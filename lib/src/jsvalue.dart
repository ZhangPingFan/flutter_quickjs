import 'quickjs.dart';
import 'constants.dart';

class JSValue {
  Pointer _val;
  Pointer _ctx;
  dynamic _value;

  Pointer get val => _val;
  Pointer get ctx => _ctx;

  JSValue(Pointer ctx, Pointer val, [bool dup = true]) {
    _val = dup ? Quickjs.jsDupValue(ctx, val) : val;
    _ctx = ctx;
  }

  dynamic toDartValue() {
    _value ??= ValueConverter.toDartValue(this);
    return _value;
  }

  dynamic valueOf() {
    return toDartValue();
  }

  @override
  String toString() {
    if (Quickjs.jsValueGetTag(_val) < JSTag.INT) {
      return Quickjs.jsToCString(_ctx, _val).toDartString();
    } else {
      _value ??= ValueConverter.toDartValue(this);
      return _value.toString();
    }
  }

  void release() {
    Quickjs.jsFreeValue(ctx, val);
  }
}

class JSObject extends JSValue {
  JSObject(Pointer ctx, Pointer val, [bool dup = true]) : super(ctx, val, dup);

  JSValue operator [](dynamic propName) {
    return getProperty(propName);
  }

  JSValue getProperty(dynamic propName) {
    if (propName is int) {
      return ValueConverter.toDartJSValue(
          ctx, Quickjs.jsGetPropertyUint32(ctx, val, propName), false);
    } else if (propName is String) {
      return ValueConverter.toDartJSValue(ctx,
          Quickjs.jsGetPropertyStr(ctx, val, propName.toNativeUtf8()), false);
    } else {
      print('getProperty with propName:$propName failed!');
      return null;
    }
  }
}

class JSArray extends JSObject {
  JSArray(Pointer ctx, Pointer val, [bool dup = true]) : super(ctx, val, dup);
  int get length => Quickjs.jsToInt64(
      ctx, Quickjs.jsGetPropertyStr(ctx, val, 'length'.toNativeUtf8()));
}

class JSFunction extends JSObject {
  static final Map<Pointer, List<Pointer>> _jsFunctionCache = {};

  JSFunction(Pointer ctx, Pointer val, [bool dup = true])
      : super(ctx, val, dup) {
    // keep all references to function alive util runtime closed
    var jfuncList = _jsFunctionCache[ctx] ?? <Pointer>[];
    jfuncList.add(val);
    _jsFunctionCache[ctx] = jfuncList;
  }

  static JSValue callFunction(ctx, jsfunc, arguments) {
    int argc = arguments.length;
    var sizeOfJSValue = Quickjs.sizeOfJSValue();
    var argv = calloc<Pointer<Pointer>>(
      argc > 0 ? sizeOfJSValue * argc : 1,
    );
    for (var i = 0; i < argc; i++) {
      Quickjs.setValueAtIndex(
          argv, i, ValueConverter.toQuickJSValue(ctx, arguments[i]));
    }
    var global = Quickjs.jsGetGlobalObject(ctx);
    var retVal = Quickjs.jsCall(ctx, jsfunc, global, argc, argv);
    Quickjs.jsFreeValue(ctx, global);
    calloc.free(argv);
    return ValueConverter.toDartJSValue(ctx, retVal, false);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #call) {
      final arguments = invocation.positionalArguments;
      return callFunction(ctx, val, arguments);
    } else {
      return super.noSuchMethod(invocation);
    }
  }

  JSValue apply(List<dynamic> params) {
    return callFunction(ctx, val, params);
  }

  static void clearCache([Pointer ctx]) {
    if (ctx != null) {
      var length = _jsFunctionCache[ctx]?.length;
      length ??= 0;
      for (var i = 0; i < length; i++) {
        Quickjs.jsFreeValue(ctx, _jsFunctionCache[ctx][i]);
      }
      _jsFunctionCache[ctx]?.clear();
      _jsFunctionCache[ctx] = null;
    }
  }
}

