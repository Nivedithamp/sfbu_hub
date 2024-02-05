import 'package:flutter/material.dart';
import 'pages/loginpage.dart';
import 'pages/homepage.dart';
import 'package:sfbu_hub/api_layer/api.dart' as api;

void main() => runApp(const FirstPage());

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  String? token;

  void refresh() {
    setState(() {});
  }

  void getToken() async {
    final token = await api.LocalStorageApi().getLoginToken();
    setState(() {
      this.token = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    getToken();
    if (token == null) {
      return MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: LoginPage(),
      );
    } else {
      return MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const NavigationBarApp(),
      );
    }
  }
}
