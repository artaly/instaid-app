import 'package:instaid_dev/models/hotlines.dart';
import 'package:flutter/material.dart';
import 'package:instaid_dev/size_config.dart';
import 'package:instaid_dev/utils/colors.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:instaid_dev/utils/dial_emergency.dart';

class HotlineCard extends StatelessWidget {
  final Hotlines _hotlines;

  HotlineCard(this._hotlines);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.all(10),
        height: SizeConfig.screenHeight * 0.0947,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18), color: Colors.white),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _hotlines.department_name ?? "",
                style: TextStyle(
                    fontSize: getProportionateScreenHeight(15),
                    fontWeight: FontWeight.w600),
              ),
              Text(
                _hotlines.department_number ?? "",
                style: TextStyle(
                    fontSize: getProportionateScreenHeight(13),
                    fontWeight: FontWeight.w400),
              )
            ],
          ),
          IconButton(
              icon: const Icon(
                Icons.local_phone,
                color: primaryColorRed,
              ),
              onPressed: () async {
                await dialEmergency(number: _hotlines.department_number ?? "");
              }),
        ]),
      ),
    );
  }
}