class ValueConverter {
  static dynamic toDartValue(JSValue jsval, {Map<int, dynamic> cache}) {
    var ctx = jsval.ctx;
    var val = jsval.val;
    var tag = Quickjs.jsValueGetTag(val);
    dynamic retValue;
    if (tag == JSTag.INT) {
      retValue = Quickjs.jsToInt64(ctx, val);
    } else if (tag == JSTag.BOOL) {
      retValue = Quickjs.jsToBool(ctx, val) != 0;
    } else if (tag == JSTag.NULL || tag == JSTag.UNDEFINED) {
    } else if (tag == JSTag.EXCEPTION) {
      var exception = Quickjs.jsGetException(ctx);
      retValue = toDartException(ctx, exception);
      Quickjs.jsFreeValue(ctx, exception);
    } else if (tag == JSTag.FLOAT64) {
      retValue = Quickjs.jsToFloat64(ctx, val);
    } else if (tag == JSTag.STRING) {
      retValue = Quickjs.jsToCString(ctx, val).toDartString();
    } else if (tag == JSTag.OBJECT) {
      cache ??= {};
      var valptr = Quickjs.jsValueGetPtr(val).address;
      if (cache.containsKey(valptr)) {
        return cache[valptr];
      }
      if (Quickjs.jsIsFunction(ctx, val) != 0) {
        retValue = HostFunction((arguments) {
          var resJval = (jsval as JSFunction).apply(arguments);
          var res = toDartValue(resJval);
          resJval.release();
          if (res is Exception) {
            throw res;
          }
          return res;
        });
      } else if (Quickjs.jsIsArray(ctx, val) != 0) {
        var length = Quickjs.jsToInt32(
            ctx, Quickjs.jsGetPropertyStr(ctx, val, 'length'.toNativeUtf8()));
        var list = [];
        cache[valptr] = list;
        for (var i = 0; i < length; i++) {
          JSValue jval = toDartJSValue(
              ctx, Quickjs.jsGetPropertyUint32(ctx, val, i), false);
          list.add(toDartValue(jval, cache: cache));
          if (list[i] is! HostFunction) {
            jval.release();
          }
        }
        return list;
      } else {
        var map = <String, dynamic>{};
        var ptab = calloc<Pointer<Pointer>>();
        var plen = calloc<Uint32>();
        cache[valptr] = map;
        if (Quickjs.jsGetOwnPropertyNames(ctx, ptab, plen, val, -1) == 0) {
          var length = plen.value;
          for (var i = 0; i < length; i++) {
            var jsAtom = Quickjs.jsPropertyEnumGetAtom(ptab.value, i);
            var jsAtomValue = Quickjs.jsAtomToValue(ctx, jsAtom);
            var jsProp = Quickjs.jsGetProperty(ctx, val, jsAtom);
            map[toDartValueFromJs(ctx, jsAtomValue, cache: cache)] =
                toDartValueFromJs(ctx, jsProp, cache: cache);
            Quickjs.jsFreeValue(ctx, jsAtomValue);
            if (Quickjs.jsIsFunction(ctx, jsProp) == 0) {
              Quickjs.jsFreeValue(ctx, jsProp);
            }
            Quickjs.jsFreeAtom(ctx, jsAtom);
          }
        }
        calloc.free(ptab);
        calloc.free(plen);
        return map;
      }
    } else {
      print('JsValue with Tag:$tag convert failed!');
    }
    return retValue;
  }

  static dynamic toDartValueFromJs(Pointer ctx, Pointer val,
      {Map<int, dynamic> cache}) {
    return toDartValue(toDartJSValue(ctx, val, false), cache: cache);
  }

  static Pointer toQuickJSValue(Pointer ctx, dynamic val) {
    Pointer jsVal;
    if (val == null) {
      jsVal = Quickjs.jsUndefined();
    } else if (val is bool) {
      jsVal = Quickjs.jsNewBool(ctx, val ? 1 : 0);
    } else if (val is int) {
      jsVal = Quickjs.jsNewInt64(ctx, val);
    } else if (val is double) {
      jsVal = Quickjs.jsNewFloat64(ctx, val);
    } else if (val is String) {
      jsVal = Quickjs.jsNewString(ctx, val.toNativeUtf8());
    } else if (val is Map) {
      jsVal = Quickjs.jsNewObject(ctx);
      val.forEach((key, value) {
        Quickjs.jsSetPropertyStr(
            ctx, jsVal, key.toString().toNativeUtf8(), toQuickJSValue(ctx, value));
      });
    } else if (val is List) {
      jsVal = Quickjs.jsNewArray(ctx);
      for (var i = 0; i < val.length; i++) {
        Quickjs.jsDefinePropertyValueUint32(
            ctx, jsVal, i, toQuickJSValue(ctx, val[i]), JSProp.C_W_E);
      }
    } else if (val is Function) {
      var hostFuncProxy = HostFunctionProxy(ctx, val);
      jsVal = Quickjs.createFunctionFromDart(ctx, hostFuncProxy.id);
    } else {
      print('valueType not supported in ValueConverter.toQuickJSValue');
      jsVal = Quickjs.jsUndefined();
    }
    return jsVal;
  }

