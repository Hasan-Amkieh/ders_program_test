// NOTE: minimum version of android is 4.4 for the application to run,

import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:Atsched/pages/exams_page.dart';
import 'package:Atsched/pages/schedule_notification_page.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
// import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:intl/intl.dart';

import 'package:Atsched/classifiers/atilim_classifier.dart';
import 'package:Atsched/others/university.dart';
import 'package:Atsched/pages/choose_settings_page.dart';
import 'package:Atsched/pages/empty_classrooms_page.dart';
import 'package:Atsched/pages/windows_webview_unsupported_page.dart';
import 'package:Atsched/scrapers/atilim_scraper_computer.dart';
import 'package:Atsched/scrapers/bilkent_scraper_computer.dart';
import 'package:Atsched/scrapers/bilkent_scraper_phone.dart';
import 'package:Atsched/scrapers/scraper.dart';
import 'package:Atsched/wp_computer.dart';

import 'dart:core';
import 'dart:io';
import 'package:Atsched/language/dictionary.dart';
import 'package:Atsched/others/subject.dart';
import 'package:Atsched/pages/add_courses_page.dart';
import 'package:Atsched/pages/create_custom_course_page.dart';
import 'package:Atsched/pages/edit_courses_page.dart';
import 'package:Atsched/pages/fav_courses_page.dart';
import 'package:Atsched/pages/no_internet_page.dart';
import 'package:Atsched/pages/personalinfo.dart';
import 'package:Atsched/pages/saved_schedules_page.dart';
import 'package:Atsched/pages/scheduler_page.dart';
import 'package:Atsched/pages/scheduler_result_page.dart';
import 'package:Atsched/pages/search_page.dart';
import 'package:Atsched/pages/update_page.dart';
import 'package:flutter/material.dart';
import 'package:Atsched/wp_phone.dart';
import 'package:Atsched/pages/home_page.dart';
import 'package:oktoast/oktoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:restart_app/restart_app.dart';
import 'package:new_version/new_version.dart';
import 'package:worker_manager/worker_manager.dart';

import 'classifiers/bilkent_classifier.dart';
import 'classifiers/classifier.dart';
import 'others/appthemes.dart';

/* NOTES about the project:

* Use the following command to get the SHA256 for Androind Applinks:
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

* Free Subscription WARNING:
* Branch IO only provides 10k MAUS (10 thousands of Monthly Active Users),
, means if the active users go higher than 10k users, then I have to pay 5 USD for 1K for each month


*/

class Main {

  static const String atschedVersionForWindows = "1.3.0.0";

  static NewVersion newVersion = NewVersion(
      //iOSId: 'com.google.Vespa',
      androidId: 'amkieh.hasan.atsched',
  );
  static late VersionStatus? versionStatus;

  static late PackageInfo packageInfo;

  static String appDocDir = "";

  static bool firstTime = false;

  static String semesterName = "";

  static List<String> unis = [
    "Atilim",
    "Bilkent"
  ];

  static late Classifier classifier;
  static late Scraper scraper;

  static int classroomsCountForCurHr = 0;

  static List<Classroom> classrooms = [];

  // NOTE: Default values are inside the function readSettings:
  static bool forceUpdate = false;
  static int hourUpdate = 48; // if the time has passed for these hours since the last update, then make an update
  static String faculty = "Engineering";
  static String department = "AE";
  static String language = "English"; // currently, there is only
  static String uni = "Atilim";
  static ThemeMode theme = ThemeMode.dark;
  static bool isThereNewerVersion = false;
  static bool isFacChange = false;

  static double days = 2;

  static String newFaculty = "";
  static String newUni = "";
  static bool isUniChange = false;

  static String artsNSciencesLink = "";
  static String fineArtsLink = "";
  static String lawLink = "";
  static String businessLink = "";
  static String engineeringLink = "";
  static String healthSciencesLink = "";
  static String civilAviationLink = "";

  static bool isAttemptedBefore = false; // if true AND the update does not work, then:
  // check if isFacDataFilled is false, then block the following tools: add courses, search for courses and scheduler

  static AppTheme appTheme = AppTheme();

  static List<Course> favCourses = [];

  static List<Exam> exams = [];

  static int currentScheduleIndex = 0;
  static List<Schedule> schedules = [];

  // NOTE: Used inside add_courses page:
  static List<Subject> coursesToAdd = [];

