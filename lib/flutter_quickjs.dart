
import 'dart:async';
import 'package:flutter/services.dart';

import 'ffi/quickjs.dart';
import 'ffi/jsvalue.dart';

class FlutterQuickjs {
  Pointer _rt;
  Pointer _ctx;
  Pointer _global;
  List<Pointer> _garbage = [];

  FlutterQuickjs() {
    _rt = Quickjs.jsNewRuntime();
    _ctx = Quickjs.jsNewContext(_rt);
    _global = Quickjs.jsGetGlobalObject(_ctx);
  }

  dynamic global() {
    return ValueConverter.toDartValueFromJs(_ctx, _global);
  }

  void setValue(String key, dynamic value) {
    // key = key.replaceAll(new RegExp(r'[\?*\.]'), '?.');
    key = key.replaceAll(new RegExp(r'->'), '.');
    var lastIdx = key.lastIndexOf('.');
    var parentStr = key.substring(0, lastIdx).replaceAll(new RegExp(r'\.'), '?.');
    var propStr = key.substring(lastIdx+1);
    if (eval(parentStr) == null) {
      List varlist = parentStr.split('?.');
      var pStr = '';
      for (int i = 0; i < varlist.length; i++) {
        pStr += (i == 0 ? '' : '.') + varlist[i];
        eval('$pStr = $pStr || {};');
      }
    }
    Pointer<Utf8> parentUtf8 = Utf8.toUtf8(parentStr);
    var parentPtr = Quickjs.jsEval(_ctx, parentUtf8, Utf8.strlen(parentUtf8), Utf8.toUtf8('FlutterQuickjs.setValue'), 0 << 0);
    Pointer valuePtr = ValueConverter.toQuickJSValue(_ctx, value);
    Quickjs.jsSetPropertyStr(_ctx, parentPtr, Utf8.toUtf8(propStr), valuePtr);
    Quickjs.jsFreeValue(_ctx, parentPtr);
  }

  dynamic getValue(String key) {
    key = key.replaceAll(new RegExp(r'->'), '?.');
    var value;
    try {
      value = eval(key);
    } catch(e){print(e);}
    return value;
  }

  dynamic eval(String script, [String source]) {
    Pointer<Utf8> input = Utf8.toUtf8(script);
    Pointer<Utf8> filename = Utf8.toUtf8(source ?? '<anonymous>');
    int inputLen = Utf8.strlen(input);
    var ret = Quickjs.jsEval(_ctx, input, inputLen, filename, 0 << 0);
    var result = ValueConverter.toDartValueFromJs(_ctx, ret);
    if (result is Exception) {
      Quickjs.jsFreeValue(_ctx, ret);
      throw result;
    } else if (result is! HostFunction) {
      Quickjs.jsFreeValue(_ctx, ret);
    } else {
      _garbage.add(ret);
    }
    return result;
  }

  close() {
    // todo: use finalizer instead (https://github.com/dart-lang/sdk/issues/35770)
    for (int i = 0; i < _garbage.length; i++) {
      Quickjs.jsFreeValue(_ctx, _garbage[i]);
    }
    Quickjs.jsFreeValue(_ctx, _global);
    Quickjs.jsFreeContext(_ctx);
    Quickjs.jsFreeRuntime(_rt);
  }

  static const MethodChannel _channel =
      const MethodChannel('flutter_quickjs');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static int nativeAdd(int x, int y) {
    return Quickjs.nativeAdd(x, y);
  }
  
  static int evalScript(Pointer<Utf8> script) {
    return Quickjs.evalScript(script);
  }
}
