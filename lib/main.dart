// NOTE: minimum version of android is 4.4 for the application to run,

import 'dart:async';
import 'package:ders_program_test/others/subject.dart';
import 'package:ders_program_test/pages/favcourses.dart';
import 'package:ders_program_test/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:ders_program_test/webpage.dart';
import 'package:ders_program_test/pages/home.dart';
import 'package:ders_program_test/pages/loadingupdate.dart';
import 'package:restart_app/restart_app.dart';
import 'package:storage_repository/implementations/storage_repository.dart';
import 'package:storage_repository/interfaces/i_storage_repository.dart';

import 'others/AppThemes.dart';

class Main {

  static IStorageRepository? storageUnit;

  static bool forceUpdate = false;
  static bool isDark = false;
  static int hourUpdate = 12; // if the time has passed for these hours since the last update, then make an update
  static String faculty = "Fine Arts";
  static String department = "GRT";
  static String language = "English"; // currently, there is only
  static ThemeMode theme = ThemeMode.light;

  static List<Subject> favCourses = [];
  static List<Subject> scheduleCourses = []; // current schedule courses

  // TODO: Extract and store the semesters here:
  static List<FacultySemester> semesters = []; // each semester contains the subjects with their details


  // TODO: Save them to the settings
  static Map<String,String> classcodes = {}; // classcodes without the secion -> the full name of the class

  // TODO: Call the function save to save everything before closing the app:
  static void save() async {

    saveSettings();

    //sleep(Duration(seconds:2));

  }

  static void saveSettings() async {

    await storageUnit!.set("force_update", forceUpdate);
    await storageUnit!.set("is_dark", isDark);
    await storageUnit!.set("faculty", faculty);
    await storageUnit!.set("department", department);
    await storageUnit!.set("language", language);
    await storageUnit!.set("hour_update", hourUpdate);
    // await will assure that every info will be written before finishing the function

    print("Settings have been saved successfully $faculty");

  }

  static void readSettings() async {

     // TODO: Reverse it back to false
    forceUpdate = await storageUnit!.get("force_update") ?? false;
    isDark = await storageUnit!.get("is_dark") ?? false;
    theme = await isDark ? ThemeMode.dark : ThemeMode.light;
    faculty = await storageUnit!.get("faculty") ?? "Fine Arts";
    department = await storageUnit!.get("department") ?? "GRT";
    language = await storageUnit!.get("language") ?? "English";
    hourUpdate = await storageUnit!.get("hour_update") ?? 12; //


  }

  static void restart() async {

    print("Result of the restart: ${await Restart.restartApp()}");

  }

}

Future main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await StorageRepository.initFlutter();

  //Instantiate a basic storage repository
  Main.storageUnit = StorageRepository();
  //or use a secure version of storage repository
  //final storageRepository = SecureStorageRepository();
  //init must be called, preferably right after the instantiation
  await Main.storageUnit!.init();

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

  // TODO: Before, check if we have
  Main.readSettings();

  // just for test purposes, remove it later
  Main.forceUpdate = true;

  //WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    themeMode: Main.theme,
    theme: AppThemes.lightTheme,
    darkTheme: AppThemes.darkTheme,
    initialRoute: Main.forceUpdate ? "/webpage" : "/home",
    routes: {
      "/home" : (context) => Home(),
      "/loadingupdate": (context) => LoadingUpdate(),
      "/webpage": (context) => Webpage(),
      "/home/searchpage": (contetx) => const SearchPage(),
      "/home/favcourses": (context) => FavCourses(),
    },
  ));

}
