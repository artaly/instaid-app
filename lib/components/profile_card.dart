import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instaid_dev/size_config.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    required this.height,
    required this.title,
    required this.icon,
    required this.inputFormatters,
    required this.editmode,
    required this.unit,
    required this.controller,
    required this.onChanged,
    this.keyboardType = TextInputType.name,
  });

  final double height;
  final String title;
  final Icon icon;
  final bool editmode;
  final List<TextInputFormatter> inputFormatters;
  final String unit;
  final TextEditingController controller;
  final void Function(String) onChanged;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: Theme.of(context).dividerColor, width: 1)),
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
                      title,
                      overflow: TextOverflow.visible,
                      softWrap: true,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: height * 0.0201),
                    ),
                  ),
                  icon,
                ],
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.03),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: false,
                      textAlign: TextAlign.left,
                      readOnly: editmode ? false : true,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: height * 0.037),
                      keyboardType: keyboardType,
                      //textInputAction: TextInputAction.continueAction,
                      controller: controller,
                      inputFormatters: inputFormatters,
                      onChanged: onChanged,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                            fontSize: height * 0.0186,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  Text(unit),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
