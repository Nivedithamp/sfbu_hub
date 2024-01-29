import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/loginpage.dart';
import 'pages/homepage.dart';


void main() => runApp(const FirstPage());

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {

  SharedPreferences? prefs;

  

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((SharedPreferences? prefs) {
      setState(() {
        this.prefs = prefs;
      });
    });
  }

  void refresh() {

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    final loginToken = prefs?.getString('loginToken');
    if (loginToken == null) {
      return MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: LoginPage( callback: refresh ),
      );
    } else {
      return MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const NavigationBarApp(),
      );
    }

  }
}