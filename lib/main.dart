import 'package:flutter/material.dart';
import 'pages/loginpage.dart';
import 'pages/homepage.dart';
import 'package:sfbu_hub/api_layer/api.dart' as api;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const FirstPage());
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("ae7e51c9-dd9d-4b56-a2aa-64ca62309d03");
  OneSignal.Notifications.requestPermission(true);
  var uuid = const Uuid().v4();
  api.LocalStorageApi().setNotificationToken(uuid);
  OneSignal.login(uuid);
  // OneSignal.externalUserId("testing");
}

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
