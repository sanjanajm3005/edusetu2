// import 'package:flutter/material.dart';

// class CustomeSnackbar {
//  dynamic showCustomSnackBar(
//     BuildContext context,
//     String message, {
//     Color bgColor = Colors.green,
//   }) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(message), backgroundColor: bgColor));
//   }
// }
import 'package:flutter/material.dart';

class CustomeSnackbar {
  void showCustomSnackBar(
    BuildContext context,
    String message, {
    Color bgColor = Colors.green,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
