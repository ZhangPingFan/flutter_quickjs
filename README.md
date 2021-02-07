# flutter_quickjs

Flutter bindings with [dart:ffi](https://flutter.dev/docs/development/platform-integration/c-interop) for [QuickJS](https://bellard.org/quickjs/) : A small Javascript engine supports **ES2020**.

This is a plugin help execute javascript on flutter app, which is convenient to use with simple apis, and it supports **iOS, Android** now.

## Install
To use this plugin, add `flutter_quickjs` as a [dependency in your pubspec.yaml file](https://pub.dev/packages/flutter_quickjs/install).

## Usage

### Basic Example
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
  var qjs = FlutterQuickjs();
  var res = qjs.eval('Math.PI');
  qjs.close();
  return res.toString();
}
```
### Global Object
```dart
qjs.eval('var a = 666;');
print(qjs.global()['a']);
// 666
```
### Set Value
```dart
qjs.setValue('globalThis.console.log', (msg) {
  print(msg);
});
qjs.eval('console.log("hello world!")');
// hello world!
```

### JS Function Call
```dart
var func = qjs.eval('function func(a, b){return [a, b, a + b];}func');
print(func(2,3));
// [2, 3, 5]
```
For more usages please see [example](./example/lib/main.dart)

## Datatype Mapping
| dart                         | js         |
| ---------------------------- | ---------- |
| null                         | Undefined / Null  |
| Bool                         | Boolean    |
| Int                          | Number     |
| Double                       | Number     |
| String                       | String     |
| List                         | Array      |
| Map                          | Object     |
| Function                     | Function   |
| Exception                    | Error      |

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