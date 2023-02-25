import 'package:flutter/material.dart';
import 'package:instaid_dev/screens/login/login.dart';

import 'package:instaid_dev/utils/colors.dart';
import '../size_config.dart';
import 'package:instaid_dev/screens/register/register.dart';

class ExistingAccount extends StatelessWidget {
  const ExistingAccount({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: TextStyle(fontSize: getProportionateScreenWidth(16)),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, LoginScreen.id),
          child: Text("Login",
              style: TextStyle(
                  fontSize: getProportionateScreenWidth(16),
                  color: primaryColor)),
        ),
      ],
    );
  }
}
