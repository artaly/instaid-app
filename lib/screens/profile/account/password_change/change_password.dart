import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import '../password_change/body.dart';

class ChangePassword extends StatefulWidget {
  static const id = 'ChangePassword';
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(uid: FirebaseAuth.instance.currentUser!.uid),
    );
  }
}
