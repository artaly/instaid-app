import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserReport {
  final String? help_type;
  final Timestamp time_of_occurence;
  final String? location;
  final double? longitude;
  final double? latitude;
  final String? status;
  final String? reportPhotoUrl;
  final String? uid;
  final String? reportTitle;
  final String? remarks;

  const UserReport({
    required this.help_type,
    required this.time_of_occurence,
    required this.location,
    required this.longitude,
    required this.latitude,
    required this.status,
    required this.uid,
    required this.reportPhotoUrl,
    required this.reportTitle,
    required this.remarks,
});

  static UserReport fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return UserReport(
      help_type: snapshot['help_type'],
      time_of_occurence: snapshot['time_of_occurence'],
      location: snapshot['location'],
      longitude: snapshot['longitude'],
      latitude: snapshot['latitude'],
      status: snapshot['status'],
      uid: snapshot['uid'],
      reportPhotoUrl: snapshot['reportPhotoUrl'],
      reportTitle: snapshot['reportTitle'],
      remarks: snapshot['remarks'],
      //user_details: snapshot['user_details'],
    );
  }

  Map<String, dynamic> toJson() => {
        'help_type': help_type,
        'time_of_occurence': time_of_occurence,
        'location': location,
        'longitude': longitude,
        'latitude': latitude,
        'status': status,
        'uid': uid,
        'reportPhotoUrl': reportPhotoUrl,
        'reportTitle': reportTitle,
        'remarks': remarks,
      };
}
