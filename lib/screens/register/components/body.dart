// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:instaid_dev/components/back_button.dart';
import 'package:instaid_dev/constants.dart';
import 'package:instaid_dev/size_config.dart';
import 'package:instaid_dev/utils/colors.dart';
import 'package:instaid_dev/utils/keyboard_dismiss_detector.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../components/bezierContainer.dart';
import 'register_form.dart';

class Body extends StatelessWidget {
  const Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final url = Uri.parse('https://github.com/artaly/instaid_release/blob/main/README.md');
    final height = MediaQuery.of(context).size.height;
    return KeyboardDismissDetector(
        child: Scaffold(
      body: Container(
        height: height,
        child: Stack(
          children: <Widget>[
            Positioned(
                top: -height * .25,
                right: -MediaQuery.of(context).size.width * .4,
                child: const BezierContainer()),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: height * .1),
                    Text(
                      "Register Account",
                      style: headingStyle,
                    ),
                    SizedBox(height: SizeConfig.screenHeight * 0.03),
                    RegisterForm(),
                    SizedBox(height: SizeConfig.screenHeight * 0.03),
                    //SizedBox(height: getProportionateScreenHeight(20)),
                    Column(
                      children: [
                        Text(
                          "By continuing, you agree to our",
                          style: TextStyle(
                              fontSize: getProportionateScreenWidth(13)),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (await canLaunchUrl(url))
                              await launchUrl(url);
                            else
                              // can't launch url, there is some error
                              throw "Could not launch $url";
                          },
                          child: Text("Terms and Conditions",
                              style: TextStyle(
                                  fontSize: getProportionateScreenWidth(13),
                                  color: primaryColor)),
                        ),
                      ],
                    ),

                    SizedBox(height: SizeConfig.screenHeight * 0.03),
                  ],
                ),
              ),
            ),
            Positioned(top: 40, left: 0, child: ToBack()),
          ],
        ),
      ),
    ));
  }
}
