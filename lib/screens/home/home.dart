// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:ui';

import 'package:clay_containers/constants.dart';
import 'package:clay_containers/widgets/clay_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:instaid_dev/components/card_button.dart';
import 'package:instaid_dev/components/default_button.dart';
import 'package:instaid_dev/resources/firestore_methods.dart';
import 'package:instaid_dev/screens/home/components/report_emergency.dart';
import 'package:instaid_dev/screens/home/components/nearby_location.dart';
import 'package:instaid_dev/screens/profile/profile_bottom_sheet.dart';
import 'package:instaid_dev/components/user_icon.dart';
import 'package:instaid_dev/resources/auth_methods.dart';
import 'package:instaid_dev/size_config.dart';
import 'package:instaid_dev/utils/colors.dart';
import 'package:instaid_dev/utils/dial_emergency.dart';
import 'package:instaid_dev/utils/sms_service.dart';
import 'package:instaid_dev/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  static const id = 'HomeScreen';
  final String uid;
  const HomeScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;
  bool dataReceived = true;
  bool timerIsOn = false;
  Timer? _time;
  double percent = 0;
  int timeInSeconds = 0;
  bool _editmode = false;
  bool isLoading = false;
  var userData = {};
  double? _latitude;
  double? _longitude;
  var _address;
  double _yOffset = 0;
  BuildContext? dialogContext;
  bool _toggleEditCheck = false;
  String time_of_occurence = '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var policePhone;
  var rhuPhone;
  var firePhone;
  var rescuePhone;
  var fullName;

  DateTime get dateTimeNow => DateTime.now();

  @override
  void initState() {
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
    asyncMethod();
    getData();
    _determinePosition();
    log(HomeScreen.id, msg: "Current user: ${auth.currentUser}");

    super.initState();
  }

  Future<void> asyncMethod() async {
    if (await Permission.contacts.status.isDenied) {
      await Permission.contacts.request();
    } else {
      await Permission.contacts.request();
    }
    if (await Permission.location.status.isDenied) {
      await Permission.location.request();
    } else {
      await Permission.location.request();
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    } else {
      await Geolocator.requestPermission();
    }
    if (await Permission.sms.status.isDenied) {
      await Permission.sms.request();
    } else {
      await Permission.sms.request();
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _updatePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    try {
      List pm = await placemarkFromCoordinates(pos.latitude, pos.longitude,
          localeIdentifier: 'phi_PH');

      _latitude = pos.latitude;
      _longitude = pos.longitude;
      log(HomeScreen.id, msg: _latitude);
      log(HomeScreen.id, msg: _longitude);

      Placemark placeMark = pm[0];
      String? street = placeMark.street;
      String? locality = placeMark.locality;
      String? subAdArea = placeMark.subAdministrativeArea;
      String? countryCode = placeMark.isoCountryCode;
      String? country = placeMark.country;
      _address =
          "${street}, ${locality}, ${subAdArea}, ${country}, ${countryCode}";
    } catch (e) {
      log(HomeScreen.id, msg: e.toString());
    }

    // setState(() {
    //   _latitude = pos.latitude;
    //   _longitude = pos.longitude;

    //   Placemark placeMark = pm[0];
    //   String? street = placeMark.street;
    //   String? locality = placeMark.locality;
    //   String? subAdArea = placeMark.subAdministrativeArea;
    //   String? countryCode = placeMark.isoCountryCode;
    //   String? country = placeMark.country;
    //   _address =
    //       "${street}, ${locality}, ${subAdArea}, ${country}, ${countryCode}";

    // });
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await _firestore.collection('user').doc(widget.uid).get();

      userData = userSnap.data()!;

      fullName = userData['firstName'] + ' ' + userData['lastName'];
      log(HomeScreen.id, msg: fullName);

      var hotlineDataPolice = await _firestore
          .collection('emergency_hotlines')
          .doc('RkQSdVv0HcBMkIdWPnkS')
          .get();

      policePhone = hotlineDataPolice.data()!;

      var hotlineDataFire = await _firestore
          .collection('emergency_hotlines')
          .doc('tYg5u3y2rqBlMiFtdiDv')
          .get();

      firePhone = hotlineDataFire.data()!;

      var hotlineDataRescue = await _firestore
          .collection('emergency_hotlines')
          .doc('RkQSdVv0HcBMkIdWPnkS')
          .get();

      rescuePhone = hotlineDataRescue.data()!;

      var hotlineDataRhiu = await _firestore
          .collection('emergency_hotlines')
          .doc('sB5QqpASEsL82t6wkZAS')
          .get();

      rhuPhone = hotlineDataRhiu.data()!;

      setState(() {});
      setState(() {});
      // showSnackBar(
      //     context, 'Current user: ${auth.currentUser?.uid.toString()}');
    } catch (e) {}
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    void sendPoliceHelp() async {
      sendEmergencyProtocol(name: fullName, helpType: "police");

      String res = await FireStoreMethods().submitHelp(
          help_type: 'Police',
          time_of_occurence: Timestamp.now(),
          location: _address,
          longitude: _longitude ?? 1,
          latitude: _latitude ?? 1,
          status: 'New',
          uid: userData['userID']);
    }

    void sendFireHelp() async {
      sendEmergencyProtocol(name: fullName, helpType: "fire");
      String res = await FireStoreMethods().submitHelp(
          help_type: 'Fire',
          time_of_occurence: Timestamp.now(),
          status: 'New',
          location: _address,
          longitude: _longitude ?? 1,
          latitude: _latitude ?? 1,
          uid: userData['userID']);
    }

    void sendMedicalHelp() async {
      sendEmergencyProtocol(name: fullName, helpType: "medical");
      String res = await FireStoreMethods().submitHelp(
          help_type: 'Medical',
          time_of_occurence: Timestamp.now(),
          status: 'New',
          location: _address,
          longitude: _longitude ?? 1,
          latitude: _latitude ?? 1,
          uid: userData['userID']);
    }

    void sendRescueHelp() async {
      sendEmergencyProtocol(name: fullName, helpType: "rescue");
      String res = await FireStoreMethods().submitHelp(
          help_type: 'Rescue',
          location: _address,
          time_of_occurence: Timestamp.now(),
          status: 'New',
          longitude: _longitude ?? 1,
          latitude: _latitude ?? 1,
          uid: userData['userID']);
    }

    showDataAlert() {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: primaryBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    17.0,
                  ),
                ),
              ),
              contentPadding: EdgeInsets.all(
                20.0,
              ),
              title: Text(
                "I NEED...",
                style: TextStyle(
                    color: textColorBlack,
                    fontSize: 25.0,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              content: Container(
                  width: 400,
                  height: 300, //SizeConfig.screenHeight * 1,
                  child: GridView(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10),
                    children: [
                      InkWell(
                        onTap: () async {
                          await _updatePosition();
                          await EasyLoading.show(status: 'Dialing hotline...');
                          dialFire(number: firePhone['department_number']);
                          await EasyLoading.dismiss();
                          sendFireHelp();
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/svg/fire.svg",
                                height: getProportionateScreenWidth(60),
                                width: getProportionateScreenWidth(60),
                                color: primaryColorRed,
                              ),
                              Padding(padding: EdgeInsets.only(bottom: 10)),
                              Text("Fire Help",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                      color: textColorDGray)),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          await EasyLoading.show(status: 'Dialing hotline...');
                          dialPolice(number: policePhone['department_number']);
                          await _updatePosition();
                          sendPoliceHelp();
                          await EasyLoading.dismiss();

                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/svg/police.svg",
                                height: getProportionateScreenWidth(60),
                                width: getProportionateScreenWidth(60),
                                color: primaryColorRed,
                              ),
                              Padding(padding: EdgeInsets.only(bottom: 10)),
                              Text("Police Help",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                      color: textColorDGray)),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          await _updatePosition();
                          await EasyLoading.show(status: 'Dialing hotline...');
                          dialMedical(number: rhuPhone['department_number']);
                          await EasyLoading.dismiss();
                          log(HomeScreen.id,
                              msg: rhuPhone['department_number']);

                          sendMedicalHelp();
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/svg/medical.svg",
                                height: getProportionateScreenWidth(60),
                                width: getProportionateScreenWidth(60),
                                color: primaryColorRed,
                              ),
                              Padding(padding: EdgeInsets.only(bottom: 10)),
                              Text("Medical Help",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                      color: textColorDGray)),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          await _updatePosition();
                          await EasyLoading.show(status: 'Dialing hotline...');
                          dialRescue(number: rescuePhone['department_number']);
                          log(HomeScreen.id,
                              msg: rescuePhone['department_number']);
                          await EasyLoading.dismiss();
                          sendRescueHelp();
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/svg/rescue.svg",
                                height: getProportionateScreenWidth(60),
                                width: getProportionateScreenWidth(60),
                                color: primaryColorRed,
                              ),
                              Padding(padding: EdgeInsets.only(bottom: 10)),
                              Text("Rescue, Other emergencies",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                      color: textColorDGray)),
                            ],
                          ),
                        ),
                      )
                    ],
                  )),
            );
          });
    }

    showChoices() {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: primaryBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    17.0,
                  ),
                ),
              ),
              contentPadding: EdgeInsets.all(
                20.0,
              ),
              title: Text(
                "Choose an option",
                style: TextStyle(
                    color: textColorBlack,
                    fontSize: 25.0,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              content: Container(
                  width: 400,
                  height: 150, //SizeConfig.screenHeight * 1,
                  child: GridView(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10),
                    children: [
                      InkWell(
                        onTap: () async {
                          //await EasyLoading.show(status: 'Dialing hotline...');
                          Navigator.of(context, rootNavigator: true).pop();
                          await showDataAlert();
                          
                          //await EasyLoading.dismiss();
                          
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/svg/fire.svg",
                                height: getProportionateScreenWidth(60),
                                width: getProportionateScreenWidth(60),
                                color: primaryColorRed,
                              ),
                              Padding(padding: EdgeInsets.only(bottom: 10)),
                              Text("Call for help",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                      color: textColorDGray)),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          // await EasyLoading.show(status: 'Dialing hotline...');
                          // dialPolice(number: policePhone['department_number']);
                          // await _updatePosition();
                          // sendPoliceHelp();
                          // await EasyLoading.dismiss();
                          Navigator.of(context, rootNavigator: true).pop();
                          onPressedReport();

                          
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/svg/police.svg",
                                height: getProportionateScreenWidth(60),
                                width: getProportionateScreenWidth(60),
                                color: primaryColorRed,
                              ),
                              Padding(padding: EdgeInsets.only(bottom: 10)),
                              Text("Report emergency",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                      color: textColorDGray)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
            );
          });
    }

    void startTimer() {
      timeInSeconds = 5;
      int time = timeInSeconds * 1000;
      double milisecPercent = time / 100;
      Timer(Duration(milliseconds: 0), () {
        _time = Timer.periodic(Duration(milliseconds: 50), (timer) {
          setState(() {
            if (time > 0) {
              if (!timerIsOn) {
                timer.cancel();
                timeInSeconds = 0;
              } else {
                time -= 50;
                if (time % 1000 == 0) {
                  timeInSeconds--;
                }
                if ((time % milisecPercent).toInt() == 0) {
                  if (percent < 0.99) {
                    percent += 0.01;
                  } else {
                    percent = 1;
                    //showDataAlert();
                    showChoices();
                  }
                }
              }
            } else {
              percent = 0;
              timer.cancel();
              timerIsOn = false;
            }
          });
        });
      });
    }

    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            backgroundColor: primaryBackground,
            body: SafeArea(
              // opacity: 1,
              // color: primaryBackground,
              // inAsyncCall: dataReceived,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SafeArea(
                      child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Hero(
                                    tag: 'avatar',
                                    child: UserAvatar(
                                      imagePath: userData['photoUrl'],
                                    )),
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        HapticFeedback.selectionClick();
                                      });
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Hello, ${userData['firstName']}",
                                          style: TextStyle(
                                            fontSize: width * 0.0381,
                                            fontWeight: FontWeight.w500,
                                            color: textColorBlack,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 0,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            onPressedViewProfile();
                                          },
                                          child: Text(
                                            'View Profile',
                                            style: TextStyle(
                                                fontSize: width * 0.0331,
                                                fontWeight: FontWeight.w600,
                                                color: primaryColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                                Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: nearestEMSLocation(
                                        width, height, context)),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: height * 0.08),
                              child: Text(
                                'Need emergency help?',
                                style: TextStyle(
                                    color: textColorBlack,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                            Text(
                              'Just press the button',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: textColorGray),
                              textAlign: TextAlign.center,
                            ),
                            Hero(
                              tag: "emergency",
                              child: Padding(
                                padding: EdgeInsets.all(height * 0.0338),
                                child: ClayContainer(
                                  color: primaryBackground,
                                  surfaceColor: primaryBackground,
                                  height: height * 0.280,
                                  width: height * 0.280,
                                  borderRadius: 130,
                                  curveType: CurveType.convex,
                                  spread: 20,
                                  depth: 30,
                                  child: Center(
                                    child: ClayContainer(
                                      color: primaryBackground,
                                      surfaceColor: primaryBackground,
                                      height: height * 0.270,
                                      width: height * 0.270,
                                      borderRadius: 200,
                                      curveType: CurveType.concave,

                                      //depth: 100,
                                      child: Center(
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              width: SizeConfig.screenWidth * 2,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                              ),
                                              child: CircularPercentIndicator(
                                                radius:
                                                    SizeConfig.screenHeight *
                                                        0.135,
                                                animation: true,
                                                percent: percent,
                                                animateFromLastPercent: true,
                                                lineWidth: height * 0.040,
                                                circularStrokeCap:
                                                    CircularStrokeCap.round,
                                                backgroundColor:
                                                    Colors.transparent,
                                              ),
                                            ),
                                            Container(
                                                height: height * 0.230,
                                                width: height * 0.230,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                ),
                                                child: RawMaterialButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      if (!timerIsOn) {
                                                        timerIsOn = true;
                                                        startTimer();
                                                      } else {
                                                        timerIsOn = false;
                                                        percent = 0;
                                                      }
                                                    });
                                                  },
                                                  elevation: 10.0,
                                                  fillColor: primaryColorRed,
                                                  highlightColor:
                                                      primaryColorRed,
                                                  highlightElevation: 0,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: !(timeInSeconds == 0)
                                                        ? Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                  height: SizeConfig
                                                                          .screenHeight *
                                                                      0.02),
                                                              Padding(
                                                                padding: EdgeInsets.only(
                                                                    top: height *
                                                                        0.0146),
                                                                child: Text(
                                                                  timeInSeconds
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          height *
                                                                              0.090,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                              Text(
                                                                'Press to cancel!',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        height *
                                                                            0.02,
                                                                    color: Colors
                                                                        .white),
                                                              )
                                                            ],
                                                          )
                                                        : Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              image:
                                                                  DecorationImage(
                                                                image: AssetImage(
                                                                    'assets/images/button.png'),
                                                              ),
                                                            ),
                                                          ),
                                                  ),
                                                  padding: EdgeInsets.all(15.0),
                                                  shape: CircleBorder(),
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // SizedBox(height: SizeConfig.screenHeight * 0.02),
                            // Text(
                            //   'Report an emergency?',
                            //   style: TextStyle(
                            //       fontSize: height * 0.03,
                            //       fontWeight: FontWeight.w600,
                            //       color: textColorBlack),
                            // ),
                            // SizedBox(height: SizeConfig.screenHeight * 0.025),
                            // DefaultButton(
                            //     text: 'Report', press: onPressedReport),
                            // InkWell(
                            //       onTap: () {
                            //         onPressedReport();
                            //       },
                            //       child: CardButton(
                            //           height: height,
                            //           title: "Report",
                            //           icon: Icon(Icons.remove_red_eye_sharp,
                            //               color: textColorDGray)),
                            //     ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.center,
                            //   children: [
                            //     InkWell(
                            //       onTap: () {
                            //         onPressedReport();
                            //       },
                            //       child: CardButton(
                            //           height: height,
                            //           title: "Report as witness",
                            //           icon: Icon(Icons.remove_red_eye_sharp,
                            //               color: textColorDGray)),
                            //     ),
                            //     InkWell(
                            //       child: CardButton(
                            //           height: height,
                            //           title: "Report as idk hehe",
                            //           icon: Icon(Icons.no_food,
                            //               color: textColorDGray)),
                            //     ),
                            //   ],
                            // )
                          ],
                        )
                      ],
                    ),
                  )),
                ],
              ),
            ),
          );
  }

  onPressedReport() {
    showModalBottomSheet(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * (750 / 812),
          minHeight: MediaQuery.of(context).size.height * (518 / 812),
        ),
        enableDrag: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        isDismissible: true,
        context: context,
        builder: (context) {
          return ReportEmergency();
        });
  }

  onPressedViewProfile() {
    showModalBottomSheet(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * (740 / 812),
          minHeight: MediaQuery.of(context).size.height * (518 / 812),
        ),
        enableDrag: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        isDismissible: true,
        context: context,
        builder: (context) {
          log(HomeScreen.id,
              msg: "View profile: ${auth.currentUser?.uid.toString()}");
          return ViewProfile(uid: auth.currentUser!.uid.toString());
        });
  }

  Widget buildName() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            userData['firstName'] ?? '',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ],
      );
}
