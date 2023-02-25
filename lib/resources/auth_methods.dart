import 'dart:typed_data';
import 'package:auth/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instaid_dev/models/user_model.dart' as model;
import 'package:instaid_dev/resources/firestore_methods.dart';
import 'package:instaid_dev/resources/storage_methods.dart';

String contactslistdata = '[]';
String? bloodType;
String? allergies;
String? diseases;
int? auth_age;
String? weight;
String? height;
String? birthDay;

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

class AuthMethods {
  // get user details
  Future<model.UserModel> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('user').doc(auth.currentUser?.uid).get();

    return model.UserModel.fromSnap(documentSnapshot);
  }

  Future<String> signUpUser({
    required String firstName,
    required String lastName,
    required String email,
    required String? birthDay,
    required String phoneNumber,
    required String password,
    required Uint8List profilePicture,
    required Uint8List validID,
    int? age,
  }) async {
    String res = "Some error Occurred";
    try {
      // UserCredential cred = await _auth.createUserWithEmailAndPassword(
      //   email: email,
      //   password: password,
      // );
      String uid = FirebaseAuth.instance.currentUser!.uid;
      String photoUrl = await StorageMethods()
          .uploadImageToStorage('profilePics', profilePicture, false);

      String validId = await StorageMethods()
          .uploadImageToStorage('validIds', validID, false);

      model.UserModel _user = model.UserModel(
        userID: uid,
        // userID: cred.user!.uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        photoUrl: photoUrl,
        validId: validId,
        phoneNumber: phoneNumber,
        age: age,
        birthDay: birthDay,
        bloodType: '',
        height: 0,
        weight: 0,
        allergies: '',
        diseases: '',
        contactslistdata: '',
      );

      await _firestore.collection("user").doc(uid).set(_user.toJson());

      res = "success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-exists') {
        Fluttertoast.showToast(msg: "This email is already in use!");
        print("This email is already in use!");
      } else if (e.code == 'phone-number-already-exists') {
        Fluttertoast.showToast(
            msg:
                "The provided phoneNumber is already in use by an existing user.");
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      res = "success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Fluttertoast.showToast(msg: "No user found for that email.");
      } else if (e.code == 'wrong-password') {
        Fluttertoast.showToast(msg: "Wrong password!");
      }
    } catch (e) {
      print(e);
    }

    return res;
  }

  Future<void> logOutUser() async {
    await _auth.signOut();
  }

  Future<String> updateEmail({required String email}) async {
    String res = "Some error occurred";
    try {
      await currentUser.updateEmail(email);
      await _firestore.collection('user').doc(auth.currentUser?.uid).update({
        'email': email,
      });
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> updatePassword(
      {required String newPassword, required String confirmPassword}) async {
    String res = "Some error occurred";
    try {
      await currentUser.updatePassword(newPassword);
    } catch (err) {
      return err.toString();
    }
    return res;
  }
}
