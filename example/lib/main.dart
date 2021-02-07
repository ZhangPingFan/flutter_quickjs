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
      text: 'const jsonData={ \n "0":0,\n "1":1,\n "2":2,\n "length":3 }\n\nconst func = (a, b) => {\n   let arr=Array.from(jsonData) \n   return Math.max(30, a + b * 3 * arr[2]);\n}\n\nfunc(...[2,5])');
  String result = '';

  @override
  void initState() {
    super.initState();
    runJs();
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
    if (!mounted) return;

    var qjs = FlutterQuickjs();
    var ret;
    // number
    print('=== number test ===');
    print(qjs.eval('3 * 21'));
    print(qjs.eval('Math.PI'));
    // boolean
    print('=== boolean test ===');
    print(qjs.eval('1 == 1'));
    print(qjs.eval('1 == 2'));
    // string
    print('=== string test ===');
    print(qjs.eval('"hello"'));
    // object
    print('=== object test ===');
    ret = qjs.eval("var obj = {a: 1, b: 'c', 'd': { e : { f : 222} }};obj");
    print(ret);
    print(ret['d']['e']['f']);
    print(qjs.eval("JSON.stringify(obj)"));
    print(qjs.eval("globalThis.obj.b"));
    print(qjs.eval("globalThis?.notfound?.haha"));
    // function
    print('=== function test ===');
    ret = qjs.eval("function func(a, b){return a + b;}func");
    print(ret);
    var x = ret.call('a', 'b');
    print(x);
    print(ret('a', 1, 'b', 1));
    var retRet = ret('b', 3);
    print(retRet);
    // array
    print('=== array test ===');
    ret = qjs.eval("var arr = [1, 'a', 5, {c: 'd'}];arr");
    print(ret);
    print(ret[2]);
    print(ret[0]);
    print(ret[3]['c']);
    // error
    print('=== error test ===');
    try {
      ret = qjs.eval("throw new Error('jserror');", "test.js");
    } catch (e) {
      print(e.message);
    }

    // setValue & dart function call
    print('=== setValue test ===');
    qjs.setValue("globalThis.testObj.a.b", {'abc': 1});
    print(qjs.eval("globalThis?.testObj?.a?.b"));
    qjs.setValue("globalThis.console.log", (msg1, msg2, msg3) {
      print(msg1);
      print(msg2);
      print(msg3);
      print('hello console log');
      return [2, 4];
    });
    print(qjs.eval('console.log("logs from js", 3);'));
    var consolelog = qjs.eval('console.log');
    print(consolelog('call console.log from dart', 2));
    qjs.setValue("globalThis.globalArray", ['aa', 33, (msg){ print(msg); }]);
    var global = qjs.global();
    print(global);
    print(global['func'](123, 32));
    global['console']['log']('call console.log from dart', 3);
    global['globalArray'][2]('test func in array');

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
