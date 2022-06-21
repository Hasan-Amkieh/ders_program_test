// NOTE: minimum version of android is 4.4 for the application to run,

import 'dart:async';
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
import 'package:ders_program_test/pages/loading_update_page.dart';
import 'package:restart_app/restart_app.dart';
import 'package:storage_repository/implementations/storage_repository.dart';
import 'package:storage_repository/interfaces/i_storage_repository.dart';

import 'others/departments.dart';

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

  static IStorageRepository? storageUnit;

  // NOTE: Default values are inside the function readSettings:
  static bool forceUpdate = true;
  static bool isDark = false;
  static int hourUpdate = 12; // if the time has passed for these hours since the last update, then make an update
  static String faculty = "Health Sciences";
  static String department = "NURS";
  static String language = "English"; // currently, there is only
  static ThemeMode theme = ThemeMode.system;

  static List<Subject> favCourses = [];

  static int currentScheduleIndex = 0;
  static List<Schedule> schedules = [Schedule(scheduleName: "Schedule 1", changes: [], scheduleCourses: [])];

  // NOTE: Used inside add_courses page:
  static List<Subject> coursesToAdd = [];

  static bool isEditingCourse = false; // usde to edit the course info
  static Subject? courseToEdit; // It is used to edit the course info
  static Subject emptySubject = Subject(classCode: "",
      departments: <String>[],
      teacherCodes: <List<String>>[[]],
      hours: <int>[],
      bgnPeriods: <List<int>>[],
      days: <List<int>>[],
      classrooms: <List<String>>[[]]);

  // TODO: Extract and store the semesters here:
  static List<FacultySemester> semesters = []; // each semester contains the subjects with their details

  // TODO: Save them to the settings
  static Map<String,String> classcodes = {}; // classcodes without the secion -> the full name of the class

  // TODO: Call the function save to save everything before closing the app:
  static void save() async {

    saveSettings();

  }

  static void saveSettings() async {

    await storageUnit!.set("force_update", forceUpdate);
    await storageUnit!.set("is_dark", ThemeMode.dark == theme ? ThemeMode.dark : ThemeMode.light);
    await storageUnit!.set("faculty", faculty);
    await storageUnit!.set("department", department);
    await storageUnit!.set("language", language);
    await storageUnit!.set("hour_update", hourUpdate);

    print("Settings were saved!");

  }

  static void readSettings() async {

     // TODO: Reverse it back to false
    forceUpdate = await storageUnit!.get("force_update") ?? false;
    isDark = await storageUnit!.get("is_dark") ?? false;
    theme = isDark ? ThemeMode.dark : ThemeMode.light;
    faculty = await storageUnit!.get("faculty") ?? "Health Sciences";
    department = await storageUnit!.get("department") ?? "NURS";
    language = await storageUnit!.get("language") ?? "English";
    hourUpdate = await storageUnit!.get("hour_update") ?? 12;

    // Sometimes the faculty is saved but the department is not:
    if (!(faculties[Main.faculty]?.keys as Iterable<String>).contains(department)) {
      department = faculties[Main.faculty]?.keys.elementAt(0) as String;
    }


  }

  static void restart() async {

    await Restart.restartApp();

  }

}

Future main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await StorageRepository.initFlutter();
  Main.storageUnit = StorageRepository();
  await Main.storageUnit!.init();

  Main.readSettings();

  //TODO: For test purposes:
  Main.faculty = "Health Sciences";
  Main.department = faculties[Main.faculty]?.keys.elementAt(0) as String;

  // TODO: just for test purposes, remove it later
  Main.forceUpdate = true;

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
