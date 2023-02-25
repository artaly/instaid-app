import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

Future<void> dialFire({required String number}) async {
  //FlutterPhoneDirectCaller.callNumber('726-3630');
  FlutterPhoneDirectCaller.callNumber(number);
}

Future<void> dialPolice({required String number}) async {
  //FlutterPhoneDirectCaller.callNumber('726-2205');
    FlutterPhoneDirectCaller.callNumber(number);

}

Future<void> dialMedical({required String number}) async {
  //FlutterPhoneDirectCaller.callNumber('786-1637');
    FlutterPhoneDirectCaller.callNumber(number);

}

Future<void> dialRescue({required String number}) async {
  //FlutterPhoneDirectCaller.callNumber('786-0816');
    FlutterPhoneDirectCaller.callNumber(number);

  }

Future <void> dialEmergency({required String number}) async {
  FlutterPhoneDirectCaller.callNumber(number);
}
