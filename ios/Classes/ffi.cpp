#include <string.h>
#include "quickjs.h"

#ifdef _MSC_VER
#define DART_EXPORT __declspec(dllexport)
#else
#define DART_EXPORT __attribute__((visibility("default"))) __attribute__((used))
#endif

JSValue *(*global_dart_callback_sync)(JSContext *ctx, JSValueConst* this_val, int32_t argc, JSValueConst *argv, int callbackId);

extern "C"
{
  DART_EXPORT JSRuntime *jsNewRuntime()
  {
    JSRuntime *rt = JS_NewRuntime();
    return rt;
  }

  DART_EXPORT void jsFreeRuntime(JSRuntime *rt)
  {
    JS_FreeRuntime(rt);
  }

  DART_EXPORT JSContext *jsNewContext(JSRuntime *rt)
  {
    JSContext *ctx = JS_NewContext(rt);
    return ctx;
  }

  DART_EXPORT void jsFreeContext(JSContext *ctx)
  {
    JS_FreeContext(ctx);
  }

  DART_EXPORT JSRuntime *jsGetRuntime(JSContext *ctx)
  {
    return JS_GetRuntime(ctx);
  }

  DART_EXPORT JSValue *jsGetGlobalObject(JSContext *ctx)
  {
    return new JSValue(JS_GetGlobalObject(ctx));
  }

  DART_EXPORT JSValue *jsEval(JSContext *ctx, const char *input, int64_t input_len, const char *filename, int32_t eval_flags)
  {
    return new JSValue(JS_Eval(ctx, input, input_len, filename, eval_flags));
  }

  DART_EXPORT int32_t jsValueGetTag(JSValue *val)
  {
    int32_t tag = JS_VALUE_GET_TAG(*val);
    #if defined(JS_NAN_BOXING)
     /* any larger tag is FLOAT64 if JS_NAN_BOXING */
     if (tag > JS_TAG_FLOAT64 || tag < JS_TAG_FIRST) {
       tag = JS_TAG_FLOAT64;
     }
    #endif
    return tag;
  }

  DART_EXPORT void *jsValueGetPtr(JSValue *val)
  {
    return JS_VALUE_GET_PTR(*val);
  }

  DART_EXPORT int32_t jsTagIsFloat64(int32_t tag)
  {
    return JS_TAG_IS_FLOAT64(tag);
  }

  DART_EXPORT JSValue *jsUndefined()
  {
    return new JSValue(JS_UNDEFINED);
  }

  DART_EXPORT JSValue *jsNewBool(JSContext *ctx, int32_t val)
  {
    return new JSValue(JS_NewBool(ctx, val));
  }

  DART_EXPORT JSValue *jsNewInt64(JSContext *ctx, int64_t val)
  {
    return new JSValue(JS_NewInt64(ctx, val));
  }

  DART_EXPORT JSValue *jsNewFloat64(JSContext *ctx, double val)
  {
    return new JSValue(JS_NewFloat64(ctx, val));
  }

  DART_EXPORT JSValue *jsNewString(JSContext *ctx, const char *str)
  {
    return new JSValue(JS_NewString(ctx, str));
  }

  DART_EXPORT JSValue *jsNewArrayBufferCopy(JSContext *ctx, const uint8_t *buf, int64_t len)
  {
    return new JSValue(JS_NewArrayBufferCopy(ctx, buf, len));
  }

  DART_EXPORT JSValue *jsNewArray(JSContext *ctx)
  {
    return new JSValue(JS_NewArray(ctx));
  }

  DART_EXPORT JSValue *jsNewObject(JSContext *ctx)
  {
    return new JSValue(JS_NewObject(ctx));
  }

  DART_EXPORT void jsFreeValue(JSContext *ctx, JSValue *val)
  {
    JS_FreeValue(ctx, *val);
    delete val;
  }

  DART_EXPORT void jsFreeValueRT(JSRuntime *rt, JSValue *val)
  {
    JS_FreeValueRT(rt, *val);
    delete val;
  }

  DART_EXPORT JSValue *jsDupValue(JSContext *ctx, JSValueConst *val)
  {
    return new JSValue(JS_DupValue(ctx, *val));
  }

  DART_EXPORT JSValue *jsDupValueRT(JSRuntime *rt, JSValueConst *val)
  {
    return new JSValue(JS_DupValueRT(rt, *val));
  }

  DART_EXPORT int32_t jsToBool(JSContext *ctx, JSValueConst *val)
  {
    return JS_ToBool(ctx, *val);
  }

  DART_EXPORT int32_t jsToInt32(JSContext *ctx, JSValueConst *val)
  {
    int32_t p;
    JS_ToInt32(ctx, &p, *val);
    return p;
  }

  DART_EXPORT int64_t jsToInt64(JSContext *ctx, JSValueConst *val)
  {
    int64_t p;
    JS_ToInt64(ctx, &p, *val);
    return p;
  }

  DART_EXPORT double jsToFloat64(JSContext *ctx, JSValueConst *val)
  {
    double p;
    JS_ToFloat64(ctx, &p, *val);
    return p;
  }

  DART_EXPORT JSValue *jsToString(JSContext *ctx, JSValueConst *val)
  {
    return new JSValue(JS_ToString(ctx, *val));
  }

  DART_EXPORT const char *jsToCString(JSContext *ctx, JSValueConst *val)
  {
    return JS_ToCString(ctx, *val);
  }

  DART_EXPORT void jsFreeCString(JSContext *ctx, const char *ptr)
  {
    return JS_FreeCString(ctx, ptr);
  }

  DART_EXPORT uint8_t *jsGetArrayBuffer(JSContext *ctx, size_t *psize, JSValueConst *obj)
  {
    return JS_GetArrayBuffer(ctx, psize, *obj);
  }

  DART_EXPORT int32_t jsIsObject(JSValueConst *val)
  {
    return JS_IsObject(*val);
  }

  DART_EXPORT int32_t jsIsFunction(JSContext *ctx, JSValueConst *val)
  {
    return JS_IsFunction(ctx, *val);
  }

  DART_EXPORT int32_t jsIsArray(JSContext *ctx, JSValueConst *val)
  {
    return JS_IsArray(ctx, *val);
  }

  DART_EXPORT JSValue *jsGetProperty(JSContext *ctx, JSValueConst *this_obj,
                                   JSAtom prop)
  {
    return new JSValue(JS_GetProperty(ctx, *this_obj, prop));
  }

  DART_EXPORT JSValue *jsGetPropertyStr(JSContext *ctx, JSValueConst *this_obj,
                                        const char *prop)
  {
    return new JSValue(JS_GetPropertyStr(ctx, *this_obj, prop));
  }

  DART_EXPORT JSValue *jsGetPropertyUint32(JSContext *ctx, JSValueConst *this_obj,
                                        uint32_t idx)
  {
    return new JSValue(JS_GetPropertyUint32(ctx, *this_obj, idx));
  }

  DART_EXPORT int32_t jsSetPropertyStr(JSContext *ctx, JSValueConst *this_obj,
                                          const char *prop, JSValue *val)
  {
    return JS_SetPropertyStr(ctx, *this_obj, prop, *val);
  }

  DART_EXPORT int jsDefinePropertyValue(JSContext *ctx, JSValueConst *this_obj,
                                          JSAtom prop, JSValue *val, int32_t flags)
  {
    return JS_DefinePropertyValue(ctx, *this_obj, prop, *val, flags);
  }

  DART_EXPORT int jsDefinePropertyValueStr(JSContext *ctx, JSValueConst *this_obj,
                                          const char *prop, JSValue *val, int flags)
  {
    return JS_DefinePropertyValueStr(ctx, *this_obj, prop, *val, flags);
  }

  DART_EXPORT int jsDefinePropertyValueUint32(JSContext *ctx, JSValueConst *this_obj,
                                          uint32_t idx, JSValue *val, int32_t flags)
  {
    return JS_DefinePropertyValueUint32(ctx, *this_obj, idx, *val, flags);
  }

  DART_EXPORT void jsFreeAtom(JSContext *ctx, JSAtom v)
  {
    JS_FreeAtom(ctx, v);
  }

  DART_EXPORT JSAtom jsValueToAtom(JSContext *ctx, JSValueConst *val)
  {
    return JS_ValueToAtom(ctx, *val);
  }

  DART_EXPORT JSValue *jsAtomToValue(JSContext *ctx, JSAtom val)
  {
    return new JSValue(JS_AtomToValue(ctx, val));
  }

  DART_EXPORT int32_t jsGetOwnPropertyNames(JSContext *ctx, JSPropertyEnum **ptab,
                                          uint32_t *plen, JSValueConst *obj, int32_t flags)
  {
    return JS_GetOwnPropertyNames(ctx, ptab, plen, *obj, flags);
  }

  DART_EXPORT JSAtom jsPropertyEnumGetAtom(JSPropertyEnum *ptab, int32_t i)
  {
    return ptab[i].atom;
  }

  DART_EXPORT JSValueConst *getValueAtIndex(JSValueConst *list, uint32_t i)
  {
    return &list[i];
  }

  DART_EXPORT void setValueAtIndex(JSValue *list, uint32_t i, JSValue *val)
  {
    list[i] = *val;
  }

  DART_EXPORT uint32_t sizeOfJSValue()
  {
    return sizeof(JSValue);
  }

  DART_EXPORT JSValue *jsCall(JSContext *ctx, JSValueConst *func_obj, JSValueConst *this_obj,
                            int32_t argc, JSValueConst *argv)
  {
    return new JSValue(JS_Call(ctx, *func_obj, *this_obj, argc, argv));
  }

  DART_EXPORT int32_t jsIsException(JSValueConst *val)
  {
    return JS_IsException(*val);
  }

  DART_EXPORT JSValue *jsGetException(JSContext *ctx)
  {
    return new JSValue(JS_GetException(ctx));
  }

  DART_EXPORT int32_t jsExecutePendingJob(JSRuntime *rt, JSContext *ctx)
  {
    return JS_ExecutePendingJob(rt, &ctx);
  }

  DART_EXPORT JSValue *jsNewPromiseCapability(JSContext *ctx, JSValue *resolving_funcs)
  {
    return new JSValue(JS_NewPromiseCapability(ctx, resolving_funcs));
  }

  JSValue dart_callback(JSContext *ctx, JSValueConst this_val, int32_t argc, JSValueConst *argv, int magic, JSValue *func_data)
  {
    if (global_dart_callback_sync == nullptr)
    {
        printf("global_dart_callback_sync is null!");
        return JS_UNDEFINED;
    }
    int32_t callbackId;
    JS_ToInt32(ctx, &callbackId, func_data[0]);
    JSValue *this_val_ptr = new JSValue(this_val);
    JSValue *result = global_dart_callback_sync(ctx, this_val_ptr, argc, argv, callbackId);
    JSValue ret = *result;
    return ret;
  }

  DART_EXPORT void registerGlobalDartCallback(JSValue *(*callback)(JSContext *ctx, JSValueConst* this_val, int32_t argc, JSValueConst *argv, int callbackId))
  {
    global_dart_callback_sync = callback;
  }

  DART_EXPORT JSValue *createFunctionFromDart(JSContext *ctx, int32_t callbackId)
  {
    JSValueConst func_data[1];
    func_data[0] = JS_NewInt32(ctx, callbackId);
    JSValue cfunc = JS_NewCFunctionData(ctx, dart_callback, 0, 0, 1, func_data);
    return new JSValue(cfunc);
  }
  
  DART_EXPORT int32_t evalScript(char *str)
  {
      JSRuntime *rt;
      JSContext *ctx;
      JSValue ret_val;
      int ret;
      
      rt = JS_NewRuntime();
      if (rt == NULL) {
          return -1;
      }        
      ctx = JS_NewContext(rt);
      if (ctx == NULL) {
          JS_FreeRuntime(rt);
          return -1;
      }
      
      if (!str)
          return -1;
      ret_val = JS_Eval(ctx, str, strlen(str), "<evalScript>", JS_EVAL_TYPE_GLOBAL);
      // JS_FreeCString(ctx, str);
      int64_t tmpint64;
      int rrr = JS_ToInt64(ctx, &tmpint64, ret_val);
      JS_FreeValue(ctx, ret_val);
      JS_FreeContext(ctx);
      JS_FreeRuntime(rt);
      return tmpint64;
  }

  DART_EXPORT int32_t native_add(int32_t x, int32_t y) {
      return x + y;
  }
}