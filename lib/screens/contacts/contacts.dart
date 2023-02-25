import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:instaid_dev/resources/firestore_methods.dart';
import 'package:instaid_dev/screens/contacts/hotline_list.dart';
import 'package:instaid_dev/utils/dial_emergency.dart';
import 'package:instaid_dev/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/contacts_card.dart';
import '../../models/contacts.dart';
import '../../models/user_model.dart';
import '../../size_config.dart';
import '../../utils/colors.dart';

class ContactScreen extends StatefulWidget {
  static const id = 'ContactScreen';
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  double buttonDepth = 30;
  bool isVisible = true;
  bool isLoading = false;
  var userData = {};

  void _updateContactsList(int index) {
    setState(() {
      HapticFeedback.lightImpact();
      contactslist.removeAt(index);
    });
    ContactsData.updateContactsListInPref(UserPref.pref);
  }

  @override
  void initState() {
    super.initState();
    getData();
    asyncMethod();
  }

  Future<void> asyncMethod() async {
    UserPref.pref = await SharedPreferences.getInstance();
    contactslistdata = UserPref.pref.getString('contactsData') ?? '';
    log("Current user contact list: $contactslistdata");
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    final prefsMap = Map<String, dynamic>();
    for (String key in keys) {
      prefsMap[key] = prefs.get(key);
    }
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('user')
          .doc(auth.currentUser?.uid)
          .get();

      userData = userSnap.data()!;
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var baseColor = primaryBackground;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, HotlineList.id);
        },
        backgroundColor: primaryColorRed,
        child: const Icon(Icons.local_phone),
      ),
      backgroundColor: baseColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Opacity(
                        opacity: 0,
                        child: Icon(Icons.arrow_forward),
                      ),
                      const Text(
                        'Contacts',
                        style: TextStyle(
                            color: textColorBlack,
                            fontSize: 30,
                            fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      Visibility(
                        visible: (contactslist.length < 5),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            child: Row(
                              children: [
                                const Text(
                                  "Add",
                                  style: TextStyle(color: primaryColor),
                                ),
                                Icon(
                                  Icons.add,
                                  size: SizeConfig.screenWidth * 0.04,
                                  color: primaryColor,
                                ),
                              ],
                            ),
                            onTap: () async {
                              if (contactslist.length < 5) {
                                HapticFeedback.lightImpact();
                                //buttonPressed();
                                try {
                                  await FlutterContactPicker
                                      .requestPermission();
                                  if (await FlutterContactPicker.hasPermission()) {
                                    PhoneContact contacts = await FlutterContactPicker.pickPhoneContact();
                                    ContactsData temp = ContactsData(
                                        name: contacts.fullName!,
                                        number: contacts.phoneNumber!.number
                                            .toString());
                                    if (!ContactsData.contactIfExist(temp)) {
                                      setState(() {
                                        contactslist.add(temp);
                                      });
                                    }
                                  }
                                } on Exception catch (_) {
                                  print("throwing new error");
                                  throw Exception("Can't add contacts");
                                }
                                ContactsData.updateContactsListInPref(UserPref.pref);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.04),
              Expanded(
                flex: 14,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: contactslist.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            print(contactslist);
                            return ContactsCard(
                              list: contactslist,
                              index: index,
                              update: _updateContactsList,
                            );
                          }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
