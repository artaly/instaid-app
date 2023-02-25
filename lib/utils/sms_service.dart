import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:instaid_dev/resources/firestore_methods.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

late TwilioFlutter twilioFlutter;

instantiateTwilio() {
  twilioFlutter = TwilioFlutter(
      accountSid: dotenv.get('TWILIO_ACCOUNT_SID'),
      authToken: dotenv.get('TWILIO_AUTH_TOKEN'),
      twilioNumber: dotenv.get('TWILIO_NUMBER'));
}

_sendSms(String recipents, String msg) {
  instantiateTwilio();
  twilioFlutter.sendSMS(toNumber: recipents, messageBody: msg);
}

Future<void> sendEmergencyProtocol({required String name, required String helpType}) async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  String content =
      'Emergency alert from InstAID!\n\n${name} called for ${helpType} help from this location. https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}\n\nYou might want to check up on them!';
  for (int i = 0; i < contactslist.length; i++) {
    _sendSms(contactslist[i].number.toString(), content);
  }
}
