import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:instaid_dev/components/card_picture.dart';
import 'package:instaid_dev/screens/home/home.dart';
import 'package:instaid_dev/utils/globals.dart' as globals;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:instaid_dev/components/default_button.dart';
import 'package:instaid_dev/resources/firestore_methods.dart';
import 'package:instaid_dev/screens/home/components/pin_location.dart';
import 'package:instaid_dev/size_config.dart';
import 'package:instaid_dev/utils/colors.dart';
import 'package:instaid_dev/utils/utils.dart';

class ReportEmergency extends StatefulWidget {
  const ReportEmergency({Key? key}) : super(key: key);

  @override
  State<ReportEmergency> createState() => _ReportEmergencyState();
}

class _ReportEmergencyState extends State<ReportEmergency> {
  bool _isLoading = false;
  Uint8List? _image;
  bool isChecked = false;
  String specialRequest = "";
  String? _currentSelectedValue;
  var userData = {};
  final titleController = TextEditingController();
  final remarksController = TextEditingController();
  final locationController = TextEditingController();
  String typeValue = "";
  double _latitude = 0;
  double _longitude = 0;
  var _address = "";

  double _pinnedLongitude = globals.pinLongitude;
  double _pinnedLatitude = globals.pinLatitude;

  List<String> _selectedChoices = [];
  final List<String> _choices = ['Rescue', 'Fire', 'Police', 'Medical'];
  final List<String> fireChoices = ['Grass Fire', 'Residential Fire', 'Storage/Warehouse Fire', 'Commercial Fire', 'Others'];
    final List<String> policeChoices = ['Against Person', 'Against Property', 'Traffic Incident', 'Others'];

  final List<String> rescueChoices = ['Fire', 'Earthquake', 'Vehicular Accident', 'Self-inflict accident', 'Hypertensive Crisis', 'Blood Sugar Spike', 'Others'];

  final List<String> medicalChoices = ['Allergic Reaction', 'Stroke', 'Seizure', 'Heart attack', 'Overdose', 'Choking', 'Others'];

  int tag = 0;