  static bool isEditingCourse = false; // usde to edit the course info
  static Subject? courseToEdit; // It is used to edit the course info
  static Subject emptySubject = Subject(customName: "",
      courseCode: "",
      departments: <String>[],
      teacherCodes: <List<String>>[[]],
      hours: <int>[],
      bgnPeriods: <List<int>>[],
      days: <List<int>>[],
      classrooms: <List<String>>[[]]);

  static late FacultySemester facultyData;
  static bool isFacDataFilled = false;
  static FacultySemester? facultyDataOld;

  static String filePrefix = Platform.isWindows ? '\\' : '/' ;

  static List<Subject> newCourses = [];
  static List<List<bool>> newCoursesChanges = []; // [isTimeChanged, isClassroomChanged]

  static bool isInternetOn = false;

  static void save() async {

    writeSettings();
    writeFacultyCourses();
    writeFavCourses();
    writeExams();
    await writeSchedules(); // NOTE: always keep writing the schedules as the last function of writing data in the memory

  }

  static void writeExams() async {

    try { // this will check if we can write the new data before deleting the old data
      if (Main.isFacDataFilled) {
        File file = File(Main.appDocDir + filePrefix + "Atsched" + filePrefix + "exams.txt");
        if (file.existsSync()) {
          file.deleteSync();
        }

        file = File(Main.appDocDir + filePrefix + "Atsched" + filePrefix + "exams.txt");
        String toWrite = "";

        for (int i = 0 ; i < Main.exams.length ; i++) {
          toWrite = toWrite + Main.exams[i].toString() + "\n";
        }
        //print("Writing the subjects: $toWrite");
        file.writeAsStringSync(toWrite);
      }
    } catch (e, s) {
      print("$e\n$s");
    }

  }

  static void readExams() async {

    File file = File(Main.appDocDir + filePrefix + "Atsched" + filePrefix + "exams.txt");

    if (file.existsSync()) {

      // print("The faculty courses exists!");

      List<String> lines = file.readAsStringSync().split("\n");

      for (String exam in lines) {
        List<String> v = exam.split("|");
        if (v.length == 4 && DateTime.now().isBefore(DateTime.fromMicrosecondsSinceEpoch(int.parse(v[2])))) {
          Main.exams.add(Exam.fromString(exam));
        }
      }

    } else {
      // print("The faculty courses DID NOT exist!");
      Main.forceUpdate = true;
    }

  }

  static void writeSettings() async {

    String toWrite = "";
    final file = File(Main.appDocDir.toString() + filePrefix + "Atsched" + filePrefix + 'settings.txt');

    toWrite = toWrite + "force_update:"+forceUpdate.toString()+"\n";
    toWrite = toWrite + "is_dark:"+(Main.theme == ThemeMode.dark).toString()+"\n";
    toWrite = toWrite + "uni:"+uni.toString()+"\n";
    toWrite = toWrite + "faculty:"+faculty.toString()+"\n";
    toWrite = toWrite + "department:"+department.toString()+"\n";
    toWrite = toWrite + "language:"+language.toString()+"\n";
    toWrite = toWrite + "hour_update:"+hourUpdate.toString()+"\n";
    toWrite = toWrite + "schedule_index:"+currentScheduleIndex.toString()+"\n";

    toWrite = toWrite + "is_attempted_before:"+isAttemptedBefore.toString()+"\n";
    toWrite = toWrite + "is_there_newer_version:"+isThereNewerVersion.toString()+"\n";
    toWrite = toWrite + "is_fac_change:"+isFacChange.toString()+"\n";

    file.writeAsStringSync(toWrite, mode: FileMode.write);

    //print("Settings were saved!");

  }

