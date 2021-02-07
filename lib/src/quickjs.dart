import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'utils.dart';

export 'dart:ffi';
export 'package:ffi/ffi.dart';

class Quickjs {
  static final DynamicLibrary ffiqjsLib = dlopenPlatformSpecific('ffiqjs');

  static final Pointer Function() jsNewRuntime = ffiqjsLib
      .lookup<NativeFunction<Pointer Function()>>('jsNewRuntime')
      .asFunction();
  static final void Function(Pointer) jsFreeRuntime = ffiqjsLib
      .lookup<NativeFunction<Void Function(Pointer)>>('jsFreeRuntime')
      .asFunction();
  static final Pointer Function(Pointer) jsNewContext = ffiqjsLib
      .lookup<NativeFunction<Pointer Function(Pointer)>>('jsNewContext')
      .asFunction();
  static final void Function(Pointer) jsFreeContext = ffiqjsLib
      .lookup<NativeFunction<Void Function(Pointer)>>('jsFreeContext')
      .asFunction();
  static final void Function(Pointer, Pointer) jsFreeValue = ffiqjsLib
      .lookup<NativeFunction<Void Function(Pointer, Pointer)>>('jsFreeValue')
      .asFunction();
  static final Pointer Function(Pointer, Pointer) jsDupValue = ffiqjsLib
      .lookup<NativeFunction<Pointer Function(Pointer, Pointer)>>('jsDupValue')
      .asFunction();
  static final void Function(Pointer, int) jsFreeAtom = ffiqjsLib
      .lookup<NativeFunction<Void Function(Pointer, Int32)>>('jsFreeAtom')
      .asFunction();
  static final Pointer Function(Pointer) jsGetGlobalObject = ffiqjsLib
      .lookup<NativeFunction<Pointer Function(Pointer)>>('jsGetGlobalObject')
      .asFunction();
  static final Pointer Function(Pointer, Pointer<Utf8>, int, Pointer<Utf8>, int)
      jsEval = ffiqjsLib
          .lookup<
              NativeFunction<
                  Pointer Function(Pointer, Pointer<Utf8>, Int64, Pointer<Utf8>,
                      Int32)>>('jsEval')
          .asFunction();
  static final Pointer Function(Pointer, Pointer, Pointer, int, Pointer)
      jsCall = ffiqjsLib
          .lookup<
              NativeFunction<
                  Pointer Function(
                      Pointer, Pointer, Pointer, Int32, Pointer)>>('jsCall')
          .asFunction();
  static final int Function(Pointer) jsValueGetTag = ffiqjsLib
      .lookup<NativeFunction<Int32 Function(Pointer)>>('jsValueGetTag')
      .asFunction();
  static final int Function(Pointer) jsIsObject = ffiqjsLib
      .lookup<NativeFunction<Int32 Function(Pointer)>>('jsIsObject')
      .asFunction();
  static final int Function(Pointer, Pointer) jsIsFunction = ffiqjsLib
      .lookup<NativeFunction<Int32 Function(Pointer, Pointer)>>('jsIsFunction')
      .asFunction();
  static final int Function(Pointer, Pointer) jsIsArray = ffiqjsLib
      .lookup<NativeFunction<Int32 Function(Pointer, Pointer)>>('jsIsArray')
      .asFunction();
  static final int Function(Pointer, Pointer) jsToBool = ffiqjsLib
      .lookup<NativeFunction<Int32 Function(Pointer, Pointer)>>('jsToBool')
      .asFunction();
  static final int Function(Pointer, Pointer) jsToInt32 = ffiqjsLib
      .lookup<NativeFunction<Int32 Function(Pointer, Pointer)>>('jsToInt32')
      .asFunction();
  static final int Function(Pointer, Pointer) jsToInt64 = ffiqjsLib
      .lookup<NativeFunction<Int64 Function(Pointer, Pointer)>>('jsToInt64')
      .asFunction();
  static final double Function(Pointer, Pointer) jsToFloat64 = ffiqjsLib
      .lookup<NativeFunction<Double Function(Pointer, Pointer)>>('jsToFloat64')
      .asFunction();
  static final Pointer Function(Pointer, Pointer) jsToString = ffiqjsLib
      .lookup<NativeFunction<Pointer Function(Pointer, Pointer)>>('jsToString')
      .asFunction();
  static final Pointer<Utf8> Function(Pointer, Pointer) jsToCString = ffiqjsLib
      .lookup<NativeFunction<Pointer<Utf8> Function(Pointer, Pointer)>>(
          'jsToCString')
      .asFunction();
  static final Pointer Function(Pointer, int) jsAtomToValue = ffiqjsLib
      .lookup<NativeFunction<Pointer Function(Pointer, Int32)>>('jsAtomToValue')
      .asFunction();
  static final Pointer Function(Pointer) jsGetException = ffiqjsLib
      .lookup<NativeFunction<Pointer Function(Pointer)>>('jsGetException')
      .asFunction();
  static final Pointer Function(Pointer, Pointer, int) jsGetProperty = ffiqjsLib
      .lookup<NativeFunction<Pointer Function(Pointer, Pointer, Int32)>>(
          'jsGetProperty')
      .asFunction();
  static final Pointer Function(Pointer, Pointer, Pointer<Utf8>)
      jsGetPropertyStr = ffiqjsLib
          .lookup<
              NativeFunction<
                  Pointer Function(
                      Pointer, Pointer, Pointer<Utf8>)>>('jsGetPropertyStr')
          .asFunction();
  static final Pointer Function(Pointer, Pointer, int) jsGetPropertyUint32 =
      ffiqjsLib
          .lookup<NativeFunction<Pointer Function(Pointer, Pointer, Int32)>>(
              'jsGetPropertyUint32')
          .asFunction();
  static final int Function(Pointer, Pointer, Pointer, Pointer, int)
      jsGetOwnPropertyNames = ffiqjsLib
          .lookup<
              NativeFunction<
                  Int32 Function(Pointer, Pointer, Pointer, Pointer,
                      Int32)>>('jsGetOwnPropertyNames')
          .asFunction();
  static final int Function(Pointer, Pointer, Pointer<Utf8>, Pointer)
      jsSetPropertyStr = ffiqjsLib
          .lookup<
              NativeFunction<
                  Int32 Function(Pointer, Pointer, Pointer<Utf8>,
                      Pointer)>>('jsSetPropertyStr')
          .asFunction();
  static final int Function(Pointer, Pointer, Pointer<Utf8>, Pointer, int)
      jsDefinePropertyValueStr = ffiqjsLib
          .lookup<
              NativeFunction<
                  Int32 Function(Pointer, Pointer, Pointer<Utf8>, Pointer,
                      Int32)>>('jsDefinePropertyValueStr')
          .asFunction();
  static final int Function(Pointer, Pointer, int, Pointer, int)
      jsDefinePropertyValueUint32 = ffiqjsLib
          .lookup<
              NativeFunction<
                  Int32 Function(Pointer, Pointer, Uint32, Pointer,
                      Int32)>>('jsDefinePropertyValueUint32')
          .asFunction();
  static final int Function(Pointer, int) jsPropertyEnumGetAtom = ffiqjsLib
      .lookup<NativeFunction<Int32 Function(Pointer, Int32)>>(
          'jsPropertyEnumGetAtom')
      .asFunction();
  static final int Function() sizeOfJSValue = ffiqjsLib
      .lookup<NativeFunction<Int32 Function()>>('sizeOfJSValue')
      .asFunction();
  static final Pointer Function(Pointer, int) getValueAtIndex = ffiqjsLib
      .lookup<NativeFunction<Pointer Function(Pointer, Int32)>>(
          'getValueAtIndex')
      .asFunction();
  static final void Function(Pointer, int, Pointer) setValueAtIndex = ffiqjsLib
      .lookup<NativeFunction<Void Function(Pointer, Int32, Pointer)>>(
          'setValueAtIndex')
      .asFunction();
  static final Pointer Function() jsUndefined = ffiqjsLib
      .lookup<NativeFunction<Pointer Function()>>('jsUndefined')
      .asFunction();
  static final Pointer Function(Pointer, int) jsNewBool = ffiqjsLib
      .lookup<NativeFunction<Pointer Function(Pointer, Int32)>>('jsNewBool')
      .asFunction();
  static final Pointer Function(Pointer, int) jsNewInt64 = ffiqjsLib
      .lookup<NativeFunction<Pointer Function(Pointer, Int64)>>('jsNewInt64')
      .asFunction();
  static final Pointer Function(Pointer, double) jsNewFloat64 = ffiqjsLib
      .lookup<NativeFunction<Pointer Function(Pointer, Double)>>('jsNewFloat64')
      .asFunction();
  static final Pointer Function(Pointer, Pointer<Utf8>) jsNewString = ffiqjsLib
      .lookup<NativeFunction<Pointer Function(Pointer, Pointer<Utf8>)>>(
          'jsNewString')
      .asFunction();
  static final Pointer Function(Pointer) jsNewArray = ffiqjsLib
      .lookup<NativeFunction<Pointer Function(Pointer)>>('jsNewArray')
      .asFunction();
  static final Pointer Function(Pointer) jsNewObject = ffiqjsLib
      .lookup<NativeFunction<Pointer Function(Pointer)>>('jsNewObject')
      .asFunction();
  static final void Function(Pointer) registerGlobalDartCallback = ffiqjsLib
      .lookup<NativeFunction<Void Function(Pointer)>>(
          'registerGlobalDartCallback')
      .asFunction();
  static final Pointer Function(Pointer, int) createFunctionFromDart = ffiqjsLib
      .lookup<NativeFunction<Pointer Function(Pointer, Int32)>>(
          'createFunctionFromDart')
      .asFunction();
}
