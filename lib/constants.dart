import 'package:flutter/material.dart';
import 'package:instaid_dev/utils/colors.dart';

import 'size_config.dart';
// For form errors

const String txtEmailNullErr = "Please enter your email";
const String txtInvalidEmailErr = "Please enter valid email";
const String txtPassNullErr = "Please enter your password";
final RegExp emailValidatorRegExp =
    RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
const String txtWrongPassword = "Wrong password";
const String txtNotMatchPw = "Password does not match";
const String txtPasswordShort = "Password too short";
const String txtNameNull = "Please enter your name";
const String txtPhoneNoNull = "Please enter your phone number";
const String txtAddressNull = "Please enter your address";

final headingStyle = TextStyle(
    fontSize: getProportionateScreenWidth(28),
    fontWeight: FontWeight.bold,
    color: Colors.black,
    height: 1.5);

final otpInputDecoration = InputDecoration(
  contentPadding:
      EdgeInsets.symmetric(vertical: getProportionateScreenWidth(15)),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
    borderSide: BorderSide(color: textColorGray),
  );
}
