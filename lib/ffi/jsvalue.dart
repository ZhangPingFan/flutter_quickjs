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
    return this.toDartValue();
  }

  String toString() {
    if (Quickjs.jsValueGetTag(_val) < JSTag.INT) {
      return Utf8.fromUtf8(Quickjs.jsToCString(_ctx, _val));
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
    return this.getProperty(propName);
  }

  JSValue getProperty(dynamic propName) {
    if (propName is int) {
      return ValueConverter.toDartJSValue(ctx, Quickjs.jsGetPropertyUint32(ctx, val, propName), false);
    } else if (propName is String) {
      return ValueConverter.toDartJSValue(ctx, Quickjs.jsGetPropertyStr(ctx, val, Utf8.toUtf8(propName)), false);
    } else {
      print('getProperty with propName:$propName failed!');
      return null;
    }
  }
}

class JSArray extends JSObject {
  JSArray(Pointer ctx, Pointer val, [bool dup = true]) : super(ctx, val, dup);
  int get length => Quickjs.jsToInt64(ctx, Quickjs.jsGetPropertyStr(ctx, val, Utf8.toUtf8("length")));

}

class JSFunction extends JSObject {
  static Map<Pointer, List<Pointer>> _jsFunctionCache = Map();

  JSFunction(Pointer ctx, Pointer val, [bool dup = true]) : super(ctx, val, dup) {
    // keep all references to function alive util runtime closed
    List jfuncList = _jsFunctionCache[ctx] ?? List<Pointer>();
    jfuncList.add(val);
    _jsFunctionCache[ctx] = jfuncList;
  }

  static JSValue callFunction(ctx, jsfunc, arguments) {
    int argc = arguments.length;
    int sizeOfJSValue = Quickjs.sizeOfJSValue();
    Pointer<Pointer> argv = allocate(
      count: argc > 0 ? sizeOfJSValue * argc : 1,
    );
    for (int i = 0; i < argc; i++) {
      Quickjs.setValueAtIndex(argv, i, ValueConverter.toQuickJSValue(ctx, arguments[i]));
    }
    Pointer global = Quickjs.jsGetGlobalObject(ctx);
    Pointer retVal = Quickjs.jsCall(ctx, jsfunc, global, argc, argv);
    Quickjs.jsFreeValue(ctx, global);
    free(argv);
    return ValueConverter.toDartJSValue(ctx, retVal, false);
  }

  @override
  noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #call) {
      final arguments = invocation.positionalArguments;
      return callFunction(this.ctx, this.val, arguments);
    } else {
      return super.noSuchMethod(invocation);
    }
  }

  JSValue apply(List<dynamic> params) {
    return callFunction(this.ctx, this.val, params);
  }

  static void clearCache([Pointer ctx]) {
    if (ctx != null) {
      var length = _jsFunctionCache[ctx]?.length;
      length ??= 0;
      for (int i = 0; i < length; i++) {
        Quickjs.jsFreeValue(ctx, _jsFunctionCache[ctx][i]);
      }
      _jsFunctionCache[ctx]?.clear();
      _jsFunctionCache[ctx] = null;
    }
  }
}

