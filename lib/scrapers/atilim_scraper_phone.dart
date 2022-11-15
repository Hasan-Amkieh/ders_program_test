
import 'dart:isolate';

import 'package:Atsched/scrapers/scraper.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../main.dart';
import '../others/subject.dart';
import '../pages/loading_update_page.dart';
import '../wp_phone.dart';

class AtilimScraperPhone extends Scraper {

  @override
  Future<AjaxRequestAction> getTimetableData(controller, request) async {

    {
      //print("Received this file: ${request.url.toString()}");
      if (request!.url
          .toString()
          .contains("__func=regularttGetData") &&
          request.readyState == AjaxRequestReadyState.DONE) {
        if (request.responseText!.isNotEmpty) { // ROOT:
          WPPhoneState.state = 3;
          // print("Timetable Retrieved!\nLength of the response: ${request.responseText?.length}");
          //dataClassification(request.responseText);
          ReceivePort rPort = ReceivePort();
          SendPort? sPort;
          Isolate? isolate;

          rPort.listen((msg) {
            if (msg is List) {

              // print("RECEIVED FROM THE ISOLATE: " + msg[0].toString());

              if (msg[0] == "sPort") {
                sPort = msg[1] as SendPort;
                sPort?.send(["timetableData", request.responseText, Main.faculty]);
              }

              if (msg[0] == "setDoNotRestart") {
                WPPhoneState.doNotRestart = true;
              }

              if (msg[0] == "facultyData") { // Main.facultyData =
                if (Main.isFacDataFilled) {
                  Main.facultyDataOld = Main.facultyData;
                }
                Main.isFacDataFilled = true;
                Main.facultyData = FacultySemester(facName: Main.faculty, lastUpdate: DateTime.now(), semesterName: WPPhoneState.currentState!.semesterName);
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
                  print("Error in periods duplication deletion: $e");
                }

                // then find all the courses that have different time or classrooms:
                if (Main.facultyDataOld != null) {
                  for (int i = 0 ; i < Main.facultyDataOld!.subjects.length ; i++) {
                    for (int j = 0 ; j < Main.facultyData.subjects.length ; j++) {
                      if (Main.facultyDataOld!.subjects[i].classCode == Main.facultyData.subjects[j].classCode) { // if the course is the same:
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
                          Main.newCourses.add(Subject(classCode: Main.facultyData.subjects[j].classCode, departments: Main.facultyData.subjects[j].departments,
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
                WPPhoneState.state = msg[1] as int;
                //rPort.close(); // it is causing the app to freeze!
                isolate?.kill();
                //
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
              print("The received object is NOT A LIST!!!");
            }
          });

          isolate = (await Isolate.spawn(Main.classifier.classifyData, rPort.sendPort));
        }
        else { // if the response is empty then smth is wrong, restart!
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
      }

      return AjaxRequestAction.PROCEED;
    }

  }

  AtilimScraperPhone._privateConstructor();

  static late final Scraper instance = AtilimScraperPhone._privateConstructor();

}
