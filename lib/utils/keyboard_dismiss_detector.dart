import 'package:flutter/material.dart';

class KeyboardDismissDetector extends StatelessWidget {
  final Widget child;

  const KeyboardDismissDetector({Key? key, required this.child})
      : super(key: key);

  static void loseFocus(context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  static void requestFocus(context) =>
      FocusScope.of(context).requestFocus(FocusNode());

  @override 
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => loseFocus(context),
      child: child,
    );
  }

}
