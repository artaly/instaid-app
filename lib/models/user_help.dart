import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserHelp {
  final String? help_type;
  final Timestamp time_of_occurence;
  final String? location;
  final double? longitude;
  final double? latitude;
  final String? status;
  final String? uid;
  //final Reference user_details;

  const UserHelp({
    required this.help_type,
    required this.time_of_occurence,
    required this.location,
    required this.longitude,
    required this.latitude,
    required this.status,
    required this.uid,
    
    //required this.user_details,
  });

  static UserHelp fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return UserHelp(
      help_type: snapshot['help_type'],
      time_of_occurence: snapshot['time_of_occurence'],
      location: snapshot['location'],
      longitude: snapshot['longitude'],
      latitude: snapshot['latitude'],
      status: snapshot['status'],
      uid: snapshot['uid'],
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
      };
}
