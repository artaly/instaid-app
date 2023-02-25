import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  final String userID;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? photoUrl;
  final String? validId;
  final int? age;
  final String? birthDay;
  final String? bloodType;
  final double? height;
  final double? weight;
  final String? allergies;
  final String? diseases;
  final String? contactslistdata;

  const UserModel({
    required this.userID,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.photoUrl,
    required this.validId,
    required this.age,
    required this.birthDay,
    required this.bloodType,
    required this.height,
    required this.weight,
    required this.allergies,
    required this.diseases,
    required this.contactslistdata,
  });

  static UserModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return UserModel(
        userID: snapshot['userID'],
        firstName: snapshot['firstName'],
        lastName: snapshot['lastName'],
        email: snapshot['email'],
        phoneNumber: snapshot['phoneNumber'],
        age: snapshot['age'],
        photoUrl: snapshot['photoUrl'],
        validId: snapshot['validId'],
        birthDay: snapshot['birthDay'],
        bloodType: snapshot['bloodType'],
        height: snapshot['height'],
        weight: snapshot['weight'],
        allergies: snapshot['allergies'],
        diseases: snapshot['diseases'],
        contactslistdata: snapshot['contactslistdata']);
  }

  Map<String, dynamic> toJson() => {
        'userID': userID,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'age': age,
        'photoUrl': photoUrl,
        'validId': validId,
        'birthDay': birthDay,
        'bloodType': bloodType,
        'height': height,
        'weight': weight,
        'allergies': allergies,
        'diseases': diseases,
        'contactslistdata': contactslistdata,
      };
}

class UserPref {
  static late SharedPreferences pref;
  static Future init() async {
    pref = await SharedPreferences.getInstance();
  }
}
