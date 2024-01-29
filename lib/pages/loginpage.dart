import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatefulWidget {
  final callback;
  const LoginPage({super.key , this.callback});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isOtpSent = false;
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
  

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Login Page'),
            const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'SFBU Email',
              ),
            ),
            
            isOtpSent
                ? const TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'OTP',
                    ),
                  )
                : const SizedBox(),
            ElevatedButton(
              onPressed: () {
                if(isOtpSent){
                  prefs?.setString('loginToken', 'token');
                  widget.callback!();
                }else{
                  setState(() {
                    isOtpSent = true;
                  });
                }
              },
              child: Text(isOtpSent ? 'Login' : 'Send OTP'),
            ),
          ],
        )
      ),
    );
  }
}