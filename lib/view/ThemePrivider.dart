import 'package:flutter/material.dart';

class ThemeManager {
  static Color  primaryColor = const Color.fromARGB(255, 212, 174, 241);
  static Color secondaryColor = const Color.fromARGB(255, 222, 206, 235);
  static Color  topContainerColor = const Color(0xFF4a4e69);
  static  Color otherColor = const Color.fromARGB(255, 57, 57, 95);
   static  Color otherColor2 = const Color.fromARGB(255, 54, 54, 75);
  static Color ButtColor =  const Color(0xFFd5bdaf);


  static void setTheme(String theme) {
    switch (theme.toLowerCase()) {
      case "purple":
        primaryColor = const Color.fromARGB(255, 212, 174, 241);
        secondaryColor = const Color.fromARGB(255, 222, 206, 235);
        topContainerColor = const Color(0xFF4a4e69);
        otherColor = const Color.fromARGB(255, 57, 57, 95);
       otherColor2 = const Color.fromARGB(255, 54, 54, 75);
         ButtColor =  const Color(0xFFd5bdaf);
        break;
      case "blue":
        primaryColor = const Color.fromARGB(255, 181, 224, 238);
        secondaryColor = const Color.fromARGB(255, 194, 206, 216);
        topContainerColor =const Color(0xFF778da9);
        otherColor = const Color.fromARGB(255, 46, 83, 105);
        otherColor2 = const Color.fromARGB(255, 48, 72, 87);
         ButtColor =  const Color(0xFFb0c4b1);
        break;
      case "green":
        primaryColor = const Color.fromARGB(255, 138, 219, 138);
        secondaryColor = const Color.fromARGB(255, 197, 230, 200);
        topContainerColor =  const Color(0xFF2d6a4f);
        otherColor = const Color.fromARGB(255, 60, 102, 54);
         otherColor2 = const Color.fromARGB(255, 68, 95, 65);
       ButtColor =  const Color.fromARGB(255, 185, 224, 193);
        break;
      case "yellow":
        primaryColor = const Color.fromARGB(221, 199, 192, 135);
        secondaryColor = const Color.fromARGB(255, 252, 236, 147);
        topContainerColor =const Color.fromARGB(223, 177, 172, 105);
        otherColor =  const Color.fromARGB(255, 143, 138, 73);
         otherColor2 = const Color.fromARGB(255, 204, 197, 146);
         ButtColor =  const Color.fromARGB(255, 173, 173, 135);
        break;
      case "orange":
        primaryColor = const Color.fromARGB(255, 235, 197, 122);
        secondaryColor = const Color.fromARGB(255, 224, 198, 155);
        topContainerColor = const Color(0xFFdb7c26);
        otherColor = const Color.fromARGB(255, 112, 73, 45);
         otherColor2 = const Color.fromARGB(255, 151, 85, 38);
         ButtColor =  const Color(0xFFe9c46a);
        break;
      default:
        primaryColor =const Color.fromARGB(255, 212, 174, 241);
        secondaryColor = const Color(0xFFF3E9FB);
        topContainerColor =const Color(0xFF4a4e69);
        otherColor = const Color.fromARGB(255, 57, 57, 95);
        otherColor2 = const Color.fromARGB(255, 54, 54, 75);
       ButtColor =  const Color(0xFFd5bdaf);
    }
  }
}
