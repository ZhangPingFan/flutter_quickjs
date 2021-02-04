import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_quickjs/flutter_quickjs.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterQuickjs.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    var qjs = new FlutterQuickjs();
    var ret;
    ret = qjs.eval('3 * 21');
    print(ret);
    ret = qjs.eval('Math.PI');
    print(ret);
    ret = qjs.eval('"hello"');
    print(ret);
    ret = qjs.eval('1 == 2');
    print(ret);
    ret = qjs.eval("var obj = {a: 1, b: 'c', 'd': { e : { f : 222} }};obj");
    print(ret);
    print(ret['d']['e']['f']);
    ret = qjs.eval("JSON.stringify(obj)");
    print(ret);
    ret = qjs.eval("globalThis.obj.b");
    print(ret);
    ret = qjs.eval("function func(a, b){return a + b;}func");
    print(ret);
    var x = ret.call('a', 'b');
    print(x);
    print(ret('a', 1, 'b', 1));
    var retRet = ret('b', 3);
    print(retRet);
    ret = qjs.eval("var arr = [1, 'a', 5, {c: 'd'}];arr");
    print(ret);
    print(ret[2]);
    print(ret[0]);
    print(ret[3]['c']);
    print(qjs.global());

    print(qjs.getValue("globalThis->obj->b"));
    print(qjs.getValue("globalThis->notfound->haha"));
    qjs.setValue("globalThis.testObj.a.b", {'a': 1});
    print(qjs.getValue("globalThis.testObj.a.b"));
    qjs.setValue("globalThis.console.log", (msg1, msg2, msg3) {
      print(msg1);
      print(msg2);
      print(msg3);
      print('hello console log');
      return [2, 4];
    });
    print(qjs.eval('console.log("logs from js", 3);'));

    try {
      ret = qjs.eval("throw new Error('jserror');", "test.js");
    } catch(e) {print(e);}

    var res = qjs.eval('"hello quickjs"');

    qjs.close();

    setState(() {
      _platformVersion = res.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('flutter_quickjs'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
