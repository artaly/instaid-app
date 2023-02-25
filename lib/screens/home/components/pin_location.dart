// ignore_for_file: unnecessary_new

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:instaid_dev/components/back_button.dart';
import 'package:instaid_dev/components/default_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:instaid_dev/utils/globals.dart' as globals;

class PinLocation extends StatefulWidget {
  static const id = 'PinLocation';
  PinLocation({Key? key}) : super(key: key);

  @override
  State<PinLocation> createState() => _PinLocationState();
}

class _PinLocationState extends State<PinLocation> {
  double newLatitude = 0;
  double newLongitude = 0;
  double _currentLatitude = 0;
  double _currentLongitude = 0;
  var _address = "";

  static late LatLng _initialPosition;
  static LatLng _lastMapPosition = _initialPosition;

  @override
  void initState() {
    super.initState();
    _updatePosition();
  }

  void _updatePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List pm = await placemarkFromCoordinates(pos.latitude, pos.longitude,
        localeIdentifier: 'phi_PH');
    setState(() {
      _initialPosition = LatLng(pos.latitude, pos.longitude);
      _currentLatitude = pos.latitude;
      _currentLongitude = pos.longitude;
      print("Last map position: " + _lastMapPosition.toString());
      print(_initialPosition);

      Placemark placeMark = pm[0];
      String? street = placeMark.street;
      String? locality = placeMark.locality;
      String? subAdArea = placeMark.subAdministrativeArea;
      String? countryCode = placeMark.isoCountryCode;
      String? country = placeMark.country;
      _address =
          "${street}, ${locality}, ${subAdArea}, ${country}, ${countryCode}";
    });
  }

  Future<void> getAddress() async {
    List pm = await placemarkFromCoordinates(
        globals.pinLatitude, globals.pinLongitude,
        localeIdentifier: 'phi_PH');
    setState(() {
      Placemark placeMark = pm[0];
      String? street = placeMark.street;
      String? locality = placeMark.locality;
      String? subAdArea = placeMark.subAdministrativeArea;
      String? countryCode = placeMark.isoCountryCode;
      String? country = placeMark.country;
      globals.pinAddress =
          "${street}, ${locality}, ${subAdArea}, ${country}, ${countryCode}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            myLocationEnabled: true,
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14,
            ),
            markers: <Marker>{
              Marker(
                  markerId: MarkerId("1"),
                  onTap: () {
                    print('Tapped');
                  },
                  draggable: true,
                  position: LatLng(_currentLatitude, _currentLongitude),
                  onDragEnd: ((newPosition) {
                    setState(() {
                      globals.pinLatitude = newPosition.latitude;
                      globals.pinLongitude = newPosition.longitude;
                      getAddress();
                      print(
                          "Pinned latitude: " + globals.pinLatitude.toString());
                      print("Pinned longitude: " +
                          globals.pinLongitude.toString());
                      print("Pinned address: " +
                          globals.pinAddress);
                    });
                  }))
            },
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: DefaultButton(
                text: "Done",
                press: () => Navigator.pop(context),
              ),
            ),
          ),
          Positioned(top: 40, left: 0, child: ToBack()),
        ],
      ),
    );
  }
}