  static void readSettings() async {

    String content = "";
    try {
      final file = File(Main.appDocDir.toString() + filePrefix + "Atsched" + filePrefix + 'settings.txt'); // FileSystemException

      content = file.readAsStringSync();
      if (content.isNotEmpty) {
        // print("Settings were found with the content of: $content");

        forceUpdate = content.substring(content.indexOf("force_update:") + 13, content.indexOf("\n", content.indexOf("force_update:") + 13)) == "true" ? true : false;
        theme = (content.substring(content.indexOf("is_dark:") + 8, content.indexOf("\n", content.indexOf("is_dark:") + 8)) == "true" ? true : false) ? ThemeMode.dark : ThemeMode.light;
        uni = content.substring(content.indexOf("uni:") + 4, content.indexOf("\n", content.indexOf("uni:") + 4));
        faculty = content.substring(content.indexOf("faculty:") + 8, content.indexOf("\n", content.indexOf("faculty:") + 8));
        department = content.substring(content.indexOf("department:") + 11, content.indexOf("\n", content.indexOf("department:") + 11));
        language = content.substring(content.indexOf("language:") + 9, content.indexOf("\n", content.indexOf("language:") + 9));
        hourUpdate = int.parse(content.substring(content.indexOf("hour_update:") + 12, content.indexOf("\n", content.indexOf("hour_update:") + 12)));
        currentScheduleIndex = int.parse(content.substring(content.indexOf("schedule_index:") + 15, content.indexOf("\n", content.indexOf("schedule_index:") + 15)));

        isAttemptedBefore = content.substring(content.indexOf("is_attempted_before:") + 20, content.indexOf("\n", content.indexOf("is_attempted_before:") + 20)) == "true" ? true : false;
        isThereNewerVersion = content.substring(content.indexOf("is_there_newer_version:") + 23, content.indexOf("\n", content.indexOf("is_there_newer_version:") + 23)) == "true" ? true : false;
        isFacChange = content.substring(content.indexOf("is_fac_change:") + 14, content.indexOf("\n", content.indexOf("is_fac_change:") + 14)) == "true" ? true : false;
      }
    } catch(err) {
      print("The settings file was not opened bcs: $err");
      Main.firstTime = true;
    }

    appTheme = AppTheme(); // this will set the styles depending on the current theme

    days = hourUpdate.toDouble() / 24.0;

  }

  static void deleteSchedules() async {

    Directory dir = Directory(Main.appDocDir + Main.filePrefix + "Atsched");
    List<FileSystemEntity> files = await (dir.list()).toList();
    // print("Deleting scheds of dir ${files}");

    for (int i = 0 ; i < files.length ; i++) {

      if (files[i].toString().contains("schedule_")) {
        // print("Deleting schedule: ${files[i].toString()}");
        await files[i].delete();
      }

    }

  }

  static Future<void> writeSchedules() async {

    // first delete all the schedules, then write all the schedules again:

    deleteSchedules();

    for (int i = 0 ; i < schedules.length ; i++) {
      print("Writing schedule ${Main.schedules[i].scheduleName}");

      File file_ = File(Main.appDocDir + filePrefix + "Atsched" + filePrefix + "schedule_${Main.schedules[i].scheduleName}.txt");
      await file_.create();
      var file = await file_.open(mode: FileMode.writeOnly);

      String toWrite = "";

      for (int j = 0 ; j < schedules[i].scheduleCourses.length ; j++) { // notes:

        toWrite = toWrite + schedules[i].scheduleCourses[j].note;

        if ((j + 1) < schedules[i].scheduleCourses.length) { // if it is not the last,
          toWrite = toWrite + "\n/ /\n";
        }

      }

      toWrite = toWrite + "////\n";

      for (int j = 0 ; j < schedules[i].scheduleCourses.length ; j++) { // courses:

        toWrite = toWrite + schedules[i].scheduleCourses[j].subject.courseCode + "|" + schedules[i].scheduleCourses[j].subject.toString() + "\n";

      }

      toWrite = toWrite + "////\n";

      String oldData = "", newData = "";
      for (int j = 0 ; j < schedules[i].changes.length ; j++) { // notations (changes):

        oldData = schedules[i].changes[j].oldData;
        newData = schedules[i].changes[j].newData;

        toWrite = toWrite + schedules[i].changes[j].courseCode + "|" +
            schedules[i].changes[j].typeOfChange + "|" + oldData + "|" +
            newData + "|" + schedules[i].changes[j].time.microsecondsSinceEpoch.toString() + "\n";

      }

      // print("The schedule ${Main.schedules[i].scheduleName} is written with the content of: \n\n$toWrite\n\n\n");

      await file.writeString(toWrite);
      await file.flush();
      await file.close();

    }

  }

