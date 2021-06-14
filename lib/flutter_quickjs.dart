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
  ///
  /// Call it everytime before use to ensure the global object is up to date.
  dynamic global() {
    return ValueConverter.toDartValueFromJs(_ctx, _global);
  }

  /// Set value by the key.
  void setValue(String key, dynamic value) {
    var sourceStr = 'FlutterQuickjs.setValue';
    var source = sourceStr.toNativeUtf8();
    key = key.replaceAll(RegExp(r'->'), '.');
    var lastIdx = key.lastIndexOf('.');
    var parentStr = key.substring(0, lastIdx).replaceAll(RegExp(r'\.'), '?.');
    var propStr = key.substring(lastIdx + 1);
    if (eval(parentStr, sourceStr, true) == null) {
      List varlist = parentStr.split('?.');
      var pStr = '';
      for (var i = 0; i < varlist.length; i++) {
        pStr += (i == 0 ? '' : '.') + varlist[i];
        var pStrUtf8 = '$pStr = $pStr || {};'.toNativeUtf8();
        var ret = Quickjs.jsEval(
            _ctx, pStrUtf8, pStrUtf8.length, source, 0 << 0);
        Quickjs.jsFreeValue(_ctx, ret);
      }
    }
    var parentUtf8 = parentStr.toNativeUtf8();
    var parentPtr = Quickjs.jsEval(
        _ctx, parentUtf8, parentUtf8.length, source, 0 << 0);
    var valuePtr = ValueConverter.toQuickJSValue(_ctx, value);
    Quickjs.jsSetPropertyStr(_ctx, parentPtr, propStr.toNativeUtf8(), valuePtr);
    Quickjs.jsFreeValue(_ctx, parentPtr);
  }

  /// Evaluate the given JavaScript string and return the result.
  dynamic eval(String script, [String source, bool free = false]) {
    var input = script.toNativeUtf8();
    var filename = (source ?? '<anonymous>').toNativeUtf8();
    var inputLen = input.length;
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

  /// Register eval() into global object by a new name.
  void registerEvalToGlobal(String funcName) {
    if (funcName != null && funcName.isNotEmpty) {
      var funcUtf8 = funcName.toNativeUtf8();
      Quickjs.registerEvalToGlobal(_ctx, funcUtf8);
    } else {
      print('registerEvalToGlobal fail because funcName is null!');
    }
  }

  /// Release the JsRuntime.
  void close() {
    // todo: use finalizer instead (https://github.com/dart-lang/sdk/issues/35770)
    JSFunction.clearCache(_ctx);
    HostFunctionProxy.clearCache(_ctx);
    Quickjs.jsFreeValue(_ctx, _global);
    Quickjs.jsFreeContext(_ctx);
    Quickjs.jsFreeRuntime(_rt);
  }
}
