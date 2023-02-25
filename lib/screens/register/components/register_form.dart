// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:instaid_dev/components/card_picture.dart';
import 'package:instaid_dev/components/default_button.dart';
import 'package:instaid_dev/components/existing_account.dart';
import 'package:instaid_dev/constants.dart';
import 'package:instaid_dev/screens/otp/otp.dart';
import 'package:instaid_dev/utils/keyboard_dismiss_detector.dart';
import 'package:intl/intl.dart';
import 'package:instaid_dev/screens/login/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instaid_dev/utils/colors.dart';
import 'package:image_picker/image_picker.dart';

import 'package:instaid_dev/size_config.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../components/custom_suffix_icon.dart';
import '../../../models/user_info.dart';
import '../../../resources/auth_methods.dart';
import '../../../utils/utils.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String? imagePath;
  String? email;
  String? password;
  String? firstName;
  String? lastName;
  String? phoneNumber;

  Uint8List? _image;
  Uint8List? _validIDImage;
  String? errorMessage;

  DateTime? selectBirthday;
  DateTime selectedDate = DateTime.now();
  String? formattedBirthday;
  var dateDifference;
  var age;
  bool _obscureText = true;

  final firstNameEditingController = TextEditingController();
  final lastNameEditingController = TextEditingController();
  final emailEditingController = TextEditingController();
  final passwordEditingController = TextEditingController();
  final phoneNumberEditingController = TextEditingController();
  TextEditingController birthDayController = TextEditingController();
  final UserInfoData _userInfo = Get.put(UserInfoData());
  bool _isLoading = false;

  final List<String> errors = [];

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  selectValidID() async {
    Uint8List viD = await pickImage(ImageSource.gallery);
    setState(() {
      _validIDImage = viD;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return KeyboardDismissDetector(
        child: Form(
      key: _formKey,
      child: Column(
        children: [
          buildAvatar(),
          SizedBox(height: getProportionateScreenHeight(25)),
          buildFNameFormField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildLNameFormField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildBirthdayFormField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildEmailFormField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildPNoFormField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildValidID(),
          SizedBox(height: getProportionateScreenHeight(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  showListValidID();
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 11),
                  child: Text("List of Valid ID",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: getProportionateScreenWidth(14),
                          color: primaryColor)),
                ),
              ),
            ],
          ),
          SizedBox(height: getProportionateScreenHeight(20)),
          DefaultButton(
              text: "Next",
              press: () {
                register();
                // Navigator.pushNamed(
                //   context,
                //   OTPScreen.id,
                //   arguments: phoneNumber,
                // );
              }),
          SizedBox(height: SizeConfig.screenHeight * 0.02),
          ExistingAccount(),
          // ElevatedButton(
          //   onPressed: register,
          //   child: Text('Register'),
          //   style: ElevatedButton.styleFrom(
          //       shadowColor: Colors.green,
          //       shape: StadiumBorder(),
          //       padding: EdgeInsets.symmetric(horizontal: 35, vertical: 20)),
          // ),
        ],
      ),
    ));
  }

  showListValidID() {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: primaryBackground,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  17.0,
                ),
              ),
            ),
            contentPadding: const EdgeInsets.all(
              20.0,
            ),
            title: Text(
              "We accept the following valid IDs",
              style: TextStyle(
                  color: textColorBlack,
                  fontSize: getProportionateScreenHeight(21),
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              width: 400,
              height: 180,
              child: Stack(children: [
                Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Senior Citizen ID"),
                        Text("Passport"),
                        Text("Driver’s License"),
                        Text("PRC ID"),
                        Text("National ID"),
                        Text("UMID ID"),
                        Text("Philhealth ID"),
                        Text("Philhealth ID"),
                        Text("Voter's ID"),
                        Text("Tin ID"),
                      ],
                    ),
                ),
              ]), //SizeConfig.sc
            ),
          );
        });
  }

  Stack buildAvatar() {
    return Stack(
      children: [
        _image != null
            ? CircleAvatar(
                radius: 45,
                backgroundImage: MemoryImage(_image!),
                backgroundColor: primaryColor,
              )
            : const CircleAvatar(
                radius: 45,
                backgroundImage:
                    NetworkImage('https://i.stack.imgur.com/l60Hf.png'),
                backgroundColor: primaryColor,
              ),
        Positioned(
          bottom: -5,
          left: 50,
          child: IconButton(
            onPressed: selectImage,
            icon: const Icon(Icons.add_a_photo),
          ),
        )
      ],
    );
  }

  Stack buildValidID() {
    return Stack(
      children: [
        _validIDImage != null
            ? Stack(
                children: [
                  CardPicture(
                    backgroundImage: MemoryImage(_validIDImage!),
                  ),
                  Positioned(
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(3.0, 3.0),
                              blurRadius: 2.0,
                            )
                          ]),
                      child: IconButton(
                          onPressed: () {
                            setState(() {
                              _validIDImage = null;
                            });
                          },
                          icon: Icon(Icons.close, color: Colors.white)),
                    ),
                  )
                ],
              )
            : CardPicture(onTap: selectValidID, cardLabel: "Attach valid ID"),
      ],
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: _obscureText,
      controller: passwordEditingController,
      onSaved: (value) {
        passwordEditingController.text = value!;
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
      controller: emailEditingController,
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => email = newValue,
      decoration: InputDecoration(
          labelText: "Email",
          hintText: "Enter your email",
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding: EdgeInsets.symmetric(horizontal: 42, vertical: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: textColorGray),
            gapPadding: 10,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: textColorGray),
            gapPadding: 10,
          )),
    );
  }

  TextFormField buildPhoneNumberField() {
    return TextFormField();
  }

  IntlPhoneField buildPNoFormField() {
    return IntlPhoneField(
      controller: phoneNumberEditingController,

      autofocus: true,
      //invalidNumberMessage: 'Invalid Phone Number!',
      textAlignVertical: TextAlignVertical.center,
      onChanged: (phone) => phoneNumber = phone.completeNumber,
      initialCountryCode: 'PH',
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
          labelText: "Phone Number",
          hintText: "Enter your phone number",
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding: EdgeInsets.symmetric(horizontal: 42, vertical: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: textColorGray),
            gapPadding: 10,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: textColorGray),
            gapPadding: 10,
          )),
      // keyboardType: TextInputType.number,
      // onSaved: (newValue) => phoneNumber = newValue,
      // onChanged: (value) {
      //   if (value.isNotEmpty) {
      //     removeError(error: txtPhoneNoNull);
      //   }
      //   return null;
      // },
      // validator: (value) {
      //   if (value!.isEmpty) {
      //     addError(error: txtPhoneNoNull);
      //   }
      //   return null;
      // },
    );
  }

  TextFormField buildLNameFormField() {
    return TextFormField(
      controller: lastNameEditingController,
      keyboardType: TextInputType.name,
      onSaved: (newValue) => lastName = newValue,
      decoration: InputDecoration(
          labelText: "Last Name",
          hintText: "Enter your last name",
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding: EdgeInsets.symmetric(horizontal: 42, vertical: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: textColorGray),
            gapPadding: 10,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: textColorGray),
            gapPadding: 10,
          )),
    );
  }

  TextFormField buildFNameFormField() {
    return TextFormField(
      controller: firstNameEditingController,
      keyboardType: TextInputType.name,
      onSaved: (newValue) => firstName = newValue,
      decoration: InputDecoration(
          labelText: "First Name",
          hintText: "Enter your first name",
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding: EdgeInsets.symmetric(horizontal: 42, vertical: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: textColorGray),
            gapPadding: 10,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: textColorGray),
            gapPadding: 10,
          )),
    );
  }

  TextFormField buildBirthdayFormField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      controller: birthDayController,
      onTap: () async {
        selectBirthday = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(1900),
          lastDate: DateTime(2023),
        );

        if (selectBirthday != null && selectBirthday != selectedDate) {
          setState(() {
            selectedDate = selectBirthday!;
            dateDifference = DateTime.now().difference(selectedDate).inDays;
            age = dateDifference ~/ 365;
            auth_age = age;

            formattedBirthday = DateFormat.yMMMMd('en_US').format(selectedDate);
            birthDay = formattedBirthday;
            // updateAge();
            // updateBirthDay();
          });
        }
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: "Birthday",
        hintText: "${selectedDate.toLocal()}".split(' ')[0],
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: EdgeInsets.symmetric(horizontal: 42, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: textColorGray),
          gapPadding: 5,
        ),
      ),
    );
  }

  Future<String?> register() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // new regex (([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$
      bool emailValid = RegExp(
              r'(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
          .hasMatch(emailEditingController.text);
      if (firstNameEditingController.text.isEmpty ||
          lastNameEditingController.text.isEmpty ||
          emailEditingController.text.isEmpty ||
          phoneNumberEditingController.text.isEmpty ||
          passwordEditingController.text.isEmpty) {
        Fluttertoast.showToast(msg: "Please fill all fields!");
      } else if (_image == null || _validIDImage == null) {
        Fluttertoast.showToast(msg: "Please select image!");
      } else if (!emailValid) {
        Fluttertoast.showToast(msg: "Please enter a valid email!");
      } else if (auth_age! < 18) {
        Fluttertoast.showToast(
            msg: "You must be 18 years old or above to register!");
      } else {
        bool isEmailExist;
        bool isMobileExist;
        try {
          var getCollection = FirebaseFirestore.instance
              .collection('user')
              .where('email', isEqualTo: emailEditingController.text);
          var fetchData = await getCollection.get();
          print('email get  ${fetchData.docs[0]['email']}');
          isEmailExist = true;
        } catch (e) {
          isEmailExist = false;

          print('email not exist');
        }
        try {
          var getCollection = FirebaseFirestore.instance
              .collection('user')
              .where('phoneNumber', isEqualTo: phoneNumber);
          var fetchData = await getCollection.get();
          print('mobile get  ${fetchData.docs[0]['phoneNumber']}');
          isMobileExist = true;
        } catch (e) {
          isMobileExist = false;

          print('mobile not exist');
        }
        if (isMobileExist == false && isEmailExist == false) {
          await EasyLoading.show(status: 'Registering...');
          // String res = await AuthMethods().signUpUser(
          //     firstName: firstNameEditingController.text,
          //     lastName: lastNameEditingController.text,
          //     email: emailEditingController.text,
          //     phoneNumber: phoneNumberEditingController.text,
          //     password: passwordEditingController.text,
          //     birthDay: birthDay,
          //     age: auth_age,
          //     profilePicture: _image!,
          //     validID: _validIDImage!);
          // if (res == "success") {
          //   setState(() {
          //     _isLoading = false;
          //   });
          // ignore: use_build_context_synchronously

          _userInfo.firstName = firstNameEditingController.text;
          _userInfo.lastName = lastNameEditingController.text;
          _userInfo.email = emailEditingController.text;
          _userInfo.phoneNumber = phoneNumber;
          _userInfo.password = passwordEditingController.text;
          _userInfo.birthDay = birthDay!;
          _userInfo.age = auth_age!;
          _userInfo.profilePicture = _image!;
          _userInfo.validID = _validIDImage!;

          //Navigator.push(context, MaterialPageRoute(builder: (context) => OTPScreen(),));
          Navigator.pushNamed(
            context,
            OTPScreen.id,
            // arguments:
            //   '${'+91' + phoneNumberEditingController.text.toString()}',
            arguments: phoneNumber,
          );
          await EasyLoading.dismiss();
          _isLoading = false;

          // } else {
          //   setState(() {
          //     _isLoading = false;
          //   });
          // }
        } else {
          if (isEmailExist) {
            Fluttertoast.showToast(msg: "This email is already in use!");
          } else {
            Fluttertoast.showToast(msg: "This phone number is already in use!");
          }
        }
      }
    } catch (err) {
      return err.toString();
    }
    return null;
  }
}
