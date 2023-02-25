import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../email_change/body.dart';

class ChangeEmail extends StatefulWidget {
  static const id = 'ChangeEmail';
  const ChangeEmail({Key? key}) : super(key: key);

  @override
  State<ChangeEmail> createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(uid: FirebaseAuth.instance.currentUser!.uid),
    );
  }
}
