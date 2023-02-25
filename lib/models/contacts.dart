import 'dart:convert';
import 'package:instaid_dev/resources/firestore_methods.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactsData {
  String name;
  String number;

  ContactsData({required this.name, required this.number});

  factory ContactsData.fromJson(Map<String, dynamic> jsonData) {
    return ContactsData(
      name: jsonData['name'],
      number: jsonData['number'],
    );
  }

  static Map<String, dynamic> toMap(ContactsData contactsData) => {
        'name': contactsData.name,
        'number': contactsData.number,
      };

  static String encode(List<ContactsData> contactsDatas) => json.encode(
        contactsDatas
            .map<Map<String, dynamic>>(
                (contactsData) => ContactsData.toMap(contactsData))
            .toList(),
      );

  static List<ContactsData> decode(String contactsDatas) =>
      (json.decode(contactsDatas) as List<dynamic>)
          .map<ContactsData>((item) => ContactsData.fromJson(item))
          .toList();

  static void updateContactsListInPref(SharedPreferences pref) {
    contactslistdata = encode(contactslist);
    pref.setString('contactsData', contactslistdata);
    updateContactList();
  }

  static bool contactIfExist(ContactsData contact) {
    int length = contactslist.length;
    for (int i = 0; i < length; i++) {
      if (contactslist[i].name == contact.name &&
          contactslist[i].number == contact.number) {
        return true;
      }
    }
    return false;
  }
}
