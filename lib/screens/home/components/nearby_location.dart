import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:instaid_dev/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

var _latitude = "";
var _longitude = "";

@override
void initState() {
  _updatePosition();
}

Future<void> _updatePosition() async {
  Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation);

  _latitude = pos.latitude.toString();
  _longitude = pos.longitude.toString();
}

Uri policeUrl = Uri.parse(
    "comgooglemaps://?saddr=$_latitude,$_longitude&daddr=1&destination=Police");

Widget nearestEMSLocation(double width, double height, BuildContext context) {
  return PopupMenuButton(
      onSelected: (value) async {
        HapticFeedback.selectionClick();
        if (value == 1) {
          if (await canLaunch(
              'https://www.google.com/maps/dir/?api=1&destination=Police')) {
            await launch(
                'https://www.google.com/maps/dir/?api=1&destination=Police');
          } else {
            throw 'Could not open the map.';
          }
        } else if (value == 2) {
          if (await canLaunch(
              'https://www.google.com/maps/dir/?api=1&destination=Hospital')) {
            await launch(
                'https://www.google.com/maps/dir/?api=1&destination=Hospital');
          } else {
            throw 'Could not open the map.';
          }
        } else if (value == 3) {
          if (await canLaunch(
              'https://www.google.com/maps/dir/?api=1&destination=Fire')) {
            await launch(
                'https://www.google.com/maps/dir/?api=1&destination=Fire');
          } else {
            throw 'Could not open the map.';
          }
        }
      },
      color: primaryBackground,
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Find emergency \nservices nearby',
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: width * 0.0331,
                  fontWeight: FontWeight.w600,
                  color: primaryColor
                  //fontWeight: FontWeight.bold),
                  ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 3.0),
              child: Icon(
                Icons.location_on_sharp,
                color: primaryColor,
                size: 25,
              ),
            ),
          ],
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      itemBuilder: (context) => [
            PopupMenuItem(
                value: 1,
                child: Row(
                  children: const <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(2, 2, 10, 2),
                      child: Icon(
                        Icons.local_police,
                        color: Colors.red,
                      ),
                    ),
                    Text('Police Station')
                  ],
                )),
            PopupMenuItem(
                value: 2,
                child: Row(
                  children: const <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(2, 2, 10, 2),
                      child: Icon(
                        Icons.local_hospital,
                        color: Colors.red,
                      ),
                    ),
                    Text('Hospital')
                  ],
                )),
            PopupMenuItem(
                value: 3,
                child: Row(
                  children: const <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(2, 2, 10, 2),
                      child: Icon(
                        Icons.fire_truck,
                        color: Colors.red,
                      ),
                    ),
                    Text('Fire Department')
                  ],
                )),
          ]);
}
