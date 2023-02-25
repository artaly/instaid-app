import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instaid_dev/screens/register/register.dart';
import 'package:instaid_dev/size_config.dart';
import 'package:instaid_dev/utils/colors.dart';
import 'package:instaid_dev/utils/keyboard_dismiss_detector.dart';

import '../../../components/no_account.dart';
import 'login_form.dart';
import '../../../components/bezierContainer.dart';

class Body extends StatelessWidget {
  const Body({Key? key}) : super(key: key);

  Widget _title() {
    return RichText(
      textAlign: TextAlign.start,
      text: const TextSpan(
          text: 'inst',
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.w700, color: primaryColor),
          children: [
            TextSpan(
              text: 'aid',
              style: TextStyle(color: primaryColorRed, fontSize: 30),
            ),
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final height = MediaQuery.of(context).size.height;
    return KeyboardDismissDetector(
      child: Scaffold(
          body: Container(
        height: height,
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: height * 0.09),
                    SvgPicture.asset("assets/svg/icon.svg", height: 200),
                    SizedBox(height: SizeConfig.screenHeight * 0.03),
                    const LoginForm(),
                    SizedBox(height: SizeConfig.screenHeight * 0.03),
                    const NoAccount(),
                  ],
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
