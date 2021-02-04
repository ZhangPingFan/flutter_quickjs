import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_quickjs/flutter_quickjs.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController _controller = TextEditingController(
      text: 'function func(a, b){\n   return Math.max(30, a + b * 3);\n}\n\nfunc(2,5)');
  String result = '';

  @override
  void initState() {
    super.initState();
    testFlutterQuickjs();
  }

  runJs() {
    var qjs = new FlutterQuickjs();
    var res;
    try {
      res = qjs.eval(_controller.text);
    } catch (e) {
      res = e.message;
    }
    setState(() {
      result = res.toString();
    });
    qjs.close();
  }

  Future<void> testFlutterQuickjs() async {
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
    } catch (e) {
      print(e);
    }

    qjs.close();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('flutter_quickjs'),
        ),
        body: Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
            children: <Widget>[
              TextField(
                autofocus: true,
                maxLines: 15,
                controller: _controller,
                decoration: InputDecoration(
                    hintText: "write your js"),
              ),
              SizedBox(height: 25),
              Text(result, textAlign: TextAlign.left, style: TextStyle(fontSize: 20))
            ],
        )),
        floatingActionButton: FloatingActionButton(
          onPressed: runJs,
          tooltip: 'Run',
          child: Icon(Icons.play_arrow_rounded, size: 40),
        ),
      ),
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
