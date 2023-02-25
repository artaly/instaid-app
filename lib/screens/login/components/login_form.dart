// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:instaid_dev/components/custom_suffix_icon.dart';
import 'package:instaid_dev/components/default_button.dart';
import 'package:instaid_dev/components/form_error.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instaid_dev/main.dart';
import 'package:instaid_dev/models/user_model.dart';
import 'package:instaid_dev/screens/login/forgot_password.dart';
import 'package:instaid_dev/screens/login/login.dart';
import 'package:instaid_dev/screens/main_screen.dart';
import 'package:instaid_dev/screens/otp/otp.dart';
import 'package:instaid_dev/size_config.dart';
import 'package:instaid_dev/constants.dart';
import 'package:instaid_dev/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../resources/auth_methods.dart';
import '../../../utils/utils.dart';
import '../../home/home.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  String? errorMessage;
  bool _obscureText = true;

  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  bool _isLoading = false;

  final List<String> errors = [];
  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: [
        buildEmailFormField(),
        SizedBox(
          height: getProportionateScreenHeight(20),
        ),
        buildPasswordFormField(),
        SizedBox(
          height: getProportionateScreenHeight(15),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Opacity(
              opacity: 0,
              child: Icon(Icons.arrow_forward),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, ForgotPassword.id),
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  "Forgot password?",
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: textColorBlack),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: getProportionateScreenHeight(15),
        ),
        // Row(
        //   children: [
        //     Checkbox(
        //       value: remember,
        //       activeColor: primaryColor,
        //       onChanged: (value) {
        //         setState(() {
        //           remember = value;
        //         });
        //       },
        //     ),
        //     Text(
        //       "Remember me",
        //       style: TextStyle(
        //         color: textColorBlack,
        //       ),
        //     ),
        //     Spacer(),

        //   ],
        // ),
        //SizedBox(height: SizeConfig.screenHeight * 0.02),
        DefaultButton(
          text: "Login",
          press: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('email', emailController.text);
            loginUser();
          },
        ),
      ]),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: _obscureText,
      controller: passwordController,
      onSaved: (value) {
        passwordController.text = value!;
      },
      onChanged: (value) {
        if (value.isNotEmpty && errors.contains(txtPassNullErr)) {
          // setState(() {
          //   errors.remove(txtPassNullErr);
          // });
          // } else if (!emailValidatorRegExp.hasMatch(value) &&
          //     !errors.contains(txtInvalidEmailErr)) {
          //   setState(() {
          //     errors.add(txtInvalidEmailErr);
          //   });
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty && errors.contains(txtPassNullErr)) {
          // setState(() {
          //   errors.add(txtPassNullErr);
          // });
          return (txtPassNullErr);
        } else if (!emailValidatorRegExp.hasMatch(value) &&
            !errors.contains(txtInvalidEmailErr)) {
          // setState(() {
          //   errors.add(txtInvalidEmailErr);
          // });
        }

        return null;
      },
      decoration: InputDecoration(
          labelText: "Password",
          hintText: "Enter your password",
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

  TextFormField buildEmailFormField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      controller: emailController,
      onSaved: (value) {
        emailController.text = value!;
      },
      onChanged: (value) {
        if (value.isNotEmpty && errors.contains(txtEmailNullErr)) {
          // setState(() {
          //   errors.remove(txtEmailNullErr);
          // });
        } else if (emailValidatorRegExp.hasMatch(value) &&
            errors.contains(txtInvalidEmailErr)) {
          // setState(() {
          //   errors.remove(txtInvalidEmailErr);
          // });
        }

        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          // setState(() {
          //   errors.add(txtEmailNullErr);
          // });
          return (txtEmailNullErr);
        } else if (!emailValidatorRegExp.hasMatch(value) &&
            !errors.contains(txtInvalidEmailErr)) {
          // setState(() {
          //   errors.add(txtInvalidEmailErr);
          // });
        }

        return null;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          labelText: "Email",
          hintText: "Enter your email",
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

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        Fluttertoast.showToast(msg: "Please fill all required fields!");
      } else {
        String res = await AuthMethods().loginUser(
            email: emailController.text, password: passwordController.text);
        if (res == 'success') {
          await EasyLoading.show(status: 'Logging in...');
          //Navigator.pushNamed(context, MainScreen.routeName);
          UserPref.pref.setString('email', 'useremail@gmail.com');
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (BuildContext ctx) => MainScreen()));
          EasyLoading.dismiss();
          setState(() {
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error: " + e.toString());
    }
  }
}
