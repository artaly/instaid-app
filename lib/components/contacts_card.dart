import 'package:flutter/material.dart';
import 'package:instaid_dev/resources/firestore_methods.dart';
import 'package:instaid_dev/utils/colors.dart';

import '../models/contacts.dart';
import '../models/user_model.dart';
import '../size_config.dart';

class ContactsCard extends StatelessWidget {
  const ContactsCard(
      {required this.list, required this.index, required this.update});
  final List<ContactsData> list;
  final int index;
  final Function update;
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
                list[index].name,
                style: TextStyle(
                    fontSize: SizeConfig.screenHeight * 0.0213,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                list[index].number,
                style: TextStyle(
                    fontSize: SizeConfig.screenHeight * 0.0189,
                    fontWeight: FontWeight.w400),
              )
            ],
          ),
          IconButton(
              icon: const Icon(
                Icons.delete,
                color: primaryColorRed,
              ),
              onPressed: () {
                update(index);
                updateContactList();
              }),
        ]),
      ),
    );
  }
}
