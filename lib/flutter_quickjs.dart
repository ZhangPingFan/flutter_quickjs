import 'src/quickjs.dart';
import 'src/jsvalue.dart';

class FlutterQuickjs {
  Pointer _rt;
  Pointer _ctx;
  Pointer _global;

  /// Create a JsRuntime in QuickJS.
  FlutterQuickjs() {
    _rt = Quickjs.jsNewRuntime();
    _ctx = Quickjs.jsNewContext(_rt);
    _global = Quickjs.jsGetGlobalObject(_ctx);
  }

  /// Return the global object.
  dynamic global() {
    return ValueConverter.toDartValueFromJs(_ctx, _global);
  }

  /// Set value by the key.
  void setValue(String key, dynamic value) {
    var sourceStr = 'FlutterQuickjs.setValue';
    var source = Utf8.toUtf8(sourceStr);
    key = key.replaceAll(new RegExp(r'->'), '.');
    var lastIdx = key.lastIndexOf('.');
    var parentStr = key.substring(0, lastIdx).replaceAll(new RegExp(r'\.'), '?.');
    var propStr = key.substring(lastIdx+1);
    if (eval(parentStr, sourceStr, true) == null) {
      List varlist = parentStr.split('?.');
      var pStr = '';
      for (int i = 0; i < varlist.length; i++) {
        pStr += (i == 0 ? '' : '.') + varlist[i];
        var pStrUtf8 = Utf8.toUtf8('$pStr = $pStr || {};');
        var ret = Quickjs.jsEval(_ctx, pStrUtf8, Utf8.strlen(pStrUtf8), source, 0 << 0);
        Quickjs.jsFreeValue(_ctx, ret);
      }
    }
    Pointer<Utf8> parentUtf8 = Utf8.toUtf8(parentStr);
    var parentPtr = Quickjs.jsEval(_ctx, parentUtf8, Utf8.strlen(parentUtf8), source, 0 << 0);
    Pointer valuePtr = ValueConverter.toQuickJSValue(_ctx, value);
    Quickjs.jsSetPropertyStr(_ctx, parentPtr, Utf8.toUtf8(propStr), valuePtr);
    Quickjs.jsFreeValue(_ctx, parentPtr);
  }

  /// Evaluate the given JavaScript string and return the result.
  dynamic eval(String script, [String source, bool free = false]) {
    Pointer<Utf8> input = Utf8.toUtf8(script);
    Pointer<Utf8> filename = Utf8.toUtf8(source ?? '<anonymous>');
    int inputLen = Utf8.strlen(input);
    var ret = Quickjs.jsEval(_ctx, input, inputLen, filename, 0 << 0);
    var result = ValueConverter.toDartValueFromJs(_ctx, ret);
    if (result is! HostFunction) {
      Quickjs.jsFreeValue(_ctx, ret);
    }
    if (result is Exception) {
      throw result;
    }
    return result;
  }

  /// Release the JsRuntime.
  close() {
    // todo: use finalizer instead (https://github.com/dart-lang/sdk/issues/35770)
    JSFunction.clearCache(_ctx);
    HostFunctionProxy.clearCache(_ctx);
    Quickjs.jsFreeValue(_ctx, _global);
    Quickjs.jsFreeContext(_ctx);
    Quickjs.jsFreeRuntime(_rt);
  }
}
