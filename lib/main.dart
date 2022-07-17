// NOTE: minimum version of android is 4.4 for the application to run,

import 'dart:async';
import 'dart:io';
import 'package:ders_program_test/language/dictionary.dart';
import 'package:ders_program_test/others/subject.dart';
import 'package:ders_program_test/pages/add_courses_page.dart';
import 'package:ders_program_test/pages/create_custom_course_page.dart';
import 'package:ders_program_test/pages/edit_courses_page.dart';
import 'package:ders_program_test/pages/fav_courses_page.dart';
import 'package:ders_program_test/pages/no_internet_page.dart';
import 'package:ders_program_test/pages/personalinfo.dart';
import 'package:ders_program_test/pages/saved_schedules_page.dart';
import 'package:ders_program_test/pages/scheduler_page.dart';
import 'package:ders_program_test/pages/search_page.dart';
import 'package:flutter/material.dart';
import 'package:ders_program_test/webpage.dart';
import 'package:ders_program_test/pages/home_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restart_app/restart_app.dart';

import 'others/appthemes.dart';

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

- Add a section inside the links page that shows upcoming important days from the schools page link, like add/drop period, courses drop period etc...

*/


class Main {

  static File? settingsStorage;

  static String appDocDir = "";

  // NOTE: Default values are inside the function readSettings:
  static bool forceUpdate = false;
  static int hourUpdate = 12; // if the time has passed for these hours since the last update, then make an update
  static String faculty = "Engineering";
  static String department = "AE";
  static String language = "English"; // currently, there is only
  static ThemeMode theme = ThemeMode.system;

  static AppTheme appTheme = AppTheme();

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

  static late FacultySemester facultyData;

  static bool isInternetOn = true;

  static void save() async {

    writeSettings();
    writeSchedules();
    writeFacultyCourses();
    writeFavCourses();

  }

