import 'dart:typed_data';

import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:instaid_dev/components/bezierContainer.dart';
import 'package:instaid_dev/components/custom_loader.dart';
import 'package:instaid_dev/constants.dart';
import 'package:instaid_dev/resources/firestore_methods.dart';
import 'package:instaid_dev/screens/main_screen.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:instaid_dev/size_config.dart';
import 'package:instaid_dev/utils/colors.dart';
import 'package:instaid_dev/utils/utils.dart';

import '../../components/pin_input_field.dart';
import '../../models/user_info.dart';
import '../../resources/auth_methods.dart';

class OTPScreen extends StatefulWidget {
  static const id = 'OTPScreen';
  final String? phoneNumber;

  const OTPScreen({
    Key? key,
    this.phoneNumber,
  }) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> with WidgetsBindingObserver {
  final UserInfoData _userInfo = Get.put(UserInfoData());
  bool isKeyboardVisible = false;
  String _code = "";
  late final ScrollController scrollController;

  @override
  void initState() {
    scrollController = ScrollController();
    WidgetsBinding.instance.addObserver(this);
    _listenSmsCode();
    _getSignature();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scrollController.dispose();
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomViewInsets = WidgetsBinding.instance.window.viewInsets.bottom;
    isKeyboardVisible = bottomViewInsets > 0;
  }

  _listenSmsCode() async {
    await SmsAutoFill().listenForCode();
  }

  _getSignature() async {
    final String signature = await SmsAutoFill().getAppSignature;
    print("Signature: $signature");
  }

  // scroll to bottom of screen, when pin input field is in focus.
  Future<void> _scrollToBottomOnKeyboardOpen() async {
    while (!isKeyboardVisible) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    await Future.delayed(const Duration(milliseconds: 250));

    if (scrollController.hasClients) {
      await scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('widget phoneNumber  ${widget.phoneNumber}');
    final height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: FirebasePhoneAuthHandler(
        phoneNumber: widget.phoneNumber!,
        signOutOnSuccessfulVerification: false,
        linkWithExistingUser: true,
        autoRetrievalTimeOutDuration: const Duration(seconds: 60),
        otpExpirationDuration: const Duration(seconds: 60),
        onCodeSent: () async {
          Fluttertoast.showToast(msg: 'OTP sent!');
          log(OTPScreen.id, msg: 'OTP sent!');
        },
        onLoginSuccess: (userCredential, autoVerified) async {
          log(
            OTPScreen.id,
            msg: autoVerified
                ? 'OTP was fetched automatically!'
                : 'OTP was verified manually!',
          );

          print('enter sucesss');
          try {
            String res = await AuthMethods().signUpUser(
                firstName: _userInfo.firstName!,
                lastName: _userInfo.lastName!,
                email: _userInfo.email!,
                phoneNumber: _userInfo.phoneNumber!,
                password: _userInfo.password!,
                birthDay: _userInfo.birthDay,
                age: _userInfo.age,
                profilePicture: _userInfo.profilePicture!,
                validID: _userInfo.validID!);
            Navigator.pushNamedAndRemoveUntil(
              context,
              MainScreen.id,
              (route) => false,
            );
          } catch (e) {
            print('instaid id id ');
          }
        },
        onLoginFailed: (authException, stackTrace) {
          log(
            OTPScreen.id,
            msg: authException.message,
            error: authException,
            stackTrace: stackTrace,
          );

          switch (authException.code) {
            case 'invalid-phone-number':
              return showSnackBar(context, 'Invalid phone number!');
            case 'invalid-verification-code':
              return showSnackBar(context, 'The entered OTP is invalid!');
            case 'too-many-requests':
              Navigator.pop(context);
              return showSnackBar(context,
                  'We have blocked all requests from this device due to unusual activity. Try again later');
            default:
              print("an error occured!");
          }
        },
        onError: (error, stackTrace) {
          log(
            OTPScreen.id,
            error: error,
            stackTrace: stackTrace,
          );
        },
        builder: (context, controller) {
          return Scaffold(
              backgroundColor: primaryBackground,
              body: controller.isSendingCode
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        CustomLoader(),
                        SizedBox(height: 50),
                        Center(
                          child: Text(
                            'Sending OTP',
                            style: TextStyle(fontSize: 25),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      height: height,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                              top: -height * .28,
                              right: -MediaQuery.of(context).size.width * .4,
                              child: const BezierContainer()),
                          Container(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: getProportionateScreenWidth(20)),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    SizedBox(
                                        height: SizeConfig.screenHeight * 0.1),
                                    Text(
                                      "OTP Verification",
                                      style: headingStyle,
                                    ),
                                    Text(
                                        "We sent your code to ${widget.phoneNumber}"),
                                    const SizedBox(height: 0.5),
                                    if (controller.codeSent)
                                      TextButton(
                                        onPressed: controller.isOtpExpired
                                            ? () async {
                                                log(OTPScreen.id,
                                                    msg: 'Resend OTP');

                                                await controller.sendOTP();
                                              }
                                            : null,
                                        child: Text(
                                          controller.isOtpExpired
                                              ? "Resend OTP Code"
                                              : "This code will expire in ${controller.otpExpirationTimeLeft.inSeconds}s",
                                          style: const TextStyle(
                                              color: primaryColor),
                                        ),
                                      ),
                                    const SizedBox(width: 5),
                                    if (controller
                                        .isListeningForOtpAutoRetrieve)
                                      Column(
                                        children: const [
                                          CustomLoader(),
                                          SizedBox(height: 50),
                                          Text(
                                            'Listening for OTP',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: textColorBlack,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 15),
                                          Divider(),
                                          Text('OR',
                                              textAlign: TextAlign.center),
                                          Divider(),
                                        ],
                                      ),
                                    const SizedBox(height: 15),
                                    PinInputField(
                                      length: 6,
                                      onFocusChange: (hasFocus) async {
                                        if (hasFocus)
                                          await _scrollToBottomOnKeyboardOpen();
                                      },
                                      onSubmit: (enteredOtp) async {
                                        print('otp   ${enteredOtp}');
                                        UserCredential cred = await FirebaseAuth
                                            .instance
                                            .createUserWithEmailAndPassword(
                                          email: _userInfo.email!,
                                          password: _userInfo.password!,
                                        );
                                        final verified = await controller
                                            .verifyOtp(enteredOtp);
                                        if (verified) {
                                          // number verify success
                                          // will call onLoginSuccess handler
                                        } else {
                                          // phone verification failed
                                          // will call onLoginFailed or onError callbacks with the error
                                        }
                                      },
                                    ),
                                    // PinFieldAutoFill(
                                    //   codeLength: 6,
                                    //   currentCode: _code,
                                    //   onCodeChanged: (code) => {
                                    //     setState(() {
                                    //       _code = code.toString();
                                    //     })
                                    //   },
                                    //   onCodeSubmitted: (code) async {
                                    //     print('otp   ${code}');
                                    //     UserCredential cred = await FirebaseAuth
                                    //         .instance
                                    //         .createUserWithEmailAndPassword(
                                    //       email: _userInfo.email!,
                                    //       password: _userInfo.password!,
                                    //     );
                                    //     final verified =
                                    //         await controller.verifyOtp(code);
                                    //     if (verified) {
                                    //     } else {}
                                    //   },
                                    // ),
                                    SizedBox(
                                        height: SizeConfig.screenHeight * 0.1),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ));
        },
      ),
    );
  }
}
