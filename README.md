# flutter_quickjs

Flutter bindings with [dart:ffi](https://flutter.dev/docs/development/platform-integration/c-interop) for [QuickJS](https://bellard.org/quickjs/):A small Javascript engine supports ES2020.

Supports iOS, Android.

## Install
To use this plugin, add `flutter_quickjs` as a [dependency in your pubspec.yaml file](https://flutter.dev/platform-plugins/).

## Usage
``` dart
import 'package:flutter/material.dart';
import 'package:flutter_quickjs/flutter_quickjs.dart';

void main() {
  var evalResult = runJs();
  runApp(
    MaterialApp(
      home: Material(
        child: Center(
          child: Text(evalResult),
        ),
      ),
    ),
  );
}

runJs() {
  var qjs = new FlutterQuickjs();
  var res;
  try {
    res = qjs.eval('Math.PI');
  } catch (e) {
    res = e.message;
  }
  qjs.close();
  return res.toString();
}
```
More usages see [example](./example/lib/main.dart)

## Todo
- bytecode support
- support more platforms like macos,linux 

## Reference
- [bellard/quickjs](https://github.com/bellard/quickjs)
- [ekibun/flutter_qjs](https://github.com/ekibun/flutter_qjs)
- [Pocket4D/quickjs_dart](https://github.com/Pocket4D/quickjs_dart)
- [siuying/QuickJS-iOS](https://github.com/siuying/QuickJS-iOS)

## Lincense

[MIT](LICENSE) © ZhangPingFan