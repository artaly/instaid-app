import 'package:flutter/material.dart';
import 'package:instaid_dev/screens/login/components/body.dart';

class LoginScreen extends StatelessWidget {
  static const id = 'LoginScreen';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Body(),
    );
  }
}
