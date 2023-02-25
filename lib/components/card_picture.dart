import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instaid_dev/utils/colors.dart';

class CardPicture extends StatelessWidget {
  CardPicture({this.onTap, this.backgroundImage, this.cardLabel});

  final Function()? onTap;
  final ImageProvider? backgroundImage;
  final String? cardLabel;
  //final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (backgroundImage != null) {
      return Card(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          width: size.width * .90,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
            image: backgroundImage != null
                ? DecorationImage(
                    image: backgroundImage!,
                    fit: BoxFit.cover,
                  )
                : null,
          ),
        ),
      );
    }

    return Card(
        elevation: 3,
        child: InkWell(
          onTap: this.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 25),
            width: size.width * .90,
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cardLabel ?? '',
                  style: TextStyle(fontSize: 17.0, color: Colors.grey[600]),
                ),
                const Icon(
                  Icons.photo_camera,
                  color: primaryColor,
                )
              ],
            ),
          ),
        ));
  }
}
