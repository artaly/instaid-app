import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instaid_dev/resources/auth_methods.dart';
import 'package:instaid_dev/screens/login/login.dart';
import 'package:instaid_dev/screens/profile/account/email_change/change_email.dart';
import 'package:instaid_dev/screens/profile/account/password_change/change_password.dart';
import 'package:instaid_dev/screens/profile/profile_widget.dart';
import 'package:instaid_dev/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../../size_config.dart';
import '../../utils/utils.dart';

class ProfileScreen extends StatefulWidget {
  static const id = 'ProfileScreen';

  final String uid;

  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = false;
  var userData = {};
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            body: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 40),
                ProfileWidget(
                  imagePath: userData['photoUrl'],
                  onClicked: () async {},
                ),
                const SizedBox(height: 24),
                buildName(),
                const SizedBox(height: 25),
                buildProfileButtons(
                  icon: Icons.mail_outline,
                  text: "Change Email",
                  press: () => Navigator.pushNamed(context, ChangeEmail.id),
                ),
                buildProfileButtons(
                  icon: Icons.password_outlined,
                  text: "Change Password",
                  press: () => Navigator.pushNamed(context, ChangePassword.id),
                ),
                buildProfileButtons(
                  icon: Icons.info_outline,
                  text: "About us",
                  press: ()=>showAboutAlert(),
                ),
                buildProfileButtons(
                  icon: Icons.logout_outlined,
                  text: "Logout",
                  press:() async {
                    UserPref.pref = await SharedPreferences.getInstance();
                    UserPref.pref.remove('bloodType');
                    signout();
                  },
                ),
              ],
            ),
          );
  }

  showAboutAlert() {
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
              "About us",
              style: TextStyle(
                  color: textColorBlack,
                  fontSize: getProportionateScreenHeight(21),
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              width: 400,
              child: Stack(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "    InstAID is a proposed Android-based emergency response mobile application with the main goal of providing estimated to precise, real-time location to the local emergency responders using geolocation for immediate emergency response to the community San Jose.",
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: getProportionateScreenHeight(15),
                      color: primaryDark,
                    ),
                  ),
                )
              ]), //SizeConfig.sc
            ),
          );
        });
  }

  Widget buildName() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            userData['firstName'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
          const Text(
            ' ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          Text(
            userData['lastName'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
        ],
      );

  signout() async {
    await _auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) => const LoginScreen(),
      ),
      (Route route) => false,
    );
  }
}

class buildProfileButtons extends StatelessWidget {
  const buildProfileButtons({
    Key? key,
    required this.text,
    required this.icon,
    required this.press,
  }) : super(key: key);

  final String text;
  final IconData icon;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      child: TextButton(
        onPressed: (){press();},
        child: Row(
          children: [
            Icon(
              icon,
              color: primaryColor,
              size: getProportionateScreenWidth(17),
            ),
            // SvgPicture.asset(
            //   icon,
            //   width: getProportionateScreenWidth(17),
            //   color: primaryColor,
            // ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                    color: textColorBlack,
                    fontSize: SizeConfig.screenHeight * 0.0173),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_outlined, color: textColorGray),
          ],
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