  void initState() {
    super.initState();
    _updatePosition();
    print(globals.pinAddress);
    getData();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  Future<void> _updatePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List pm = await placemarkFromCoordinates(pos.latitude, pos.longitude,
        localeIdentifier: 'phi_PH');

    if (this.mounted) {
      // check whether the state object is in tree
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;

        Placemark placeMark = pm[0];
        String? street = placeMark.street;
        String? locality = placeMark.locality;
        String? subAdArea = placeMark.subAdministrativeArea;
        String? countryCode = placeMark.isoCountryCode;
        String? country = placeMark.country;
        _address =
            // ignore: unnecessary_brace_in_string_interps
            "${street}, ${locality}, ${subAdArea}, ${country}, ${countryCode}";
      });
    }
  }

  getData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('user')
          .doc(auth.currentUser?.uid)
          .get();

      userData = userSnap.data()!;

      setState(() {});
    } catch (e) {}
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Column(
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
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: Column(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Text("Type of Emergency",
                                          textAlign: TextAlign.left,
                                          style:
                                              TextStyle(color: textColorBlack)),
                                      buildChips(),
                                      SizedBox(
                                          height:
                                              getProportionateScreenHeight(10)),
                                      FormField<String>(
                                        builder:
                                            (FormFieldState<String> state) {
                                          return InputDecorator(
                                            decoration: InputDecoration(
                                                //labelStyle: textStyle,
                                                errorStyle: TextStyle(
                                                    color: Colors.redAccent,
                                                    fontSize: 16.0),
                                                hintText:
                                                    'Please select expense',
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0))),
                                            isEmpty:
                                                _currentSelectedValue == '',
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: _currentSelectedValue,
                                                isDense: true,
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    _currentSelectedValue =
                                                        newValue;
                                                    state.didChange(newValue);
                                                  });
                                                },
                                                items: (tag == 0) ?
                                                  rescueChoices
                                                    .map((String value) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList() : (tag == 1) ? fireChoices
                                                    .map((String value) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList() : (tag == 2) ? policeChoices
                                                    .map((String value) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList() : medicalChoices
                                                    .map((String value) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      SizedBox(
                                          height:
                                              getProportionateScreenHeight(25)),
                                      buildLocationField(),
                                      CheckboxListTile(
                                        activeColor: primaryColor,
                                        checkColor: Colors.white,
                                        title: const Text(
                                          "Use my current location",
                                          style: TextStyle(
                                            color: textColorBlack,
                                          ),
                                        ),
                                        value: isChecked,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            isChecked = value!;
                                          });
                                        },
                                        controlAffinity: ListTileControlAffinity
                                            .leading, //  <-- leading Checkbox
                                      ),
                                      SizedBox(
                                          height:
                                              getProportionateScreenHeight(10)),
                                      buildRemarksField(),
                                      SizedBox(
                                          height:
                                              getProportionateScreenHeight(20)),
                                      buildIncidentPhoto(),
                                      SizedBox(
                                          height:
                                              getProportionateScreenHeight(25)),
                                      DefaultButton(
                                          text: "Submit",
                                          press: () async {
                                            await submitReport();
                                          }),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ),
            ],
          );
  }

  selectIncidentPic() async {
    Uint8List incidentImg = await pickImage(ImageSource.camera);
    setState(() {
      _image = incidentImg;
    });
  }

  Stack buildIncidentPhoto() {
    return Stack(
      children: [
        _image != null
            ? Stack(
                children: [
                  CardPicture(
                    backgroundImage: MemoryImage(_image!),
                  ),
                  Positioned(
                    child: Container(
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(3.0, 3.0),
                              blurRadius: 2.0,
                            )
                          ]),
                      child: IconButton(
                          onPressed: () {
                            setState(() {
                              _image = null;
                            });
                          },
                          icon: const Icon(Icons.close, color: Colors.white)),
                    ),
                  )
                ],
              )
            : CardPicture(
                onTap: selectIncidentPic, cardLabel: "Select incident picture"),
      ],
    );
  }

  ChipsChoice buildChips() {
    return ChipsChoice<int>.single(
      value: tag,
      onChanged: (val) => setState(() {
        tag = val;
        if (tag == 0) {
          typeValue = "Rescue";
          log(HomeScreen.id, msg: typeValue);
        } else if (tag == 1) {
          typeValue = "Fire";
          log(HomeScreen.id, msg: typeValue);
        } else if (tag == 2) {
          typeValue = "Police";
          log(HomeScreen.id, msg: typeValue);
        } else if (tag == 3) {
          typeValue = "Medical";
          log(HomeScreen.id, msg: typeValue);
        }
      }),
      choiceItems: C2Choice.listFrom<int, String>(
        source: _choices,
        value: (i, v) => i,
        label: (i, v) => v,
      ),
    );
  }

  TextFormField buildTitleField() {
    return TextFormField(
      controller: titleController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
          labelText: "Title",
          hintText: "Determine the incident",
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 42, vertical: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: textColorGray),
            gapPadding: 10,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: textColorGray),
            gapPadding: 10,
          )),
    );
  }

  TextFormField buildLocationField() {
    if (isChecked == false) {
      locationController.text = globals.pinAddress;
    } else {
      locationController.text = "Current position used";
    }

    return TextFormField(
      enabled: isChecked != false ? false : true,
      onTap: () {
        Navigator.pushNamed(context, PinLocation.id);
      },
      controller: locationController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
          labelText: "Location",
          hintText: isChecked != false
              ? "Current position used"
              //globals.pinAddress
              : "Determine the location",
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 42, vertical: 20),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: textColorGray),
            gapPadding: 10,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: textColorGray),
            gapPadding: 10,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: textColorGray),
            gapPadding: 10,
          )),
    );
  }

  TextFormField buildRemarksField() {
    return TextFormField(
      controller: remarksController,
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: 3,
      decoration: InputDecoration(
          labelText: "Other remarks",
          hintText: "Additional information (optional)",
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 42, vertical: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: textColorGray),
            gapPadding: 10,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: textColorGray),
            gapPadding: 10,
          )),
    );
  }

  Future<void> submitReport() async {
    try {
      if (_currentSelectedValue == "" || locationController.text.isEmpty) {
        Fluttertoast.showToast(msg: "Please fill all required fields!");
      } else if (_image == null) {
        Fluttertoast.showToast(msg: "Please select a picture of the incident!");
      } else {
        await _updatePosition();
        await EasyLoading.show(status: 'Submitting report...');
        String res = await FireStoreMethods().submitReport(
            help_type: typeValue,
            location: isChecked != false ? _address : globals.pinAddress,
            time_of_occurence: Timestamp.now(),
            status: 'New',
            longitude: isChecked != false ? _longitude : globals.pinLongitude,
            latitude: isChecked != false ? _latitude : globals.pinLatitude,
            uid: userData['userID'],
            reportTitle: _currentSelectedValue,
            remarks: remarksController.text,
            reportPhotoUrl: _image!);

        Fluttertoast.showToast(msg: "Report submitted!");

        Navigator.pop(context);
        EasyLoading.dismiss();
        globals.pinAddress = "";
        globals.pinLongitude = 0;
        globals.pinLatitude = 0;
        locationController.clear();
        print("Cleared" + globals.pinAddress);
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
