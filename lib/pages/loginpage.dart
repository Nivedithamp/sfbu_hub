import 'package:flutter/material.dart';
import 'package:sfbu_hub/api_layer/api.dart' as api;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sfbu_hub/models/models.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isOtpSent = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool isValidEmail(String email) {
    return email.endsWith('sfbu.edu');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('Login Page'),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'SFBU Email',
            ),
          ),
          isOtpSent
              ? TextField(
                  controller: otpController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'OTP',
                  ),
                )
              : const SizedBox(),
          ElevatedButton(
            onPressed: () async {
              if (isOtpSent) {
                LoginResponse loginResponse = await api.GraphQlApi()
                    .login(emailController.text, otpController.text);
                if (loginResponse.error!) {
                  Fluttertoast.showToast(
                      msg: loginResponse.error_message!,
                      toastLength: Toast.LENGTH_SHORT);
                  return;
                }

                api.LocalStorageApi().setLoginToken(loginResponse.token!);
                api.LocalStorageApi().setEmail(emailController.text);
              } else {
                if (!isValidEmail(emailController.text)) {
                  Fluttertoast.showToast(
                      msg: 'Invalid email, Enter your SFBU email',
                      toastLength: Toast.LENGTH_SHORT);
                  return;
                }
                LoginResponse loginResponse =
                    await api.GraphQlApi().getOtp(emailController.text);
                setState(() {
                  if (loginResponse.error!) {
                    Fluttertoast.showToast(
                        msg: loginResponse.error_message!,
                        toastLength: Toast.LENGTH_SHORT);
                    return;
                  }

                  Fluttertoast.showToast(
                      msg: 'OTP sent to ${emailController.text}',
                      toastLength: Toast.LENGTH_SHORT);
                  isOtpSent = true;
                });
              }
            },
            child: Text(isOtpSent ? 'Login' : 'Send OTP'),
          ),
        ],
      )),
    );
  }
}
