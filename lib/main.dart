// NOTE: minimum version of android is 4.4 for the application to run,

import 'dart:async';
import 'dart:io';
import 'package:ders_program_test/others/subject.dart';
import 'package:ders_program_test/pages/add_courses_page.dart';
import 'package:ders_program_test/pages/create_custom_course_page.dart';
import 'package:ders_program_test/pages/edit_courses_page.dart';
import 'package:ders_program_test/pages/fav_courses_page.dart';
import 'package:ders_program_test/pages/saved_schedules_page.dart';
import 'package:ders_program_test/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:ders_program_test/webpage.dart';
import 'package:ders_program_test/pages/home_page.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restart_app/restart_app.dart';

import 'others/departments.dart';

/* NOTES about the project:

* Use the following command to get the SHA256 for Androind Applinks:
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

* Some info for the deep links:

dersbottest.app.link / dersbottest-alternate.app.link

branch key: key_live_ih9S9zfR2H62HMatSvr3NhnctugTyf3W
branch secret: secret_live_IT69dUSWoQndwGZn8qHilb5ZSrJDIlf4
app name: ders_bot_test / App ID: 1068179538950771279

* Free Subscription WARNING:
* Branch IO only provides 10k MAUS (10 thousands of Monthly Active Users),
, means if the active users go higher than 10k users, then I have to pay 5 USD for 1K for each month

*
*/

/*

TODO: These following comments state the things to do in the long term inside the application:

- Look into the file inside the website "ttviewer.js?...=getTTviewData"

- Add the medical department using the following page https://www.atilim.edu.tr/en/tip/page/4804/course-schedule

- Inisde some faculties, there are some special departments, like "Her gun" or "General Electives",
make them scanned and addaed into the DropList to be chosen, excluse all the deps of "CMPE 1 Reg." and etc...

- Inside the Add Custom Course page, add two choises of CheckBoxes, both basically say "Link Teachers/Classrooms", if it is checked,
then the teacher/classroom text fields are moved from the periods into the bottom of the Course Code field.

*/


class Main {

  static File? settingsStorage;

  static String appDocDir = "";

  // NOTE: Default values are inside the function readSettings:
  static bool forceUpdate = true;
  static bool isDark = false;
  static int hourUpdate = 12; // if the time has passed for these hours since the last update, then make an update
  static String faculty = "Engineering";
  static String department = "AE";
  static String language = "English"; // currently, there is only
  static ThemeMode theme = ThemeMode.system;
  static DateTime lastUpdated = DateTime.now();

  static List<Course> favCourses = [];

  static int currentScheduleIndex = 0;
  static List<Schedule> schedules = [];

  // NOTE: Used inside add_courses page:
  static List<Subject> coursesToAdd = [];

  static bool isEditingCourse = false; // usde to edit the course info
  static Subject? courseToEdit; // It is used to edit the course info
  static Subject emptySubject = Subject(customName: "",
      classCode: "",
      departments: <String>[],
      teacherCodes: <List<String>>[[]],
      hours: <int>[],
      bgnPeriods: <List<int>>[],
      days: <List<int>>[],
      classrooms: <List<String>>[[]]);

  // TODO: Extract and store the semesters here:
  static List<FacultySemester> semesters = []; // each semester contains the subjects with their details

  // TODO: Call the function save to save everything before closing the app:
  static void save() async {

    saveSettings();

  }

  static void saveSettings() async {

    String toWrite = "";
    try {
      final file = File('${Main.appDocDir}/settings.txt'); // FileSystemException

      toWrite = toWrite + "force_update:"+forceUpdate.toString()+"\n";
      toWrite = toWrite + "is_dark:"+isDark.toString()+"\n";
      toWrite = toWrite + "faculty:"+faculty.toString()+"\n";
      toWrite = toWrite + "department:"+department.toString()+"\n";
      toWrite = toWrite + "language:"+language.toString()+"\n";
      toWrite = toWrite + "hour_update:"+hourUpdate.toString()+"\n";
      toWrite = toWrite + "last_updated:"+lastUpdated.microsecondsSinceEpoch.toString()+"\n";

      await file.writeAsString(toWrite, mode: FileMode.write);

    } catch(err) {
      print("The settings file was not opened bcs: $err");
    }

    print("Settings were saved!");

  }

