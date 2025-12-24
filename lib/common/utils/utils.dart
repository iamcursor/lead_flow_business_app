import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart' as mobile_toast;

class Utils {
  static void fieldFocusChange(
      BuildContext context, FocusNode current, FocusNode nextFocus) {
    current.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  static void toastMessage({required String message, required Color color,Duration? duration}) {
      mobile_toast.Fluttertoast.showToast(
        msg: message,
        toastLength: duration == null ? mobile_toast.Toast.LENGTH_SHORT : mobile_toast.Toast.LENGTH_LONG ,
        gravity: mobile_toast.ToastGravity.BOTTOM,
        backgroundColor: color,
        textColor: Colors.white,
      );

  }

  // static snackBar(String message,Color color, BuildContext context) {
  //   return ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       backgroundColor: color,
  //     ),
  //   );
  // }
}