class ValueConverter {
  static dynamic toDartValue(JSValue jsval) {
    Pointer ctx = jsval.ctx;
    Pointer val = jsval.val;
    int tag = Quickjs.jsValueGetTag(val);
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
      retValue = Utf8.fromUtf8(Quickjs.jsToCString(ctx, val));
    } else if (tag == JSTag.OBJECT) {
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
        int length = Quickjs.jsToInt32(ctx, Quickjs.jsGetPropertyStr(ctx, val, Utf8.toUtf8("length")));
        List<dynamic> list = List(length);
        for (int i = 0; i < length; i++) {
          JSValue jval = toDartJSValue(ctx, Quickjs.jsGetPropertyUint32(ctx, val, i), false);
          list[i] = toDartValue(jval);
          if (list[i] is! HostFunction) {
            jval.release();
          }
        }
        return list;
      } else {
        Map map = Map();
        Pointer<Pointer> ptab = allocate<Pointer>();
        Pointer<Uint32> plen = allocate<Uint32>();
        if (Quickjs.jsGetOwnPropertyNames(ctx, ptab, plen, val, -1) == 0) {
          int length = plen.value;
          for (int i = 0; i < length; i++) {
            var jsAtom = Quickjs.jsPropertyEnumGetAtom(ptab.value, i);
            var jsAtomValue = Quickjs.jsAtomToValue(ctx, jsAtom);
            var jsProp = Quickjs.jsGetProperty(ctx, val, jsAtom);
            map[toDartValueFromJs(ctx, jsAtomValue)] =
                toDartValueFromJs(ctx, jsProp);
            Quickjs.jsFreeValue(ctx, jsAtomValue);
            if (Quickjs.jsIsFunction(ctx, jsProp) == 0) {
              Quickjs.jsFreeValue(ctx, jsProp);
            }
            Quickjs.jsFreeAtom(ctx, jsAtom);
          }
        }
        free(ptab);
        free(plen);
        return map;
      }
    } else {
      print('JsValue with Tag:$tag convert failed!');
    }
    return retValue;
  }

  static dynamic toDartValueFromJs(Pointer ctx, Pointer val) {
    return toDartValue(toDartJSValue(ctx, val, false));
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
      jsVal = Quickjs.jsNewString(ctx, Utf8.toUtf8(val));
    } else if (val is Map) {
      jsVal = Quickjs.jsNewObject(ctx);
      val.forEach((key, value) {
        Quickjs.jsSetPropertyStr(ctx, jsVal, Utf8.toUtf8(key), toQuickJSValue(ctx, value));
      });
    } else if (val is List) {
      jsVal = Quickjs.jsNewArray(ctx);
      for (int i = 0; i < val.length; i++) {
        Quickjs.jsDefinePropertyValueUint32(ctx, jsVal, i, toQuickJSValue(ctx, val[i]), JSProp.C_W_E);
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
    var err = Utf8.fromUtf8(Quickjs.jsToCString(ctx, exception));
    if (Quickjs.jsValueGetTag(exception) == JSTag.OBJECT) {
      Pointer stack =
          Quickjs.jsGetPropertyStr(ctx, exception, Utf8.toUtf8("stack"));
      if (Quickjs.jsToBool(ctx, stack) != 0) {
        err += '\n' + Utf8.fromUtf8(Quickjs.jsToCString(ctx, stack));
      }
      Quickjs.jsFreeValue(ctx, stack);
    }
    return Exception(err);
  }
}

class HostFunction {
  Function _onCall;
  int _argNum;
  int get length => _argNum;

  HostFunction(this._onCall) {
    String runtimeTypeStr = _onCall.runtimeType.toString();
    if (runtimeTypeStr.indexOf('(') == runtimeTypeStr.indexOf(')') - 1) {
      _argNum = 0;
    } else {
      String argsStr = runtimeTypeStr.splitMapJoin((new RegExp(r',')),
      onMatch:    (m) => '${m.group(0)}',
      onNonMatch: (n) => '');
      _argNum = argsStr.length + 1;
    }
  }

  noSuchMethod(Invocation invocation) {
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
  static Map<Pointer, List<dynamic>> _hostFunctionCache = Map();
  static bool initialized = false;
  int _callbackId;
  int get id => _callbackId;

  HostFunctionProxy(Pointer ctx, Function func) {
    if (!initialized) {
      final functionCallbackPointer = Pointer.fromFunction<Pointer Function(Pointer, Pointer, Int32, Pointer, Int32)>(functionCallback);
      Quickjs.registerGlobalDartCallback(functionCallbackPointer);
      initialized = true;
    }
    List funcList = _hostFunctionCache[ctx] ?? List<dynamic>();
    funcList.add(HostFunction(func));
    _callbackId = funcList.length - 1;
    _hostFunctionCache[ctx] = funcList;
  }

  static Pointer functionCallback(Pointer ctx, Pointer thisVal, int argc, Pointer argv, int callbackId) {
    Pointer jsVal = Quickjs.jsUndefined();
    try {
      List funcList = _hostFunctionCache[ctx];
      var _hostFunction = funcList[callbackId];
      int _requestArgc = _hostFunction.length;
      if (_hostFunction != null) {
        List params = [];
        for (int i = 0; i < _requestArgc; i++) {
          if (i < argc) {
            Pointer arg = Quickjs.getValueAtIndex(argv, i);
            params.add(ValueConverter.toDartValueFromJs(ctx, arg));
          } else {
            params.add(null);
          }
        }
        var ret = _hostFunction.apply(params);
        jsVal = ValueConverter.toQuickJSValue(ctx, ret);
      }
    } catch(e) {print(e);}
    return jsVal;
  }

  static void clearCache([Pointer ctx]) {
    if (ctx != null) {
      _hostFunctionCache[ctx]?.clear();
      _hostFunctionCache[ctx] = null;
    }
  }
}
