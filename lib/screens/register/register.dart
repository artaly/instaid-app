import 'package:flutter/material.dart';

import '../register/components/body.dart';

class RegisterScreen extends StatelessWidget {
  static const id = 'RegisterScreen';
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(),
    );
  }
}