  static void readSettings() async {

    String content = "";
    try {
      final file = File('${Main.appDocDir}/settings.txt'); // FileSystemException

      content = file.readAsStringSync();
      if (content.isNotEmpty) {
        print("Settings were found with the content of: $content");

        forceUpdate = content.substring(content.indexOf("force_update:") + 13, content.indexOf("\n", content.indexOf("force_update:") + 13)) == "true" ? true : false;
        isDark = content.substring(content.indexOf("is_dark:") + 8, content.indexOf("\n", content.indexOf("is_dark:") + 8)) == "true" ? true : false;
        theme = isDark ? ThemeMode.dark : ThemeMode.light;
        faculty = content.substring(content.indexOf("faculty:") + 8, content.indexOf("\n", content.indexOf("faculty:") + 8));
        department = content.substring(content.indexOf("department:") + 11, content.indexOf("\n", content.indexOf("department:") + 11));
        language = content.substring(content.indexOf("language:") + 9, content.indexOf("\n", content.indexOf("language:") + 9));
        hourUpdate = int.parse(content.substring(content.indexOf("hour_update:") + 12, content.indexOf("\n", content.indexOf("hour_update:") + 12)));
        lastUpdated = DateTime.fromMicrosecondsSinceEpoch(int.parse(content.substring(content.indexOf("last_updated:") + 13, content.indexOf("\n", content.indexOf("last_updated:") + 13))));

      }
    } catch(err) {
      print("The settings file was not opened bcs: $err");
    }

    // Sometimes the faculty is saved but the department is not:
    // if (!(faculties[Main.faculty]?.keys as Iterable<String>).contains(department)) {
    //   department = faculties[Main.faculty]?.keys.elementAt(0) as String;
    // }


  }

  static void restart() async { // Updated: whenever the app is restarted, it will save automatically!

    Main.save();
    Restart.restartApp().then((value) { ; });

  }

}

Future main() async {

  print("EXECUTING MAIN FUNCTION!!!");

  WidgetsFlutterBinding.ensureInitialized();
  Main.appDocDir = (await getApplicationDocumentsDirectory()).path;
  await [Permission.storage].request().then((value_) {
    if (!value_.toString().contains(".granted")) {
      print("The premission of storage was not granted! Restarting the app!");
      Main.restart();
    } else {
      print("The premission of storage was granted!");
    }
  });

  ;
  Main.readSettings();

  // NOTE: For test purposes:
  // Main.language = "English";
  // Main.faculty = "Engineering";
  // Main.department = faculties[Main.faculty]?.keys.elementAt(0) as String;

  // TODO: just for test purposes, remove it later
  Main.forceUpdate = true;

  Main.schedules.add(Schedule(scheduleName: "Schedule 1", scheduleCourses: []));
  Main.currentScheduleIndex = 0;

  print("update is ${Main.forceUpdate}");

  runApp(MaterialApp(
    themeMode: Main.theme,
    //theme: AppThemes.lightTheme,
    //darkTheme: AppThemes.darkTheme,
    initialRoute: Main.forceUpdate ? "/webpage" : "/home",
    routes: {
      "/home" : (context) => Home(),
      "/webpage": (context) => Webpage(),
      "/home/searchcourses": (contetx) => const SearchPage(),
      "/home/favcourses": (context) => FavCourses(),
      "/home/editcourses": (context) => EditCoursePage(),
      "/home/editcourses/addcourses": (context) => AddCoursesPage(),
      "/home/editcourses/createcustomcourse": (context) => CustomCoursePage(),
      "/home/editcourses/editcourseinfo": (context) { CustomCoursePage page = CustomCoursePage(); page.subject = Main.courseToEdit ?? Main.emptySubject; return page; },
      "/home/savedschedules" : (context) => SavedSchedulePage(),
    },
  ));

}
