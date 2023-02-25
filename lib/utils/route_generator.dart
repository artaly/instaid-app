import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instaid_dev/screens/contacts/contacts.dart';
import 'package:instaid_dev/screens/contacts/hotline_list.dart';
import 'package:instaid_dev/screens/home/components/pin_location.dart';
import 'package:instaid_dev/screens/home/home.dart';
import 'package:instaid_dev/screens/login/forgot_password.dart';
import 'package:instaid_dev/screens/login/login.dart';
import 'package:instaid_dev/screens/main_screen.dart';
import 'package:instaid_dev/screens/otp/otp.dart';
import 'package:instaid_dev/screens/profile/account/email_change/change_email.dart';
import 'package:instaid_dev/screens/profile/account/password_change/change_password.dart';
import 'package:instaid_dev/screens/profile/profile.dart';
import 'package:instaid_dev/screens/profile/profile_bottom_sheet.dart';
import 'package:instaid_dev/screens/register/register.dart';

class RouteGenerator {
  static const _id = 'RouteGenerator';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as dynamic;
    switch (settings.name) {
      case LoginScreen.id:
        return _route(const LoginScreen());
      case ChangeEmail.id:
        return _route(const ChangeEmail());
      case ChangePassword.id:
        return _route(const ChangePassword());
      case ForgotPassword.id:
        return _route(const ForgotPassword());
      case RegisterScreen.id:
        return _route(const RegisterScreen());
      case ViewProfile.id:
        return _route(ViewProfile(uid: FirebaseAuth.instance.currentUser!.uid));
      case MainScreen.id:
        return _route(const MainScreen());
      case OTPScreen.id:
        return _route(OTPScreen(phoneNumber: args));
      case HotlineList.id:
        return _route(const HotlineList());
      case PinLocation.id:
        return _route(PinLocation());
      case HomeScreen.id:
        return _route(HomeScreen(uid: FirebaseAuth.instance.currentUser!.uid));
      case ProfileScreen.id:
        return _route(
            ProfileScreen(uid: FirebaseAuth.instance.currentUser!.uid));
      case ContactScreen.id:
        return _route(const ContactScreen());
      default:
        return _errorRoute(settings.name);
    }
  }

  static MaterialPageRoute _route(Widget widget) =>
      MaterialPageRoute(builder: (context) => widget);

  static Route<dynamic> _errorRoute(String? name) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text('ROUTE \n\n$name\n\nNOT FOUND'),
        ),
      ),
    );
  }
}
