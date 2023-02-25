import 'package:flutter/material.dart';

import 'package:instaid_dev/utils/colors.dart';
import '../size_config.dart';
import 'package:instaid_dev/screens/register/register.dart';

class NoAccount extends StatelessWidget {
  const NoAccount({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(fontSize: getProportionateScreenWidth(16), color: textColorBlack),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, RegisterScreen.id),
          child: Text("Register",
              style: TextStyle(
                  fontSize: getProportionateScreenWidth(16),
                  color: primaryColor)),
        ),
      ],
    );
  }
}
