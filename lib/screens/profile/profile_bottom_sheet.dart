import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instaid_dev/components/allergies_diseases_card.dart';
import 'package:instaid_dev/components/profile_card.dart';
import 'package:instaid_dev/components/user_icon.dart';
import 'package:instaid_dev/models/user_model.dart';
import 'package:instaid_dev/utils/keyboard_dismiss_detector.dart';
import 'package:instaid_dev/resources/firestore_methods.dart';
import 'package:instaid_dev/size_config.dart';
import 'package:instaid_dev/utils/colors.dart';
import 'package:instaid_dev/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewProfile extends StatefulWidget {
  final String uid;
  static const id = 'ViewProfile';
  const ViewProfile({Key? key, required this.uid}) : super(key: key);

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  var userData = {};
  bool _toggleEditCheck = false;
  bool isLoading = false;

  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController bloodController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController allergiesController = TextEditingController();
  TextEditingController diseasesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    getData();
    asyncMethod();
  }

  @override
  void dispose() {
    bloodController.dispose();
    super.dispose();
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

      weightController.text = userData['weight'];
      ageController.text = userData['age'].toString();
      heightController.text = userData['height'];
      bloodController.text = userData['bloodType'];
      allergiesController.text = userData['allergies'];
      diseasesController.text = userData['diseases'];
      // print(userData['age']);
      // print(userData['weight']);
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> asyncMethod() async {
    UserPref.pref = await SharedPreferences.getInstance();
    // If blood type update not updating, print this
    bloodType = UserPref.pref.getString('bloodType');
    // log(ViewProfile.id, msg: bloodType);

    // final prefs = await SharedPreferences.getInstance();
    // final keys = prefs.getKeys();

    // final prefsMap = Map<String, dynamic>();
    // for (String key in keys) {
    //   prefsMap[key] = prefs.get(key);
    // }

    // log(ViewProfile.id, msg: prefsMap);

    // weight = UserPref.pref.getString('weight') ?? "";
    // height = UserPref.pref.getString('height') ?? "";
    // // auth_age = UserPref.pref.getInt('age') ?? 0;
    // allergies = UserPref.pref.getString('allergies') ?? "";
    // diseases = UserPref.pref.getString('diseases') ?? "";
    // print(auth_age);
  }

  @override
  Widget build(BuildContext context) {
    double uheight = MediaQuery.of(context).size.height;

    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : KeyboardDismissDetector(
            child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    height: 5,
                    width: 52,
                    color: textColorGray,
                    margin: const EdgeInsets.only(bottom: 10)),
                Expanded(
                  child: Container(
                      decoration: const BoxDecoration(
                        color: primaryBackground,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: SafeArea(
                          child: Column(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 20),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Opacity(
                                            opacity: 0,
                                            child: Icon(Icons.arrow_forward),
                                          ),
                                          UserAvatar(
                                            imagePath: userData['photoUrl'],
                                            size:
                                                SizeConfig.screenHeight * 0.15,
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              (_toggleEditCheck == true)
                                                  ? Icons.check
                                                  : Icons.edit,
                                              size:
                                                  SizeConfig.screenWidth * 0.1,
                                              color: primaryColorRed,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _toggleEditCheck =
                                                    !_toggleEditCheck;
                                                if (!_toggleEditCheck) {
                                                  updatePrefs();
                                                  updateBloodType(bloodTypeNew: bloodType!);
                                                  updateHeight(
                                                      height: heightController
                                                          .text);
                                                  updateWeight(
                                                      weight: weightController
                                                          .text);
                                                  updateAllergies(
                                                      allergies:
                                                          allergiesController
                                                              .text);
                                                  updateDiseases(
                                                      diseases:
                                                          diseasesController
                                                              .text);
                                                }
                                                //print(_toggleEditCheck);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 20, 0, 0),
                                            child: buildName(),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 15, 0, 15),
                                        child: buildBirthday(),
                                      ),
                                      Container(
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                buildAge(),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  10),
                                                          border: Border.all(
                                                              color: Theme.of(
                                                                      context)
                                                                  .dividerColor,
                                                              width: 1)),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                "Blood Type",
                                                                overflow:
                                                                    TextOverflow
                                                                        .visible,
                                                                softWrap: true,
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        uheight *
                                                                            0.0201),
                                                              ),
                                                              Icon(
                                                                Icons
                                                                    .water_drop,
                                                                size: SizeConfig
                                                                        .screenWidth *
                                                                    0.04,
                                                                color: const Color(
                                                                    0xFFB35354),
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 26,
                                                                    right: 8,
                                                                    left: 4),
                                                            child:
                                                                DropdownButtonHideUnderline(
                                                              child:
                                                                  DropdownButton(
                                                                      hint: const Text(
                                                                          "Blood Type",
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          style: TextStyle(
                                                                              fontSize:
                                                                                  14,
                                                                              fontWeight: FontWeight
                                                                                  .w300)),
                                                                      dropdownColor:
                                                                          primaryBackground,
                                                                      value: bloodType ?? userData['bloodType'],
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .keyboard_arrow_down_rounded,
                                                                        color: _toggleEditCheck
                                                                            ? Colors.red
                                                                            : Colors.grey,
                                                                      ),
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w700,
                                                                      ),
                                                                      items: [
                                                                        DpItem(
                                                                            context,
                                                                            'A+',
                                                                            uheight),
                                                                        DpItem(
                                                                            context,
                                                                            'A-',
                                                                            uheight),
                                                                        DpItem(
                                                                            context,
                                                                            'B+',
                                                                            uheight),
                                                                        DpItem(
                                                                            context,
                                                                            'B-',
                                                                            uheight),
                                                                        DpItem(
                                                                            context,
                                                                            'AB+',
                                                                            uheight),
                                                                        DpItem(
                                                                            context,
                                                                            'AB-',
                                                                            uheight),
                                                                        DpItem(
                                                                            context,
                                                                            'O+',
                                                                            uheight),
                                                                        DpItem(
                                                                            context,
                                                                            'O-',
                                                                            uheight),
                                                                      ],
                                                                      onChanged: _toggleEditCheck
                                                                          ? (value) {
                                                                              setState(() {
                                                                                bloodType = value as String;
                                                                              });
                                                                            }
                                                                          : null),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                ProfileCard(
                                                  height: uheight,
                                                  unit: "cm",
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .digitsOnly
                                                  ],
                                                  keyboardType:
                                                      TextInputType.number,
                                                  icon: Icon(
                                                    Icons.straighten,
                                                    size:
                                                        SizeConfig.screenWidth *
                                                            0.04,
                                                    color:
                                                        const Color(0xFF6BB3B9),
                                                  ),
                                                  title: 'Height:',
                                                  controller: heightController,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      height = value;
                                                      log(ViewProfile.id,
                                                          msg: height);
                                                    });
                                                  },
                                                  editmode: _toggleEditCheck,
                                                ),
                                                ProfileCard(
                                                  unit: "kg",
                                                  height: uheight,
                                                  inputFormatters: [
                                                    FilteringTextInputFormatter
                                                        .digitsOnly
                                                  ],
                                                  keyboardType:
                                                      TextInputType.number,
                                                  icon: Icon(
                                                    Icons.scale,
                                                    size:
                                                        SizeConfig.screenWidth *
                                                            0.04,
                                                    color:
                                                        const Color(0XFF886FB5),
                                                  ),
                                                  title: 'Weight:',
                                                  controller: weightController,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      weight = value;
                                                    });
                                                  },
                                                  editmode: _toggleEditCheck,
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                AllergiesDiseases(
                                                  height: uheight,
                                                  keyboardType:
                                                      TextInputType.name,
                                                  icon: Icon(
                                                    Icons.no_food,
                                                    size:
                                                        SizeConfig.screenWidth *
                                                            0.04,
                                                    color:
                                                        const Color(0xFF724219),
                                                  ),
                                                  title: 'Allergies:',
                                                  controller:
                                                      allergiesController,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      allergies = value;
                                                    });
                                                  },
                                                  editmode: _toggleEditCheck,
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                AllergiesDiseases(
                                                  height: uheight,
                                                  keyboardType:
                                                      TextInputType.name,
                                                  icon: Icon(
                                                    Icons.sick,
                                                    size:
                                                        SizeConfig.screenWidth *
                                                            0.04,
                                                    color:
                                                        const Color(0xFF2F9255),
                                                  ),
                                                  title:
                                                      'Sickness, Diseases, Medications',
                                                  controller:
                                                      diseasesController,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      diseases = value;
                                                    });
                                                  },
                                                  editmode: _toggleEditCheck,
                                                ),
                                              ],
                                            ),
                                            // Row(
                                            //   children: [
                                            //     ProfileCard(
                                            //       height: uheight,
                                            //       unit: "cm",
                                            //       keyboardType:
                                            //           TextInputType.number,
                                            //       icon: Icon(
                                            //         Icons.straighten,
                                            //         size: SizeConfig.screenWidth *
                                            //             0.04,
                                            //         color:
                                            //             const Color(0xFF6BB3B9),
                                            //       ),
                                            //       title: 'Height:',
                                            //       controller: heightController,
                                            //       onChanged: (value) {
                                            //         setState(() {
                                            //           height = value;
                                            //           updateHeight();
                                            //         });
                                            //       },
                                            //       editmode: _toggleEditCheck,
                                            //     ),
                                            //   ],
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ),
              ],
            ),
          ));
  }

  Widget buildName() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            userData['firstName'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 30),
          ),
          Text(
            ' ',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 30),
          ),
          Text(
            userData['lastName'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 30),
          ),
        ],
      );

  Widget buildBirthday() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            userData['birthDay'] ?? '',
            style: const TextStyle(color: textColorDGray, fontSize: 15),
          ),
        ],
      );

  Widget buildAge() => Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: Theme.of(context).dividerColor, width: 1)),
            // height: 200,
            // width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Age",
                        overflow: TextOverflow.visible,
                        softWrap: true,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: SizeConfig.screenHeight * 0.0201),
                      ),
                    ),
                    Icon(
                      Icons.calendar_month,
                      size: SizeConfig.screenWidth * 0.04,
                      color: const Color(0xFF62C886),
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig.screenHeight * 0.03),
                Row(
                  children: [
                    Expanded(
                      // child: Text(
                      //   userData['age'] ?? '',
                      //   style: TextStyle(
                      //       fontWeight: FontWeight.w700,
                      //       fontSize: SizeConfig.screenHeight * 0.037),

                      // ),
                      child: TextFormField(
                        autofocus: false,
                        initialValue: userData['age'].toString(),
                        textAlign: TextAlign.left,
                        readOnly: true,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: SizeConfig.screenHeight * 0.037),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                              fontSize: SizeConfig.screenHeight * 0.0186,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    Text("years old"),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  DropdownMenuItem<String> DpItem(
      BuildContext context, String text, double uheight) {
    return DropdownMenuItem(
      child: Container(
        child: Text(
          text,
          style: TextStyle(
              color: textColorBlack,
              fontWeight: FontWeight.w700,
              fontSize: uheight * 0.0301,
              fontFamily: 'Gotham'),
        ),
      ),
      value: text,
    );
  }
}