  static void writeSettings() async {

    String toWrite = "";
    final file = File('${Main.appDocDir}/settings.txt'); // FileSystemException

    toWrite = toWrite + "force_update:"+forceUpdate.toString()+"\n";
    toWrite = toWrite + "is_dark:"+(Main.theme == ThemeMode.dark).toString()+"\n";
    toWrite = toWrite + "faculty:"+faculty.toString()+"\n";
    toWrite = toWrite + "department:"+department.toString()+"\n";
    toWrite = toWrite + "language:"+language.toString()+"\n";
    toWrite = toWrite + "hour_update:"+hourUpdate.toString()+"\n";

    file.writeAsStringSync(toWrite, mode: FileMode.write);

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
        theme = (content.substring(content.indexOf("is_dark:") + 8, content.indexOf("\n", content.indexOf("is_dark:") + 8)) == "true" ? true : false) ? ThemeMode.dark : ThemeMode.light;
        faculty = content.substring(content.indexOf("faculty:") + 8, content.indexOf("\n", content.indexOf("faculty:") + 8));
        department = content.substring(content.indexOf("department:") + 11, content.indexOf("\n", content.indexOf("department:") + 11));
        language = content.substring(content.indexOf("language:") + 9, content.indexOf("\n", content.indexOf("language:") + 9));
        hourUpdate = int.parse(content.substring(content.indexOf("hour_update:") + 12, content.indexOf("\n", content.indexOf("hour_update:") + 12)));
      }
    } catch(err) {
      print("The settings file was not opened bcs: $err");
    }

    appTheme = AppTheme(); // this will set the styles depending on the current theme

  }

  static void writeSchedules() {

    // first delete all the schedules, then write all the schedules again:

    Directory dir = Directory(Main.appDocDir);

    // List directory contents, recursing into sub-directories,
    // but not following symbolic links.
    List<FileSystemEntity> files = dir.listSync();

    for (int i = 0 ; i < files.length ; i++) {

      if (files[i].toString().contains("schedule_")) {
        files[i].deleteSync();
      }

    }

    for (int i = 0 ; i < schedules.length ; i++) {

      File file = File("${Main.appDocDir}/schedule_${Main.schedules[i].scheduleName}.txt");
      String toWrite = "";

      for (int j = 0 ; j < schedules[i].scheduleCourses.length ; j++) { // notes:

        toWrite = toWrite + schedules[i].scheduleCourses[j].note;

        if ((j + 1) < schedules[i].scheduleCourses.length) { // if it is not the last,
          toWrite = toWrite + "\n/ /\n";
        }

      }

      toWrite = toWrite + "////\n";

      for (int j = 0 ; j < schedules[i].scheduleCourses.length ; j++) { // courses:

        toWrite = toWrite + schedules[i].scheduleCourses[j].subject.classCode + "|" + schedules[i].scheduleCourses[j].subject.toString() + "\n";

      }

      print("The schedule ${Main.schedules[i].scheduleName} is written with the content of: \n\n$toWrite\n\n\n");

      file.writeAsStringSync(toWrite);

    }

  }

  static void readSchedules() {

    Directory dir = Directory(Main.appDocDir);

    // List directory contents, recursing into sub-directories,
    // but not following symbolic links.
    List<FileSystemEntity> files = dir.listSync();

    //print("All the files are: $files");

    for (int i = 0 ; i < files.length ; i++) {

      if (files[i].toString().contains("schedule_")) {

        print("Opening file: ${files[i].toString()}");
        File file = File(files[i].path);
        if (file.existsSync()) {
          print("The file EXISTED!!!!");

          String content = file.readAsStringSync();
          if (content.replaceAll("////\n", "").isEmpty) {
            print("The file is empty, finding another file!");
            continue;
          }

          //print("File content is: $content");

          String scheduleName = files[i].toString().substring(files[i].toString().indexOf("schedule_") + 9).replaceAll(".txt", "").replaceAll("'", "");
          print("The schedule name is $scheduleName");

          List<String> notes = content.split("////\n").elementAt(0).split('\n/ /\n');
          // the notes and the courses are seperated by "////\n" but each note is seperatoed by "\n/ /\n"

          List<String> courses = content.split("////\n").elementAt(1).split("\n");

          List<Course> courses_ = [];
          int index = 0;
          courses = courses.where((element) => element.trim().isNotEmpty).toList();
          courses.forEach((course) { print("Doing $course"); courses_.add(Course(subject: Subject.fromStringWithClassCode(course), note: notes[index < notes.length ? index : 0])); index++; });

          //courses_.forEach((element) {print(element.subject.toString());});
          Main.schedules.add(Schedule(scheduleName: scheduleName, scheduleCourses: courses_));

        }

      }

    }

  }

  static void restart() async { // Updated: whenever the app is restarted, it will save automatically!
    // sometimes, we need normal restart without saving, so remember to call Restart.restartApp() directly!

    Main.save();
    Restart.restartApp().then((value) { ; });

  }

  static void writeFacultyCourses() {

    File file = File("${Main.appDocDir}/faculty_courses.txt");
    if (file.existsSync()) {
      file.deleteSync();
    }

    file = File("${Main.appDocDir}/faculty_courses.txt");
    String toWrite = "";

    toWrite = toWrite + Main.faculty + "\n";
    toWrite = toWrite + Main.facultyData.lastUpdate.microsecondsSinceEpoch.toString() + "\n";
    for (int i = 0 ; i < Main.facultyData.subjects.length ; i++) {

      toWrite = toWrite + Main.facultyData.subjects[i].classCode + "|" + Main.facultyData.subjects[i].toString() + "\n";

    }
    //print("Writing the subjects: $toWrite");
    file.writeAsStringSync(toWrite);

  }

  static void readFacultyCourses() {

    File file = File("${Main.appDocDir}/faculty_courses.txt");

    if (file.existsSync()) {

      print("The faculty courses exists!");

      List<String> lines = file.readAsStringSync().split("\n");
      String facultyName = lines[0];
      if (facultyName != Main.faculty) {
        Main.forceUpdate = true;
        print("The faculties are different, updating!");
        return;
      }
      lines.removeAt(0);

      DateTime lastUpdated = DateTime.fromMicrosecondsSinceEpoch(int.parse(lines[0]));
      print("Time difference is ${DateTime.now().difference(lastUpdated).inHours}, updating!");
      if (DateTime.now().difference(lastUpdated).inHours >= Main.hourUpdate) {
        print("Time difference is ${DateTime.now().difference(lastUpdated).inHours}, updating!");
        Main.forceUpdate = true;
        return;
      }
      lines.removeAt(0);

      int index = 0;
      lines = lines.where((element) => element.trim().isNotEmpty).toList();
      Main.facultyData = FacultySemester(facName: facultyName, lastUpdate: lastUpdated);
      lines.forEach((course) { Main.facultyData.subjects.add(Subject.fromStringWithClassCode(course)); index++; });

    } else {
      print("The faculty courses DID NOT exist!");
      Main.forceUpdate = true;
    }

  }

  static void readFavCourses() {

    File file = File("${Main.appDocDir}/fav_courses.txt");

    if (file.existsSync()) {

      print("Favourite courses exists!");

      List<String> sections = file.readAsStringSync().split("////\n");
      List<String> notes = sections[0].split("\n/ /\n");
      List<String> courses = sections[1].split("\n");

      int index = 0;
      courses = courses.where((element) => element.trim().isNotEmpty).toList();
      courses.forEach((course) { Main.favCourses.add(Course(subject: Subject.fromStringWithClassCode(course), note: notes[index])); index++; });

    } else {
      print("Favourite courses DID NOT exist!");
    }

  }

  static void writeFavCourses() {

    File file = File("${Main.appDocDir}/fav_courses.txt");
    String toWrite = "";

    for (int i = 0 ; i < Main.favCourses.length ; i++) {

      toWrite = toWrite + Main.favCourses[i].note;
      if (i + 1 < Main.favCourses.length) { // if it is not the lats note:
        toWrite = toWrite + "\n/ /\n";
      }

    }

    toWrite = toWrite + "////\n";
    for (int i = 0 ; i < Main.favCourses.length ; i++) {

      toWrite = toWrite + Main.favCourses[i].subject.classCode + "|" + Main.facultyData.subjects[i].toString() + "\n";

    }

    file.writeAsStringSync(toWrite);

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

  Main.readSchedules();
  Main.readSettings();
  if (!Main.forceUpdate) {
    Main.readFacultyCourses();
  }
  Main.readFavCourses();

  if (Main.schedules.isEmpty) {
    Main.schedules.add(Schedule(scheduleName: translateEng("Default Schedule"), scheduleCourses: []));
  }
  // TODO: Store the schedule index along the settings file inside writeSettings and readSettings:
  Main.currentScheduleIndex = 0;

  if (Main.forceUpdate) { // if we are going to update then check for internet:
    await NoInternetPageState.checkInternet();
  }

  runApp(MaterialApp(
    initialRoute: Main.isInternetOn ? (Main.forceUpdate ? "/webpage" : "/home") : "/nointernet",
    routes: {
      "/nointernet" : (context) => NoInternetPage(),
      "/home" : (context) => Home(),
      "/webpage": (context) => Webpage(),
      "/home/searchcourses": (contetx) => const SearchPage(),
      "/home/favcourses": (context) => FavCourses(),
      "/home/editcourses": (context) => EditCoursePage(),
      "/home/editcourses/addcourses": (context) => AddCoursesPage(),
      "/home/editcourses/createcustomcourse": (context) => CustomCoursePage(),
      "/home/editcourses/editcourseinfo": (context) { CustomCoursePage page = CustomCoursePage(); page.subject = Main.courseToEdit ?? Main.emptySubject; return page; },
      "/home/savedschedules" : (context) => SavedSchedulePage(),
      "/home/personalinfo" : (context) => PersonalInfo(),
      "/home/scheduler" : (context) => SchedulerPage(),
    },
  ));

}
