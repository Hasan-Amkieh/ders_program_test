import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:Atsched/pages/loading_update_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:Atsched/main.dart';
import 'package:Atsched/others/subject.dart';

import 'others/university.dart';

//import 'package:Atsched/others/spring_schedules.dart';

class WPPhone extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return WPPhoneState();
  }

}

class WPPhoneState extends State<WPPhone> {
  InAppWebViewController? webView;

  static int state = 0;

  static bool doNotRestart = false;

  static WPPhoneState? currentState;
  late InAppWebViewController controller;

  @override
  void initState() {

    super.initState();

    currentState = this;
    currWidget = this;

  }

  Future<void> getTimetableLinks() async {

    var request = await HttpClient().getUrl(Uri.parse('https://www.atilim.edu.tr/en/dersprogrami'));
    // sends the request
    var response = await request.close();

    // transforms and prints the response
    await for (var contents in response.transform(const Utf8Decoder())) {
      int pos;

      if (semesterName.isEmpty) {
        int pos_;
        int start;
        pos = contents.indexOf('https://atilimartsci'); // first search for
        if (pos != -1) {
          start = contents.lastIndexOf('<table', pos);
          pos_ = contents.lastIndexOf('Schedule', pos);
          if (pos_ == -1 || pos_ < start) {
            pos_ = contents.lastIndexOf('schedule', pos);
          }
          if (pos_ == -1 || pos_ < start) {
            pos_ = contents.lastIndexOf('SCHEDULE', pos);
          }
          if (pos_ == -1 || pos_ < start) {
            pos_ = contents.lastIndexOf('School', pos);
          }
          if (pos_ == -1 || pos_ < start) {
            pos_ = contents.lastIndexOf('SCHOOL', pos);
          }
          if (pos_ == -1 || pos_ < start) {
            pos_ = contents.lastIndexOf('school', pos);
          }

          if (pos_ != -1 && pos_ > start) { // then the semester name is found:

            pos = contents.lastIndexOf('>', pos_) + 1;
            pos_ = contents.indexOf('<', pos_);
            semesterName = contents.substring(pos, pos_);
            semesterName = semesterName.replaceAll("&nbsp;", " ");

          }
        }
      }

      if (Main.artsNSciencesLink.isEmpty) {
        pos = contents.indexOf('https://atilimartsci');
        if (pos != -1) {
          Main.artsNSciencesLink = contents.substring(pos, contents.indexOf('"', pos + 32));
        }
      }
      if (Main.fineArtsLink.isEmpty) {
        pos = contents.indexOf('https://atilimgstm');
        if (pos != -1) {
          Main.fineArtsLink = contents.substring(pos, contents.indexOf('"', pos + 32));
        }
      }
      if (Main.lawLink.isEmpty) {
        pos = contents.indexOf('https://atilimlaw');
        if (pos != -1) {
          Main.lawLink = contents.substring(pos, contents.indexOf('"', pos + 32));
        }
      }
      if (Main.businessLink.isEmpty) {
        pos = contents.indexOf('https://atilimmgmt');
        if (pos != -1) {
          Main.businessLink = contents.substring(pos, contents.indexOf('"', pos + 32));
        }
      }
      if (Main.engineeringLink.isEmpty) {
        pos = contents.indexOf('https://atilimengr');
        if (pos != -1) {
          Main.engineeringLink = contents.substring(pos, contents.indexOf('"', pos + 32));
        }
      }
      if (Main.healthSciencesLink.isEmpty) {
        pos = contents.indexOf('https://atilimhlth');
        if (pos != -1) {
          Main.healthSciencesLink = contents.substring(pos, contents.indexOf('"', pos + 32));
        }
      }
      if (Main.civilAviationLink.isEmpty) {
        pos = contents.indexOf('https://atilimcav');
        if (pos != -1) {
          Main.civilAviationLink = contents.substring(pos, contents.indexOf('"', pos + 32));
        }
      }
    }

    // print("found the following links: "
    //     "${Main.artsNSciencesLink}\n${Main.fineArtsLink}\n${Main.businessLink}\n${Main.engineeringLink}\n${Main.civilAviationLink}\n${Main.healthSciencesLink}\n${Main.lawLink}");

  }

  String semesterName = "";

  @override
  Widget build(BuildContext context) {

    getTimetableLinks();

    return Scaffold(
      body: Stack(
          children: [
            InAppWebView(
                onAjaxReadyStateChange: (controller, request) async {
                  //print("Received this file: ${request.url.toString()}");
                  if (request.url
                      .toString()
                      .contains("__func=regularttGetData") &&
                      request.readyState == AjaxRequestReadyState.DONE) {
                    if (request.responseText!.isNotEmpty) { // ROOT:
                      state = 3;
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
                            // TODO: TEST:
                            // switch (Main.faculty) {
                            //   case "Engineering":
                            //     //sPort?.send(["timetableData", SpringSchedules.engineeringTimeTable, Main.faculty]);
                            //     sPort?.send(["timetableData", request.responseText, Main.faculty]);
                            //     break;
                            //   case "Civil Aviation":
                            //     //sPort?.send(["timetableData", SpringSchedules.civilAviationTimeTable, Main.faculty]);
                            //     sPort?.send(["timetableData", request.responseText, Main.faculty]);
                            //     break;
                            //   case "Health Sciences":
                            //     //sPort?.send(["timetableData", SpringSchedules.healthSciencesTimeTable, Main.faculty]);
                            //     sPort?.send(["timetableData", request.responseText, Main.faculty]);
                            //     break;
                            //   case "Arts and Sciences":
                            //     //sPort?.send(["timetableData", SpringSchedules.artsNSciencesTimeTable, Main.faculty]);
                            //     sPort?.send(["timetableData", request.responseText, Main.faculty]);
                            //     break;
                            //   case "Fine Arts":
                            //     //sPort?.send(["timetableData", SpringSchedules.fineArtsNArchitetctureTimeTable, Main.faculty]);
                            //     sPort?.send(["timetableData", request.responseText, Main.faculty]);
                            //     break;
                            //   case "Law":
                            //     sPort?.send(["timetableData", request.responseText, Main.faculty]); // cause there is no spring sem
                            //     break;
                            //   case "Business":
                            //     sPort?.send(["timetableData", SpringSchedules.businessTimeTable, Main.faculty]);
                            //     break;
                            // }
                            // TODO: TEST;
                          }

                          if (msg[0] == "setDoNotRestart") {
                            doNotRestart = true;
                          }

                          if (msg[0] == "facultyData") { // Main.facultyData =
                            if (Main.isFacDataFilled) {
                              Main.facultyDataOld = Main.facultyData;
                            }
                            Main.isFacDataFilled = true;
                            Main.facultyData = FacultySemester(facName: Main.faculty, lastUpdate: DateTime.now(), semesterName: semesterName);
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
                            state = msg[1] as int;
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
                },
                initialUrlRequest: URLRequest(
                    url: Uri.parse(
                        University.getFacultyLink(Main.department))),
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                      useShouldInterceptAjaxRequest: true),
                ),
                onWebViewCreated: (InAppWebViewController controller) {
                  webView = controller;
                },
                onCreateWindow: (controller, action) async {
                  this.controller = controller;

                  return true;
                },
                onLoadStart: (controller, url) async {
                  // print("Loading of te page started!");
                  state = 1;
                },
                onLoadStop: (controller, url) async {
                  // print("Loading of the page finished!");
                  state = 2;
                }),
            LoadingUpdate(),
          ],
      ),
    );
  }

  static WPPhoneState? currWidget;

  void finish() {

    Navigator.pushNamed(context, "/home");

  }

}