  static dynamic toDartJSValue(Pointer ctx, Pointer val, [bool dup = true]) {
    if (Quickjs.jsIsFunction(ctx, val) != 0) {
      return JSFunction(ctx, val, dup);
    } else if (Quickjs.jsIsArray(ctx, val) != 0) {
      return JSArray(ctx, val, dup);
    } else if (Quickjs.jsIsObject(val) != 0) {
      return JSObject(ctx, val, dup);
    } else {
      return JSValue(ctx, val, dup);
    }
  }

  static Exception toDartException(Pointer ctx, Pointer exception) {
    var err = Quickjs.jsToCString(ctx, exception).toDartString();
    if (Quickjs.jsValueGetTag(exception) == JSTag.OBJECT) {
      var stack =
          Quickjs.jsGetPropertyStr(ctx, exception, 'stack'.toNativeUtf8());
      if (Quickjs.jsToBool(ctx, stack) != 0) {
        err += '\n' + Quickjs.jsToCString(ctx, stack).toDartString();
      }
      Quickjs.jsFreeValue(ctx, stack);
    }
    return Exception(err);
  }
}

class HostFunction {
  final Function _onCall;
  int _argNum;
  int get length => _argNum;

  HostFunction(this._onCall) {
    var runtimeTypeStr = _onCall.runtimeType.toString();
    if (runtimeTypeStr.indexOf('(') == runtimeTypeStr.indexOf(')') - 1) {
      _argNum = 0;
    } else {
      var argsStr = runtimeTypeStr.splitMapJoin((RegExp(r',')),
          onMatch: (m) => '${m.group(0)}', onNonMatch: (n) => '');
      _argNum = argsStr.length + 1;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #call) {
      final arguments = invocation.positionalArguments;
      return _onCall(arguments);
    } else {
      return super.noSuchMethod(invocation);
    }
  }

  dynamic apply(List<dynamic> params) {
    return Function.apply(_onCall, params);
  }
}

class HostFunctionProxy {
  static final Map<Pointer, List<dynamic>> _hostFunctionCache = {};
  static bool initialized = false;
  int _callbackId;
  int get id => _callbackId;

  HostFunctionProxy(Pointer ctx, Function func) {
    if (!initialized) {
      final functionCallbackPointer = Pointer.fromFunction<
          Pointer Function(
              Pointer, Pointer, Int32, Pointer, Int32)>(functionCallback);
      Quickjs.registerGlobalDartCallback(functionCallbackPointer);
      initialized = true;
    }
    var funcList = _hostFunctionCache[ctx] ?? <dynamic>[];
    funcList.add(HostFunction(func));
    _callbackId = funcList.length - 1;
    _hostFunctionCache[ctx] = funcList;
  }

  static Pointer functionCallback(
      Pointer ctx, Pointer thisVal, int argc, Pointer argv, int callbackId) {
    var jsVal = Quickjs.jsUndefined();
    try {
      var funcList = _hostFunctionCache[ctx];
      var _hostFunction = funcList[callbackId];
      int _requestArgc = _hostFunction.length;
      if (_hostFunction != null) {
        var params = [];
        for (var i = 0; i < _requestArgc; i++) {
          if (i < argc) {
            var arg = Quickjs.getValueAtIndex(argv, i);
            params.add(ValueConverter.toDartValueFromJs(ctx, arg));
          } else {
            params.add(null);
          }
        }
        var ret = _hostFunction.apply(params);
        jsVal = ValueConverter.toQuickJSValue(ctx, ret);
      }
    } catch (e) {
      print(e);
    }
    return jsVal;
  }

  static void clearCache([Pointer ctx]) {
    if (ctx != null) {
      _hostFunctionCache[ctx]?.clear();
      _hostFunctionCache[ctx] = null;
    }
  }
}
