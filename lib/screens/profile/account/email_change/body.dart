import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instaid_dev/components/back_button.dart';
import 'package:instaid_dev/components/default_button.dart';
import 'package:instaid_dev/resources/auth_methods.dart';
import 'package:instaid_dev/screens/main_screen.dart';
import 'package:instaid_dev/size_config.dart';
import 'package:instaid_dev/utils/colors.dart';
import 'package:instaid_dev/utils/keyboard_dismiss_detector.dart';
import 'package:instaid_dev/utils/utils.dart';

class Body extends StatefulWidget {
  final String uid;
  const Body({Key? key, required this.uid}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final TextEditingController emailController = new TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      controller: emailController,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          labelText: "Email",
          hintText: "Enter new email",
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding: EdgeInsets.symmetric(horizontal: 42, vertical: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: textColorGray),
            gapPadding: 5,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: primaryColor),
            gapPadding: 5,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : KeyboardDismissDetector(
            child: Scaffold(
            body: Container(
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: SizeConfig.screenHeight * .12),
                          Text(
                            "Change email",
                            style: TextStyle(
                              fontSize: getProportionateScreenWidth(28),
                              color: textColorBlack,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: SizeConfig.screenHeight * 0.05),
                          buildEmailFormField(),
                          SizedBox(height: SizeConfig.screenHeight * 0.04),
                          DefaultButton(
                            text: "Change",
                            press: changeEmail,
                          ),
                          SizedBox(
                            height: getProportionateScreenHeight(40),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(top: 40, left: 0, child: ToBack()),
                ],
              ),
            ),
          ));
  }

  void changeEmail() async {
    try {
      bool emailValid = RegExp(
              r'(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
          .hasMatch(emailController.text);
      if ((emailController.text).isEmpty) {
        Fluttertoast.showToast(msg: "Please enter your new email!");
      } else if (!emailValid) {
        Fluttertoast.showToast(msg: "Please enter a valid email!");
      } else {
        bool isEmailExist;
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

        if (isEmailExist == false) {
          await EasyLoading.show(status: 'Changing email...');
          String res =
              await AuthMethods().updateEmail(email: emailController.text);

          emailController.clear();
          EasyLoading.dismiss();
          Fluttertoast.showToast(msg: "Successfully changed email!");
          Navigator.pushNamed(context, MainScreen.id);
        } else {
          if (isEmailExist) {
            Fluttertoast.showToast(msg: "This email is already in use!");
          }
        }
      }
    } catch (err) {
      print("Error" + err.toString());
    }
  }
}
