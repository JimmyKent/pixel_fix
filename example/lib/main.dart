import 'package:flutter/material.dart';
import 'package:pixel_fix/pixel_fix.dart';

void main() {
//   runApp(MyApp());
  InnerWidgetsFlutterBinding.initPixel(1242, 3);
  InnerWidgetsFlutterBinding.ensureInitialized()
    ..attachRootWidget(MyApp())
    ..scheduleWarmUpFrame();
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Container(
            width: 200,
            height: 200,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
