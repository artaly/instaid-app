import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instaid_dev/components/back_button.dart';
import 'package:instaid_dev/components/custom_suffix_icon.dart';
import 'package:instaid_dev/components/default_button.dart';
import 'package:instaid_dev/components/form_error.dart';
import 'package:instaid_dev/components/no_account.dart';
import 'package:instaid_dev/constants.dart';
import 'package:instaid_dev/utils/colors.dart';
import 'package:instaid_dev/size_config.dart';
import 'package:instaid_dev/utils/keyboard_dismiss_detector.dart';

import '../../../components/bezierContainer.dart';

class Body extends StatelessWidget {
  const Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return KeyboardDismissDetector(
      child: Scaffold(
        body: Container(
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
                      SizedBox(height: height * .2),
                      Text(
                        "Forgot Password",
                        style: TextStyle(
                          fontSize: getProportionateScreenWidth(28),
                          color: textColorBlack,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: SizeConfig.screenHeight * 0.01),
                      const Text(
                        "Please enter your email and we will send \nyou a link to change your password",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColorGray,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: SizeConfig.screenHeight * 0.06),
                      const ForgotPasswordForm(),
                    ],
                  ),
                ),
              ),
              Positioned(top: 40, left: 0, child: ToBack()),
            ],
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = new TextEditingController();
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
            decoration: InputDecoration(
                labelText: "Email",
                hintText: "Enter your email",
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 42, vertical: 20),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: textColorGray),
                  gapPadding: 10,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: textColorGray),
                  gapPadding: 10,
                )),
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.03),
          DefaultButton(
            text: "Send request",
            press: () async {
              bool isEmailExist;
              bool emailValid = RegExp(r'(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
          .hasMatch(emailController.text);
              if ((emailController.text).isEmpty) {
                Fluttertoast.showToast(msg: "Please enter your email!");
              } else if (!emailValid) {
                Fluttertoast.showToast(msg: "Please enter a valid email!");
              } else {
                try {
                  var getCollection = FirebaseFirestore.instance
                      .collection('user')
                      .where('email', isEqualTo: emailController.text);
                  var fetchData = await getCollection.get();
                  print('email get  ${fetchData.docs[0]['email']}');
                  isEmailExist = true;
                } catch (e) {
                  isEmailExist = false;

                  print('email not exist');
                }
                if (isEmailExist == true) {
                  await EasyLoading.show(status: 'Setting password reset link...');
                  auth.sendPasswordResetEmail(email: emailController.text);
                  EasyLoading.dismiss();
                  Fluttertoast.showToast(msg: "Password reset link sent!");
                  Navigator.of(context).pop();
                } else {
                  Fluttertoast.showToast(msg: "This email is not registered!");
                }
              }
            },
          ),
          SizedBox(height: SizeConfig.screenHeight * 0.06),
          //const NoAccount(),
        ],
      ),
    );
  }
}
