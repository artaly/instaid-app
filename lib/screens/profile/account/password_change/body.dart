import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instaid_dev/components/back_button.dart';
import 'package:instaid_dev/components/default_button.dart';
import 'package:instaid_dev/resources/auth_methods.dart';
import 'package:instaid_dev/screens/main_screen.dart';
import 'package:instaid_dev/utils/keyboard_dismiss_detector.dart';
import 'package:instaid_dev/size_config.dart';
import 'package:instaid_dev/utils/colors.dart';
import 'package:instaid_dev/utils/utils.dart';

class Body extends StatefulWidget {
  final String uid;
  const Body({Key? key, required this.uid}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool isLoading = false;
  var userData = {};
  bool _obscureText = true;
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.uid)
          .get();

      userData = userSnap.data()!;
      setState(() {});
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  TextFormField buildPasswordFormField(
      {required String label, required controller, required hint}) {
    return TextFormField(
      obscureText: _obscureText,
      controller: controller,
      onSaved: (value) {
        controller.text = value!;
      },
      onChanged: (value) {
        return null;
      },
      validator: (value) {
        return null;
      },
      decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixIcon: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
            child: GestureDetector(
              onTap: _toggle,
              child: Icon(
                _obscureText
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                color: primaryColor,
                size: 24,
              ),
            ),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding: EdgeInsets.symmetric(horizontal: 42, vertical: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: textColorGray),
            gapPadding: 10,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: primaryColor),
            gapPadding: 10,
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
                              "Change password",
                              style: TextStyle(
                                fontSize: getProportionateScreenWidth(28),
                                color: textColorBlack,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: SizeConfig.screenHeight * 0.05),
                            buildPasswordFormField(
                                label: "New password",
                                hint: "Enter new password",
                                controller: newPasswordController),
                            SizedBox(height: SizeConfig.screenHeight * 0.03),
                            buildPasswordFormField(
                                label: "Confirm password",
                                hint: "Confirm new password",
                                controller: confirmPasswordController),
                            SizedBox(height: SizeConfig.screenHeight * 0.04),
                            DefaultButton(
                              text: "Change",
                              press: changePassword,
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
            ),
          );
  }

  void changePassword() async {
    try {
      if (newPasswordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty) {
        Fluttertoast.showToast(msg: "Please fill all fields!");
      } else if (newPasswordController.text != confirmPasswordController.text) {
        Fluttertoast.showToast(msg: "Passwords do not match!");
      } else if (newPasswordController.text.length < 6 &&
          confirmPasswordController.text.length < 6) {
        Fluttertoast.showToast(
            msg: "Password must be at least 6 characters long or more!");
      } else {
        await EasyLoading.show(status: 'Changing password...');
        String res = await AuthMethods().updatePassword(
            newPassword: newPasswordController.text,
            confirmPassword: confirmPasswordController.text);

        EasyLoading.dismiss();

        Fluttertoast.showToast(msg: "Successfully changed password!");
        newPasswordController.clear();
        confirmPasswordController.clear();
        Navigator.pushNamed(context, MainScreen.id);
      }

      // Navigator.of(context).pushReplacement(MaterialPageRoute(
      //     builder: (context) =>
      //        MainScreen);
    } catch (err) {
      print(err.toString);
    }
  }
}
