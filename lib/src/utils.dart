import 'dart:ffi';
import 'dart:io' show Platform;

String _platformPath(String name, {String path}) {
  path ??= '';
  if (Platform.isLinux || Platform.isAndroid) {
    return path + 'lib' + name + '.so';
  }
  if (Platform.isMacOS) return path + 'lib' + name + '.dylib';
  if (Platform.isWindows) return path + name + '.dll';
  throw Exception('Platform not implemented');
}

DynamicLibrary dlopenPlatformSpecific(String name, {String path}) {
  if (Platform.isIOS) {
    return DynamicLibrary.process();
  }
  var fullPath = _platformPath(name, path: path);
  return DynamicLibrary.open(fullPath);
}