import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({this.size = 50, required this.imagePath});
  final double size;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final image = NetworkImage(imagePath);
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60),
          image: DecorationImage(image: image, fit: BoxFit.cover),
          //shape: BoxShape.rectangle,
          color: Color(0xffc7c9cd)),
    );
  }
}
