
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:Atsched/scrapers/scraper.dart';
import 'package:Atsched/wp_phone.dart';

import '../main.dart';
import '../others/subject.dart';
import '../others/university.dart';
import '../pages/loading_update_page.dart';
import '../wp_computer.dart';

class BilkentScraperComputer extends Scraper {

  @override
  getTimetableData() async {

    // print("Calling Bilkent Scraper!!!");

    // 1. Determine the semester name in Main
    // Only the latest semester is required

    try {

      // print("Getting the new links: ");
      var request = await (HttpClient()..connectionTimeout = const Duration(seconds: 5)).getUrl(Uri.parse('https://raw.githubusercontent.com/furkankose/bilkent-scheduler/data/public/data/semesters.json'));
      // sends the request
      var response = await request.close();

      // print("The status code is : ${response.statusCode}");
      // transforms and prints the response
      if (response.statusCode == 200) {
        await for (var contents in response.transform(const Utf8Decoder())) {
          int pos;

          pos = contents.indexOf('"year":"');
          if (pos != -1) {

            Main.semesterName = contents.substring(pos + 8, contents.indexOf('"', pos + 8));

            pos = contents.indexOf('"name":"');
            Main.semesterName = Main.semesterName + " " + contents.substring(pos + 8, contents.indexOf('"', pos + 8));

            // for example: 20221 / means the for the Fall (last digit of 1) and for 2022 - 2023
            pos = contents.indexOf('"code":"');
            University.variables.addEntries([MapEntry("code", contents.substring(pos + 8, contents.indexOf('"', pos + 8)))]);

            break; // We got all the information we need, get out:

          }
        }
      }

    } catch (e) {
      Main.forceUpdate = false; // something is really wrong!
      print("ERROR: $e");
    }

    // print("The semester name is ${Main.semesterName} and the code ${University.variables["code"]}");

    if (Platform.isWindows) {
      WPComputerState.state = 2;
    } else {
      WPPhoneState.state = 2;
    }

    // STARTING RECEIVING THE DATA:

    String timetableStr = "";

    try {

      // print("Getting the new links: ${'https://raw.githubusercontent.com/furkankose/bilkent-scheduler/data/public/data/offerings/' +
      //     University.variables['code'].toString() + '.json'}");
      var request = await (HttpClient()..connectionTimeout = const Duration(seconds: 5)).getUrl(Uri.parse('https://raw.githubusercontent.com/furkankose/bilkent-scheduler/data/public/data/offerings/' +
          University.variables['code'].toString() + '.json'));
      // sends the request
      var response = await request.close();

      // print("The status code is : ${response.statusCode}");
      // transforms and prints the response
      if (response.statusCode == 200) {
        await for (var contents in response.transform(const Utf8Decoder())) {

          if (contents.contains('"sections":') || contents.contains('"instructor":') || contents.contains('"name":')) { // total 269163 of length
            timetableStr = timetableStr + contents;
            // print(contents.length);
          }
        }
      }

    } catch (e) {
      Main.forceUpdate = false; // something is really wrong!
      print("ERROR: $e");
    }

    // print("Received the contents: $timetableData of length ${timetableData.length}");

    // print("Content length is ${timetableStr.length}");

    Map timetableData = const JsonDecoder().convert(timetableStr); // Map<String, Map<String (subject without secs.), (properties) Map<"Props, like name and sections", dynamic>>>
    // the first str represents the Faculty, like "ADA", architectural drawing
    // the dynamic key has a map of keys, each key is a section, the value of each section key has a map of properties of that section of that subject

    if (Platform.isWindows) {
      WPComputerState.state = 3;
    } else {
      WPPhoneState.state = 3;
    }

    ReceivePort rPort = ReceivePort();
    SendPort? sPort;
    Isolate? isolate;

    rPort.listen((msg) {
      if (msg is List) {

        // print("RECEIVED FROM THE ISOLATE: " + msg[0].toString());

        if (msg[0] == "sPort") {
          sPort = msg[1] as SendPort;
          sPort?.send(["timetableData", timetableData]);
        }

        if (msg[0] == "setDoNotRestart") {
          if (Platform.isWindows) {
            WPComputerState.doNotRestart = true;
          } else {
            WPPhoneState.doNotRestart = true;
          }
        }

        if (msg[0] == "facultyData") { // Main.facultyData =
          if (Main.isFacDataFilled) {
            Main.facultyDataOld = Main.facultyData;
          }
          Main.isFacDataFilled = true;
          Main.facultyData = FacultySemester(facName: Main.faculty, lastUpdate: DateTime.now(), semesterName: Main.semesterName);
          Main.facultyData.subjects = msg[1] as List<Subject>;

          // find all the courses that have duplication of periods:

          try {
            for (int subIndex = 0 ; subIndex < Main.facultyData.subjects.length ; subIndex++) {
              for (int i = 0 ; i < Main.facultyData.subjects[subIndex].hours.length ; i++) {
                for (int j = 0 ; j < Main.facultyData.subjects[subIndex].days[i].length ; j++) {
                  for (int i_ = 0 ; i_ < Main.facultyData.subjects[subIndex].hours.length ; i_++) {
                    for (int j_ = 0 ; j_ < Main.facultyData.subjects[subIndex].days[i_].length ; j_++) {
                      if (Main.facultyData.subjects[subIndex].hours[i] == Main.facultyData.subjects[subIndex].hours[i_] &&
                          Main.facultyData.subjects[subIndex].days[i][j] == Main.facultyData.subjects[subIndex].days[i_][j_] &&
                          Main.facultyData.subjects[subIndex].bgnPeriods[i][j] == Main.facultyData.subjects[subIndex].bgnPeriods[i_][j_] &&
                          (j != j_)) { // then it is a duplicate
                        Main.facultyData.subjects[subIndex].days[i_].removeAt(j_);
                        Main.facultyData.subjects[subIndex].bgnPeriods[i_].removeAt(j_);
                        if (j_ > 0) {
                          j_--;
                        }
                      }
                    }
                  }
                }
              }
            }
          } catch(e) {
            print("An error has occurred during the course period duplication deletion: $e");
          }

          // then find all the courses that have different time or classrooms:
          if (Main.facultyDataOld != null) {
            for (int i = 0 ; i < Main.facultyDataOld!.subjects.length ; i++) {
              for (int j = 0 ; j < Main.facultyData.subjects.length ; j++) {
                if (Main.facultyDataOld!.subjects[i].courseCode == Main.facultyData.subjects[j].courseCode) { // if the course is the same:
                  bool isTimeDiff = false;
                  bool isClassroomDiff = false;
                  for (int k = 0 ; k < Main.facultyDataOld!.subjects[i].days.length ; k++) { // loop through the period: Main.facultyDataOld.subjects[i].days[k]
                    if (isTimeDiff) {
                      break;
                    }
                    if (Main.facultyData.subjects[j].hours.length > k && Main.facultyDataOld!.subjects[i].hours[k] == Main.facultyData.subjects[j].hours[k]) {
                      for (int l = 0; l < Main.facultyDataOld!.subjects[i].days[k].length; l++) {
                        if (Main.facultyDataOld!.subjects[i].days.length != Main.facultyData.subjects[j].days.length || Main.facultyDataOld!.subjects[i].days[k].length != Main.facultyData.subjects[j].days[k].length) {
                          isTimeDiff = true;
                          break;
                        } else {
                          if (Main.facultyDataOld!.subjects[i].days[k][l] != Main.facultyData.subjects[j].days[k][l] && Main.facultyDataOld!.subjects[i].bgnPeriods[k][l] != Main.facultyData.subjects[j].bgnPeriods[k][l]) {
                            isTimeDiff = true;
                            break;
                          }
                        }
                      }
                    } else {
                      isTimeDiff = true;
                      break;
                    }
                  }

                  for (int k = 0 ; k < Main.facultyDataOld!.subjects[i].classrooms.length ; k++) { // check classrooms:
                    for (int l = 0 ; l < Main.facultyDataOld!.subjects[i].classrooms[k].length ; l++) {
                      if (Main.facultyData.subjects[j].classrooms.length == Main.facultyDataOld?.subjects[i].classrooms.length &&
                          Main.facultyData.subjects[j].classrooms[k].length == Main.facultyDataOld?.subjects[i].classrooms[k].length
                          && Main.facultyDataOld!.subjects[i].classrooms[k][l] != Main.facultyData.subjects[j].classrooms[k][l]) {
                        isClassroomDiff = true;
                        break;
                      }
                    }
                    if (isClassroomDiff) {
                      break;
                    }
                  }

                  if (isTimeDiff || isClassroomDiff) {
                    // copy everything instead of copying the reference:
                    Main.newCourses.add(Subject(courseCode: Main.facultyData.subjects[j].courseCode, departments: Main.facultyData.subjects[j].departments,
                        teacherCodes: Main.facultyData.subjects[j].teacherCodes, hours: Main.facultyData.subjects[j].hours, bgnPeriods: Main.facultyData.subjects[j].bgnPeriods,
                        days: Main.facultyData.subjects[j].days, classrooms: Main.facultyData.subjects[j].classrooms, customName: Main.facultyData.subjects[j].customName));
                    Main.newCoursesChanges.add([isTimeDiff, isClassroomDiff]);
                  }
                }
              }
            }
          }
        }

        if (msg[0] == "setState") { // Main.facultyData =
          if (Platform.isWindows) {
            WPComputerState.state = msg[1] as int;
          } else {
            WPPhoneState.state = msg[1] as int;
          }
          //rPort.close(); // it is causing the app to freeze!
          isolate?.kill();
        }

        if (msg[0] == "error") { // Main.facultyData =
          if (Main.isAttemptedBefore) {
            if (Main.facultyDataOld != null) {
              Main.facultyData = Main.facultyDataOld!;
              Main.isFacDataFilled = true;
            } else {
              Main.isFacDataFilled = false;
            }
            // then go to the Home page:
            LoadingUpdate.currWidget?.endLoading();
          } else {
            Main.isAttemptedBefore = true;
            Main.restart();
          }
        }

      } else {
        print("[ERROR] The received object is NOT A LIST!!!");
      }
    });

    isolate = (await Isolate.spawn(Main.classifier.classifyData, rPort.sendPort));

    // print("Testing : ${timetableData["ADA"]["ADA 131"]["sections"]["1"]["instructor"]}"); // Hatice Karaca is the supposed result

  }

  BilkentScraperComputer._privateConstructor();

  static late final Scraper instance = BilkentScraperComputer._privateConstructor();

}
