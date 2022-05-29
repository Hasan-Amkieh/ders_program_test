// NOTE: minimum version of android is 4.4 for the application to run,

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ders_program_test/webpage.dart';
import 'package:ders_program_test/home.dart';
import 'package:ders_program_test/loadingupdate.dart';
import 'package:ders_program_test/subject.dart';

class Main {

  static final settingsUnit = GetStorage("settings");
  static DateTime lastUpdate = DateTime.now();
  static bool toUpdate = false;
  static bool isDark = false;
  static final hourUpdate = 12; // if the time has passed for these hours since the last update, then make an update

  static List<Semester> semesters = []; // each semester contains the subjects with their details

  // update section
  static Map<String,String> classcodes = {}; // classcodes without the secion -> the full name of the class
// update section

}

Future main() async {

  // TODO: Store this into a function which takes two DateTime objects and returns a bool
  /*Map<String, int> rawTime = engCoursesUnit.read("Time") ?? {};
  if (rawTime.isEmpty) {
    toUpdate = true;
  } else {
    int y = rawTime['y'] ?? currentTime.year,
        m = rawTime['m'] ?? currentTime.month,
        d = rawTime['d'] ?? currentTime.day,
        h = rawTime['h'] ?? currentTime.hour;
    if (currentTime.compareTo(DateTime(y, m, d, h)) ==
        1) { // the time is in the past
      if (currentTime.month > m || currentTime.day > d ||
          currentTime.hour - hourUpdate > h)
        toUpdate = true;
    }
  }*/


  Main.toUpdate = false; // just for test purposes, remove it later

  //WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    initialRoute: Main.toUpdate ? "/webpage" : "/home",
    routes: {
      "/home" : (context) => Home(),
      "/loadingupdate": (context) => LoadingUpdate(),
      "/webpage": (context) => Webpage(),
    },
  ));

}
