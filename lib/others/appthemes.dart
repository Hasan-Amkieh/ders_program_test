import 'package:ders_program_test/main.dart';
import 'package:flutter/material.dart';

/*const List<List<Color>> darkThemeScheduleColors = [ // TODO: Complete this: // Or maybe not! / maybe use both for white and dark themes!
  [Colors.blue, Colors.grey], // The first is for background color, the second is text color,
];*/

const List<List<Color>> whiteThemeScheduleColors = [
  [Color.fromRGBO(84, 125, 141, 1.0), Colors.white],
  [Color.fromRGBO(102, 132, 89, 1.0), Colors.white],
  [Color.fromRGBO(141, 163, 153, 1.0), Colors.white],
  [Color.fromRGBO(70, 136, 185, 1.0), Colors.white],
  [Color.fromRGBO(38, 110, 115, 1.0), Colors.white],
  [Color.fromRGBO(104, 184, 161, 1.0), Colors.white],
  [Color.fromRGBO(54, 117, 136, 1.0), Colors.white],
  [Color.fromRGBO(50, 134, 149, 1.0), Colors.white],
  [Color.fromRGBO(10, 166, 62, 1.0), Colors.white],
  [Color.fromRGBO(128, 105, 103, 1.0), Colors.white],
  [Color.fromRGBO(20, 130, 200, 1.0), Colors.white],
  [Color.fromRGBO(215, 194, 135, 1.0), Colors.white],
  [Color.fromRGBO(93, 138, 168, 1.0), Colors.white],
  [Color.fromRGBO(118, 171, 223, 1.0), Colors.white],
];


class AppTheme {

  TextStyle headerStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Main.theme == ThemeMode.light ? Colors.black : Colors.white);

  Color normalTextColor = Main.theme == ThemeMode.light ? Colors.blue : Colors.white;

  Color titleTextColor = Main.theme == ThemeMode.light ? Colors.black : Colors.white;

  Color subtitleTextColor = Main.theme == ThemeMode.light ? Colors.grey.shade600 : Colors.grey.shade400;

  TextStyle headerSchedulePageTextStyle = const TextStyle(color: Colors.white, fontWeight: FontWeight.bold);

  Color headerBackgroundColor = Main.theme == ThemeMode.light ? Colors.blue : Colors.grey.shade900;

  Color periodBackgroundColor = Main.theme == ThemeMode.light ? Colors.grey.shade50 : const Color.fromRGBO(13, 38, 35, 1.0).withOpacity(0.8);

  Color scheduleBackgroundColor = Main.theme == ThemeMode.light ? Colors.grey.shade200 : Colors.grey.shade800;

  Color navigationBarColor = Main.theme == ThemeMode.light ? const Color.fromRGBO(80, 114, 150, 1.0) : const Color.fromRGBO(48, 48, 48, 1.0);

  Color navIconColor = Main.theme == ThemeMode.light ? Colors.black : Colors.white;

  Color titleIconColor = Main.theme == ThemeMode.light ? Colors.grey.shade700 : Colors.white;

  Color scaffoldBackgroundColor = Main.theme == ThemeMode.light ? Colors.white : const Color.fromRGBO(13, 38, 35, 1.0);

  Color emptyCellColor = Main.theme == ThemeMode.light ? Colors.white : Colors.grey.shade800;

  Color textfieldBackgroundColor = Main.theme == ThemeMode.light ? Colors.white : Colors.grey.shade600;

  Brightness keyboardTheme = Main.theme == ThemeMode.light ? Brightness.light : Brightness.dark;

  AppTheme() {
    ;
  }

}
