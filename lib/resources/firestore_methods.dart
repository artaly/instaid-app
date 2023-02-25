import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instaid_dev/models/contacts.dart';
import 'package:instaid_dev/models/user_help.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instaid_dev/models/user_model.dart';
import 'package:instaid_dev/models/user_report.dart';
import 'package:instaid_dev/resources/storage_methods.dart';

import 'package:uuid/uuid.dart';

List<ContactsData> contactslist = [];
String contactslistdata = '[]';
String? bloodType;
String? allergies;
String? diseases;
int? auth_age;
String? weight;
String? height;
String? birthDay;

final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

User currentUser = auth.currentUser!;

Future<void> updateAllergies({required String allergies}) async {
  await _firestore.collection('user').doc(auth.currentUser?.uid).update({
    'allergies': allergies,
  });
}

Future<void> updateDiseases({required String diseases}) async {
  await _firestore.collection('user').doc(auth.currentUser?.uid).update({
    'diseases': diseases,
  });
}

Future<void> updateContactList() async {
  await _firestore.collection('user').doc(auth.currentUser?.uid).update({
    'contactslistdata': contactslistdata,
  });
}

Future<void> updateBloodType({required String bloodTypeNew}) async {
  await _firestore.collection('user').doc(auth.currentUser?.uid).update({
    'bloodType': bloodType,
  });
}

Future<void> updateWeight({required String weight}) async {
  await _firestore.collection('user').doc(auth.currentUser?.uid).update({
    'weight': weight,
  });
}

Future<String> updateHeight({required String height}) async {
  await _firestore.collection('user').doc(auth.currentUser?.uid).update({
    'height': height,
  });
  return 'Successfully changed height';
}

void updatePrefs() {
  UserPref.pref.setString('bloodType', bloodType ?? '');
  UserPref.pref.setString('diseases', diseases ?? '');
  UserPref.pref.setString('allergies', allergies ?? '');
  UserPref.pref.setString('weight', weight ?? '');
  UserPref.pref.setString('height', height ?? '');
  UserPref.pref.setString('contactsData', contactslistdata);
}

class FireStoreMethods {
  Future<String> submitReport({
    required String help_type,
    required Timestamp time_of_occurence,
    required String location,
    required double? longitude,
    required double latitude,
    required String status,
    required String uid,
    required Uint8List reportPhotoUrl,
    required String? reportTitle,
    required String? remarks,
  }) async {
    String res = "Some error Occurred";
    String photoUrl = await StorageMethods()
        .uploadImageToStorage('incidentPics', reportPhotoUrl, false);

    try {
      String helpID = const Uuid().v1();
      UserReport userReport = UserReport(
        help_type: help_type,
        time_of_occurence: time_of_occurence,
        location: location,
        longitude: longitude,
        status: status,
        latitude: latitude,
        uid: uid,
        reportPhotoUrl: photoUrl,
        reportTitle: reportTitle,
        remarks: remarks,
      );

      await _firestore
            .collection("dispatch_emergency")
            .doc(helpID)
            .set(userReport.toJson());


      // help_type.forEach((item) async {
      //   if (item.contains("Police")) {
      //     await _firestore
      //         .collection("police_reports")
      //         .doc(helpID)
      //         .set(userReport.toJson());
      //   } else if (item.contains("Rescue")) {
      //     await _firestore
      //         .collection("rescue_reports")
      //         .doc(helpID)
      //         .set(userReport.toJson());
      //   } else if (item.contains("Fire")) {
      //     await _firestore
      //         .collection("fire_reports")
      //         .doc(helpID)
      //         .set(userReport.toJson());
      //   } else if (item.contains("Medical")) {
      //     await _firestore
      //         .collection("medical_reports")
      //         .doc(helpID)
      //         .set(userReport.toJson());
      //   }
      // });

      res = "success";
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<String> submitHelp({
    required String help_type,
    required Timestamp time_of_occurence,
    required String location,
    required double longitude,
    required double latitude,
    required String status,
    required String uid,
  }) async {
    String res = "Some error Occurred";
    try {
      String helpID = const Uuid().v1();
      UserHelp userHelp = UserHelp(
        help_type: help_type,
        time_of_occurence: time_of_occurence,
        location: location,
        longitude: longitude,
        status: status,
        latitude: latitude,
        uid: uid,
      );

      await _firestore
            .collection("dispatch_emergency")
            .doc(helpID)
            .set(userHelp.toJson());

      // if (help_type == "Police") {
      //   await _firestore
      //       .collection("police_emergency")
      //       .doc(helpID)
      //       .set(userHelp.toJson());
      // } else if (help_type == "Fire") {
      //   await _firestore
      //       .collection("fire_emergency")
      //       .doc(helpID)
      //       .set(userHelp.toJson());
      // } else if (help_type == "Medical") {
      //   await _firestore
      //       .collection("medical_emergency")
      //       .doc(helpID)
      //       .set(userHelp.toJson());
      // } else if (help_type == "Rescue") {
      //   await _firestore
      //       .collection("rescue_emergency")
      //       .doc(helpID)
      //       .set(userHelp.toJson());
      // }

      res = "success";
    } catch (err) {
      return err.toString();
    }
    return res;
  }
}
