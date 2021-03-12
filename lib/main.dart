import 'package:flutter/material.dart';
import 'package:insurance/screens/kaza_kaydi_screen.dart';
import 'package:insurance/screens/policy_detail.dart';
import 'package:insurance/screens/kaza_screen.dart';
import 'package:insurance/screens/policy_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (ctx) => PolicyScreen(),
        PolicyDetail.routeName: (ctx) => PolicyDetail(),
        KazaScreen.routeName: (ctx) => KazaScreen(),
        KazaKaydiScreen.routeName: (ctx) => KazaKaydiScreen(),
      },
    );
  }
}
