import 'package:flutter/material.dart';
import 'package:instaid_dev/size_config.dart';
import 'package:instaid_dev/utils/colors.dart';

class CardButton extends StatelessWidget {
  const CardButton({
    required this.height,
    required this.title,
    required this.icon,
  });

  final double height;
  final String title;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
          height: SizeConfig.screenHeight * 0.14,
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.visible,
                      softWrap: true,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Color(0xFF4C5061),
                          fontWeight: FontWeight.w500,
                          fontSize: height * 0.0201),
                    ),
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.02),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [icon]),
            ],
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