  static void readSchedules() {

    Directory dir = Directory(Main.appDocDir + filePrefix + "Atsched");

    // List directory contents, recursing into sub-directories,
    // but not following symbolic links.
    List<FileSystemEntity> files = dir.listSync();

    //print("All the files are: $files");

    for (int i = 0 ; i < files.length ; i++) {

      if (files[i].toString().contains("schedule_")) {

        // print("Opening file: ${files[i].toString()}");
        File file = File(files[i].path);
        if (file.existsSync()) {
          // print("The file EXISTED!!!!");

          String content = file.readAsStringSync();
          if (content.replaceAll("////\n", "").isEmpty) {
            // print("The file is empty, finding another file!");
            continue;
          }

          //print("File content is: $content");

          String scheduleName = files[i].toString().substring(files[i].toString().indexOf("schedule_") + 9).replaceAll(".txt", "").replaceAll("'", "");
          // print("The schedule name is $scheduleName");

          List<String> notes = content.split("////\n").elementAt(0).split('\n/ /\n');
          // the notes and the courses are seperated by "////\n" but each note is seperatoed by "\n/ /\n"

          List<String> courses = content.split("////\n").elementAt(1).split("\n");

          List<Course> courses_ = [];
          int index = 0;
          courses = courses.where((element) => element.trim().isNotEmpty).toList();
          courses.forEach((course) { /*print("Doing $course");*/ courses_.add(Course(subject: Subject.fromStringWithCourseCode(course), note: notes[index < notes.length ? index : 0])); index++; });

          List<String> notations = content.split("////\n").elementAt(2).split("\n");
          List<Change> changes = [];

          // print("Found notations: $notations");
          notations.forEach((element) {
            if (element.trim().isNotEmpty) {
              List<String> content = element.split("|");
              Change change;
              if (content[1] == "time") { // time change:
                // print("content: $content");
                change = Change(courseCode: content.elementAt(0), typeOfChange: content.elementAt(1),
                    oldData: content.elementAt(2) + "|" + content.elementAt(3) + "|" + content.elementAt(4),
                    newData: content.elementAt(5) + "|" + content.elementAt(6) + "|" + content.elementAt(7),
                    time: DateTime.fromMicrosecondsSinceEpoch(int.parse(content.elementAt(8))));
              } else { // classroom change:
                change = Change(courseCode: content.elementAt(0), typeOfChange: content.elementAt(1),
                    oldData: content.elementAt(2), newData: content.elementAt(3), time: DateTime.fromMicrosecondsSinceEpoch(int.parse(content.elementAt(4))));
              }
              changes.add(change);
            }
          });

          //courses_.forEach((element) {print(element.subject.toString());});
          Main.schedules.add(Schedule(scheduleName: scheduleName, scheduleCourses: courses_, changes: changes));

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

    try { // this will check if we can write the new data before deleting the old data
      if (Main.isFacDataFilled) {
        File file = File(Main.appDocDir + filePrefix + "Atsched" + filePrefix + "faculty_courses.txt");
        if (file.existsSync()) {
          file.deleteSync();
        }

        file = File(Main.appDocDir + filePrefix + "Atsched" + filePrefix + "faculty_courses.txt");
        String toWrite = "";

        toWrite = toWrite + Main.faculty + "\n";
        toWrite = toWrite + Main.facultyData.semesterName + "\n";
        toWrite = toWrite + Main.facultyData.lastUpdate.microsecondsSinceEpoch.toString() + "\n";
        for (int i = 0 ; i < Main.facultyData.subjects.length ; i++) {
          toWrite = toWrite + Main.facultyData.subjects[i].courseCode + "|" + Main.facultyData.subjects[i].toString() + "\n";
        }
        //print("Writing the subjects: $toWrite");
        file.writeAsStringSync(toWrite);
      }
    } catch (e) {
      print("$e");
    }

  }

  static void readFacultyCourses() {

    File file = File(Main.appDocDir + filePrefix + "Atsched" + filePrefix + "faculty_courses.txt");

    if (file.existsSync()) {

      // print("The faculty courses exists!");

      List<String> lines = file.readAsStringSync().split("\n");
      String facultyName = lines[0];
      if (facultyName != Main.faculty) {
        Main.forceUpdate = true;
        // print("The faculties are different, updating!");
        return;
      }
      lines.removeAt(0);
      String semesterName = lines[0];
      lines.removeAt(0);

      DateTime lastUpdated = DateTime.fromMicrosecondsSinceEpoch(int.parse(lines[0]));
      // print("Time difference is ${DateTime.now().difference(lastUpdated).inHours}, updating!");
      if (DateTime.now().difference(lastUpdated).inHours >= Main.hourUpdate) {
        // print("Time difference is ${DateTime.now().difference(lastUpdated).inHours}, updating!");
        Main.forceUpdate = true;
        return;
      }
      lines.removeAt(0);

      lines = lines.where((element) => element.trim().isNotEmpty).toList();
      Main.isFacDataFilled = true;
      Main.facultyData = FacultySemester(facName: facultyName, lastUpdate: lastUpdated, semesterName: semesterName);
      lines.forEach((course) { Main.facultyData.subjects.add(Subject.fromStringWithCourseCode(course)); });

    } else {
      // print("The faculty courses DID NOT exist!");
      Main.forceUpdate = true;
    }

  }

  static void readFavCourses() {

    File file = File(Main.appDocDir + filePrefix + "Atsched" + filePrefix + "fav_courses.txt");

    if (file.existsSync()) {

      // print("Favourite courses exists!");

      List<String> sections = file.readAsStringSync().split("////\n");
      List<String> notes = sections[0].split("\n/ /\n");
      List<String> courses = sections[1].split("\n");

      int index = 0;
      courses = courses.where((element) => element.trim().isNotEmpty).toList();
      courses.forEach((course) { Main.favCourses.add(Course(subject: Subject.fromStringWithCourseCode(course), note: notes[index])); index++; });

    }

  }

  static void writeFavCourses() {

    File file = File(Main.appDocDir + filePrefix + "Atsched" + filePrefix + "fav_courses.txt");
    String toWrite = "";

    for (int i = 0 ; i < Main.favCourses.length ; i++) {

      toWrite = toWrite + Main.favCourses[i].note;
      if (i + 1 < Main.favCourses.length) { // if it is not the lats note:
        toWrite = toWrite + "\n/ /\n";
      }

    }

    toWrite = toWrite + "////\n";
    for (int i = 0 ; i < Main.favCourses.length ; i++) {

      toWrite = toWrite + Main.favCourses[i].subject.courseCode + "|" + Main.facultyData.subjects[i].toString() + "\n";

    }

    file.writeAsStringSync(toWrite);

  }

  static void assignScrapersNClassifiers() {

    switch(Main.uni) {

      case "Atilim":
        print("Atilim classifier is set!");
        Main.classifier = AtilimClassifier.instance;
        // Main.scraper = Platform.isWindows ? AtilimScraperComputer.instance : AtilimScraperPhone.instance;
        Main.scraper = AtilimScraperComputer.instance;
        break;
      case "Bilkent":
        print("Bilkent classifier is set!");
        Main.classifier = BilkentClassifier.instance;
        Main.scraper = Platform.isWindows ? BilkentScraperComputer.instance : BilkentScraperPhone.instance;
        break;

    }

  }

  static List updateClassroomsCount(List<Subject> subjects, List<Classroom> classrooms_, TypeSendPort sPort) {

    List<Classroom> classrooms = classrooms_;

    if (classrooms_.isEmpty) {
      bool isClassroomFound = false;
      bool isPeriodFound = false;

      for (int subI = 0 ; subI < subjects.length ; subI++) {

        for (int periodI = 0 ; periodI < subjects[subI].days.length ; periodI++) {

          if (subjects[subI].classrooms.length <= periodI) { // TODO: there is a change

            continue;
          }
          for (int classroomI = 0 ; classroomI < subjects[subI].classrooms[periodI].length ; classroomI++) {

            // print("${subjects[subI].days[periodI].length} ${subjects[subI].classrooms[periodI].length}");

            isClassroomFound = false;
            isPeriodFound = false;
            int atI = -1;
            for (int searchI = 0 ; searchI < classrooms.length ; searchI++) {
              atI = searchI;
              if (subjects[subI].classrooms[periodI][classroomI] == classrooms[searchI].classroom) {
                isClassroomFound = true;
                bool isFound = false;
                for (int a_ = 0 ; a_ < classrooms[searchI].days[0].length ; a_++) {
                  if (subjects[subI].days[periodI].length > classroomI && subjects[subI].bgnPeriods[periodI].length > classroomI && classrooms[searchI].bgnPeriods[0].length > a_ &&
                      classrooms[searchI].days[0][a_] == subjects[subI].days[periodI][classroomI] &&
                      classrooms[searchI].bgnPeriods[0][a_] == subjects[subI].bgnPeriods[periodI][classroomI]) {
                    isFound = true;
                    if (classrooms[searchI].hours.length > a_ && classrooms[searchI].hours[a_] < subjects[subI].hours[periodI]) {
                      classrooms[searchI].hours[a_] = subjects[subI].hours[periodI];
                    }
                  }
                }
                if (isFound) {
                  isPeriodFound = true;
                  break;
                }
              }
              if (isClassroomFound) {
                break;
              }
            }

            if (!isClassroomFound) {
              classrooms.add(Classroom(
                classroom: subjects[subI].classrooms[periodI][classroomI],
                days: [subjects[subI].days[periodI]],
                bgnPeriods: [subjects[subI].bgnPeriods[periodI]],
                hours: [subjects[subI].hours[periodI]],
              ));
            }

            if (atI != -1) {
              if (!isPeriodFound) { // not the issue, the issue is that no periods are being added from the other courses

                classrooms[atI].days.add([]);
                classrooms[atI].bgnPeriods.add([]);
                for (int i = 0 ; i < subjects[subI].days[periodI].length ; i++) {
                  classrooms[atI].days[classrooms[atI].days.length - 1].add(subjects[subI].days[periodI][i]);
                }
                for (int i = 0 ; i < subjects[subI].bgnPeriods[periodI].length ; i++) {
                  classrooms[atI].bgnPeriods[classrooms[atI].days.length - 1].add(subjects[subI].bgnPeriods[periodI][i]);
                }
                classrooms[atI].hours.add(subjects[subI].hours[periodI]);

              }
            }

          }

        }

      }
    }

    int classroomsCount = 0;

    // Then, find all the classrooms that, perform the search:
    String day = DateFormat('EEEE').format(DateTime.now());
    String bgnHr = "", endHr = "";
    if (DateTime.now().minute < 20) {
      bgnHr = (DateTime.now().hour - 1).toString() + ":" + University.getBgnMinutes().toString();
      endHr = (DateTime.now().hour).toString() + ":" + University.getEndMinutes().toString();
    } else {
      bgnHr = DateTime.now().hour.toString() + ":" + University.getBgnMinutes().toString();
      endHr = (DateTime.now().hour + 1).toString() + ":" + University.getEndMinutes().toString();
    }

    int dayToSearch;
    if (day != "Any") {
      dayToSearch = stringToDay(day);
    } else {
      dayToSearch = -1;
    }

    int bgnHrToSearch, endHrToSearch;
    if (bgnHr != "Any") {
      bgnHrToSearch = University.stringToBgnPeriod(bgnHr);
    } else {
      bgnHrToSearch = -1;
    }
    if (endHr != "Any") {
      endHrToSearch = University.stringToBgnPeriod(endHr);
    } else {
      endHrToSearch = -1;
    }

    int hours1;
    int bgnHour1;
    int hours2;
    int bgnHour2;

    bool isEmpty = true; // by default, it is not empty, try to find if the period we need has one period that is empty at the same time
    classrooms.forEach((classroom) {
      isEmpty = true;

      List<int> daysUsed = [];

      for (int i = 0 ; i < classroom.days.length ; i++) {
        for (int j = 0 ; j < classroom.days[i].length ; j++) {
          if (!daysUsed.contains(classroom.days[i][j])) {
            daysUsed.add(classroom.days[i][j]);
          }
        }
      }

      if (dayToSearch == -1) {
        bool emptyDayFound = false;
        for (int d = 1 ; d < 8 ; d++) {
          if (!daysUsed.contains(d)) {
            emptyDayFound = true;
            break;
          }
        }
        if (emptyDayFound) {
          classroomsCount++;
          return ;
        }
      }

      for (int i = 0 ; i < classroom.days.length ; i++) {
        for (int j = 0 ; j < classroom.days[i].length ; j++) {
          if (dayToSearch != -1 && classroom.bgnPeriods[i].length > j) {
            hours1 = endHrToSearch - bgnHrToSearch;
            bgnHour1 = bgnHrToSearch;
            hours2 = classroom.hours[i];
            bgnHour2 = classroom.bgnPeriods[i][j];
            if (
            (bgnHour1 >= bgnHour2 && bgnHour1 < (bgnHour2 + hours2)) ||
                ((bgnHour1 + hours1) > bgnHour2 && (bgnHour1 + hours1) < (bgnHour2 + hours2))
                || (bgnHour2 >= bgnHour1 && bgnHour2 < (bgnHour1 + hours1)) ||
                ((bgnHour2 + hours2) > bgnHour1 && (bgnHour2 + hours2) < (bgnHour1 + hours1))
            ) {
              if (dayToSearch == classroom.days[i][j]) {
                isEmpty = false;
                break;

              }
            }
          }
        }
        if (!isEmpty) {
          break;
        }
      }

      if (isEmpty) {
        classroomsCount++;
      }

      return ;

    });

    return [classroomsCount, [...classrooms]];

  }

  static void scheduleClassroomsCounter() {

    Executor().execute(arg1: Main.facultyData.subjects, arg2: Main.classrooms, fun2: Main.updateClassroomsCount).then((result) {
      Main.classroomsCountForCurHr = result[0];
      Main.classrooms = result[1];

      int mins = 0;
      if (DateTime.now().minute < 20) {
        mins = DateTime.now().minute;
      } else {
        mins = 60 - DateTime.now().minute + 20;
      }

      print("Classrooms count to be refreshed after $mins minutes!");
      Timer(Duration(minutes: mins), scheduleClassroomsCounter);

    });

  }

  static bool isNumeric(String s) {
    if(s == null) {
      return false;
    }
    return double.parse(s, (e) => 0.0) != 0.0;
  }

}

Future main() async {

  WidgetsFlutterBinding.ensureInitialized();
  Main.appDocDir = (await getApplicationDocumentsDirectory()).path;
  if (!Platform.isWindows) {
    // await [Permission.storage].request().then((value_) {
    //   if (!value_.toString().contains(".granted")) {
    //     Main.restart();
    //   } else {
    //     //print("The premission of storage was granted!");
    //   }
    // });
  }

  // print("Elapsed time: ${DateTime.now().microsecondsSinceEpoch}");

  { // for storing the files into that directory:
    Directory dir = Directory(Main.appDocDir + Main.filePrefix + "Atsched");
    if (!dir.existsSync()) {
      dir.createSync();
    }
  }

  /*if (Platform.isWindows) {
      FlutterWindowClose.setWindowShouldCloseHandler(() async {
        return await showDialog(
            context: context,
            builder: (context) {
              if (Main.newFaculty.isNotEmpty) { // then it is a faculty change
                return AlertDialog(
                    title: const Text('Do you want to change the faculty?\nNext time you open Atsched the faculty will change'),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            Main.forceUpdate = true;
                            Main.faculty = Main.newFaculty;
                            Main.department = faculties[Main.faculty]?.keys.elementAt(0) as String;
                            Main.isFacChange = true;
                            Main.save();
                            Navigator.of(context).pop(true);
                          },
                          child: const Text('Yes')),
                      ElevatedButton(
                          onPressed: () { Main.newFaculty = ""; Navigator.of(context).pop(false); },
                          child: const Text('No')),
                    ]
                );
              }
              else {
                return AlertDialog(
                    title: Text('Do you really want to quit?' + (Main.forceUpdate ? "\nNext time you open Atsched the update will start" : "")),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            Main.save();
                            Navigator.of(context).pop(true);
                          },
                          child: const Text('Yes')),
                      ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('No')),
                    ]
                );
              }
            });
      });
    }*/

  Main.readSchedules();
  Main.readSettings();
  // if (!Main.forceUpdate) {
  //   Main.readFacultyCourses();
  // }
  Main.readFacultyCourses(); // read the faculty courses everytime, if there is an update it will be used to detect the changes inside-
  // thew old courses and update the classrooms or the time of the class accordingly...
  Main.readFavCourses();
  Main.readExams();

  if (Main.schedules.isEmpty) {
    Main.schedules.add(Schedule(scheduleName: translateEng("Default Schedule"), scheduleCourses: []));
  }

  // after the scheudles list has been filled, do this:
  if (Main.currentScheduleIndex >= Main.schedules.length) { // precaution: for preventing errors:
    Main.currentScheduleIndex = Main.schedules.length - 1;
  }

  // always check the internet connection for updating the courses and the app itself form app store or google play
  await NoInternetPageState.checkInternet();

  bool forceToHomePage = false;
  //print("LAST TIME UPDATED IS ${Main.isFacDataFilled && !Main.isInternetOn && Main.facultyData.lastUpdate.difference(DateTime.now()).inDays <= 7}");
  if (Main.isFacDataFilled && !Main.isInternetOn && Main.facultyData.lastUpdate.difference(DateTime.now()).inDays <= 7) {
    forceToHomePage = true;
  }

  Main.packageInfo = await PackageInfo.fromPlatform();

  bool goToUpdatePage = false;
  bool isThereErr = false;

  if (!Platform.isWindows) {
    try {
      // Main.versionStatus = await Main.newVersion.getVersionStatus();
    } catch(err, trace) {
      print(err.toString() + "\n$trace");
      isThereErr = true;
    }
    if (!Main.isInternetOn && Main.isThereNewerVersion) {
      goToUpdatePage = true;
    }
    try {
      if (!isThereErr && Main.versionStatus != null && Main.versionStatus!.canUpdate) {
        Main.isThereNewerVersion = true;
        goToUpdatePage = true;
        Main.writeSettings();
      }
    } catch (err) {
      print("ERROR: Main.versionStatus has not been initialied");
    }
  } else {

    //Main.isInternetOn

    if (Main.isInternetOn) {
      var request = await HttpClient().getUrl(Uri.parse('https://apps.microsoft.com/store/detail/atsched/9NQ6G0L7FTG2?hl=en-us&gl=us'));
      // sends the request
      var response = await request.close();

      // transforms and prints the response
      await for (var contents in response.transform(const Utf8Decoder())) {
        int pos;
        String version;

        if (Main.semesterName.isEmpty) {
          // Sample: "Latest Version: 1.3.0.0////"
          pos = contents.indexOf('Latest Version: '); // first search for
          if (pos != -1) {

            version = contents.substring(pos + 16, contents.indexOf('////', pos + 16));
            if (version.isNotEmpty) {
              List<String> vNew = version.trim().split('.');
              List<String> vOld = Main.atschedVersionForWindows.split('.');
              //print("The new version: $vNew\n\nThe old version: $vOld");
              if (int.parse(vNew[0]) > int.parse(vOld[0]) ||
                  int.parse(vNew[1]) > int.parse(vOld[1]) ||
                  int.parse(vNew[2]) > int.parse(vOld[2]) ||
                  int.parse(vNew[3]) > int.parse(vOld[3])) {
                Main.isThereNewerVersion = true;
                goToUpdatePage = true;
                break;
              }
            }

          }
        }

      }
    }

    // print("found the following links: "
    //     "${Main.artsNSciencesLink}\n${Main.fineArtsLink}\n${Main.businessLink}\n${Main.engineeringLink}\n${Main.civilAviationLink}\n${Main.healthSciencesLink}\n${Main.lawLink}");
  }

  if (Main.forceUpdate) { // if no link was found, then Atsched will just open up, but it will not update:
    if (University.areFacsSupported() && (await University.getFacultyLink(Main.department)).isEmpty) {
      Main.forceUpdate = false;
    }
  }

  Main.assignScrapersNClassifiers();

  await Executor().warmUp(log: false, isolatesCount: 3); // might be increased later!

  runApp(OKToast(
    child: MaterialApp(
      builder: InAppNotifications.init(),
      debugShowCheckedModeBanner: false,
      initialRoute: Main.firstTime ? "/choosesettings" :
      (!goToUpdatePage ?
      (forceToHomePage ?
      "/home" : (Main.isInternetOn ?
      (Main.forceUpdate ? "/webpage" : "/home") : "/nointernet")) : "/update"),

      routes: {
        "/choosesettings" : (context) => ChooseSettingsPage(),
        "/nointernet" : (context) => NoInternetPage(),
        "/home" : (context) => Home(),
        "/webviewunsupported" : (context) => WebviewUnsupported(),
        "/webpage": (context) => Platform.isWindows ? WPComputer() : WPPhone(),
        "/update": (context) => UpdatePage(),
        "/home/searchcourses": (context) => const SearchPage(),
        "/home/emptyclassrooms": (context) => EmptyClassroomsPage(),
        "/home/favcourses": (context) => FavCourses(),
        "/home/editcourses": (context) => EditCoursePage(),
        "/home/editcourses/addcourses": (context) => AddCoursesPage(),
        "/home/editcourses/createcustomcourse": (context) => CustomCoursePage(),
        "/home/editcourses/editcourseinfo": (context) { CustomCoursePage page = CustomCoursePage(); page.subject = Main.courseToEdit ?? Main.emptySubject; return page; },
        "/home/savedschedules" : (context) => SavedSchedulePage(),
        "/home/savedschedules/schedulenotifications" : (context) => ScheduleNotificationPage(),
        "/home/personalinfo" : (context) => PersonalInfo(),
        "/home/scheduler" : (context) => SchedulerPage(),
        "/home/scheduler/schedulerresult" : (context) => SchedulerResultPage(),
        "/home/examspage" : (context) => ExamsPage(),
      },
    ),
  ));

}
