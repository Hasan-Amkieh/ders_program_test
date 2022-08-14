import 'dart:isolate';

import 'package:ders_program_test/pages/loading_update_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ders_program_test/main.dart';
import 'package:ders_program_test/others/subject.dart';

import 'others/departments.dart';

import 'package:ders_program_test/others/spring_schedules.dart';

class Webpage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return WebpageState();
  }

}

class WebpageState extends State<Webpage> {
  InAppWebViewController? webView;

  static int state = 0;

  static bool doNotRestart = false;

  static WebpageState? currentState;
  late InAppWebViewController controller;

  @override
  void initState() {

    super.initState();

    currentState = this;
    currWidget = this;

  }

  @override
  Widget build(BuildContext context) {

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
                      print("Timetable Retrieved!\nLength of the response: ${request.responseText?.length}");
                      //dataClassification(request.responseText);
                      ReceivePort rPort = ReceivePort();
                      SendPort? sPort;
                      Isolate? isolate;

                      rPort.listen((msg) {
                        if (msg is List) {

                          print("RECEIVED FROM THE ISOLATE: " + msg[0].toString());

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
                            Main.facultyData = FacultySemester(facName: Main.faculty, lastUpdate: DateTime.now());
                            Main.facultyData.subjects = msg[1] as List<Subject>;

                            // then find all the courses that have different time or classrooms:
                            for (int i = 0 ; i < Main.facultyDataOld!.subjects.length ; i++) {
                              for (int j = 0 ; j < Main.facultyData.subjects.length ; j++) {
                                if (Main.facultyDataOld!.subjects[i].classCode == Main.facultyData.subjects[j].classCode) { // if the course is the same:
                                  bool isTimeDiff = false;
                                  bool isClassroomDiff = false;
                                  for (int k = 0 ; k < Main.facultyDataOld!.subjects[i].days.length ; k++) { // loop through the period: Main.facultyDataOld.subjects[i].days[k]
                                    if (isTimeDiff) {
                                      break;
                                    }
                                    if (Main.facultyDataOld!.subjects[i].hours[k] == Main.facultyData.subjects[j].hours[k]) {
                                      for (int l = 0; l < Main.facultyDataOld!.subjects[i].days[k].length; l++) {
                                        if (Main.facultyDataOld!.subjects[i].days[k][l] != Main.facultyData.subjects[j].days[k][l] && Main.facultyDataOld!.subjects[i].bgnPeriods[k][l] != Main.facultyData.subjects[j].bgnPeriods[k][l]) {
                                          isTimeDiff = true;
                                          break;
                                        }
                                      }
                                    } else {
                                      isTimeDiff = true;
                                      break;
                                    }
                                  }

                                  for (int k = 0 ; k < Main.facultyDataOld!.subjects[i].classrooms.length ; k++) { // check classrooms:
                                    for (int l = 0 ; l < Main.facultyDataOld!.subjects[i].classrooms[k].length ; l++) {
                                      if (Main.facultyDataOld!.subjects[i].classrooms[k][l] != Main.facultyData.subjects[j].classrooms[k][l]) {
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

                      isolate = (await Isolate.spawn(dataClassification, rPort.sendPort));
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
                        getFacultyLink(Main.department))),
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
                  print("Loading of te page started!");
                  state = 1;
                },
                onLoadStop: (controller, url) async {
                  print("Loading of the page finished!");
                  state = 2;
                }),
            LoadingUpdate(),
          ],
      ),
    );
  }

  static void dataClassification(SendPort sPort) {

    ReceivePort rPort = ReceivePort();

    rPort.listen((msg) {

      try {
        if (msg is List) {

          if (msg[0] == "timetableData") {

            String timetableStr = msg[1];
            String faculty = msg[2];

            //print("Starting classification:\n");
            sPort.send(["setDoNotRestart"]); // doNotRestart = true;

            //FacultySemester facultyData = FacultySemester(facName: Main.faculty, lastUpdate: DateTime.now());

            List<String> names = [];
            var classesInSemester = [];
            List<MapEntry<String, String>> subjectIds = [];
            List<Subject> subjects = [];

            int classCodesEnd, classCodesBegin;
            classCodesEnd = timetableStr.indexOf(
                '{"id":"picture_url","name":"Fotoğraf"},{"id":"timeoff","type":"object","name":"Zaman Tablosu"},{"id":"contract_weight","type":"float","name":"Öğretmen Sözleşmesi İçin Uzunluk Değeri"}]', 0);
            classCodesBegin = timetableStr.indexOf("data_rows", classCodesEnd) + 9;
            classCodesEnd = timetableStr.indexOf("data_columns", classCodesBegin);

            int lastFound = classCodesBegin;
            String name = "", classCodeWithSec, classCodeWithoutSec;
            while (lastFound < classCodesEnd) {

              lastFound = timetableStr.indexOf('name":"', lastFound) + 7;
              name = timetableStr.substring(lastFound, timetableStr.indexOf('"', lastFound));

              lastFound = timetableStr.indexOf('short":"', lastFound) + 8;
              classCodeWithSec = timetableStr.substring(lastFound, timetableStr.indexOf('"', lastFound));
              if (classCodeWithSec.contains('(')) {
                classCodeWithoutSec = classCodeWithSec.substring(0, classCodeWithSec.indexOf('('));
              } else {
                classCodeWithoutSec = classCodeWithSec;
              }

              names.add(name);

              classesInSemester.add(classCodeWithSec);

              lastFound = timetableStr.lastIndexOf('"id":"', lastFound) + 6;
              subjectIds.add(MapEntry(classCodeWithSec, timetableStr.substring(lastFound, timetableStr.indexOf('"', lastFound))));
              lastFound = timetableStr.indexOf('short":"', lastFound) + 8; // so we dont loop forever

            }

            // TODO: Instead of searching of all the file, cut the string part that you need and use it instead of using the whole file (better performance)

            //print("Resolving all ids with subjectid!");
                { // for each subjectId, we have this:
              List<String> lessonIds; // lessonId is used to find the time for the class
              List<String> classIds, classes;
              List<List<String>> teacherCodesIds, teacherCodes;
              List<List<String>> classroomsIds, classrooms;
              List<int> hrs;
              List<List<int>> beginningHr, day;
              lastFound = classCodesBegin;
              int periodIndex, i;
              int continueAfter; // it is the index number that was used to find the subjectId
              int subjectIndex = 0;

              subjectIds.forEach((subjectId) {
                lessonIds = [];
                classIds = []; classes = [];
                teacherCodesIds = []; teacherCodes = [];
                classroomsIds = []; classrooms = [];
                hrs = [];
                beginningHr = [];
                day = []; // 1 for mon. / 2 for tue. / till 6 for sat.
                continueAfter = classCodesBegin;
                periodIndex = 0;
                String str, str_;

                while (true) { // looping each period because there could multiple periods for a subjectid

                  teacherCodesIds.add([]);
                  classroomsIds.add([]);
                  lastFound = continueAfter = timetableStr.indexOf('"subjectid":"${subjectId.value}"', continueAfter)
                      + '"subjectid":"${subjectId.value}"'.length;
                  if (continueAfter - '"subjectid":"${subjectId.value}"'.length == -1) {
                    break;
                  }

                  i = timetableStr.lastIndexOf('"id":"', lastFound) + 6;
                  lessonIds.add(timetableStr.substring(i, timetableStr.indexOf('"', i)));

                  lastFound = timetableStr.indexOf('teacherids":[', lastFound) + 13;
                  str = timetableStr.substring(lastFound, timetableStr.indexOf(']', lastFound));
                  if (str.isEmpty) {
                    teacherCodesIds.elementAt(periodIndex).add("");
                  } else {
                    int start, end = -1;
                    while (true) { // loop for each teacherCode
                      start = str.indexOf('"', end + 1) + 1;
                      if (start == 0) {
                        break;
                      }
                      end = str.indexOf('"', start);
                      teacherCodesIds.elementAt(periodIndex).add(str.substring(start, end));
                    }
                  }

                  lastFound = timetableStr.indexOf('classids":[', lastFound) + 11;
                  str = timetableStr.substring(lastFound, timetableStr.indexOf(']', lastFound));
                  if (str.isEmpty) {
                    classIds.add("");
                  } else {
                    int start, end = -1;
                    while (true) { // loop for each teacherCode
                      start = str.indexOf('"', end + 1) + 1;
                      if (start == 0) {
                        break;
                      }
                      end = str.indexOf('"', start);
                      str_ = str.substring(start, end);
                      if (!classIds.contains(str_)) {
                        classIds.add(str_);
                      }
                    }
                  }

                  lastFound = timetableStr.indexOf('durationperiods":', lastFound) + 17;
                  hrs.add(int .parse(timetableStr.substring(lastFound, timetableStr.indexOf(',', lastFound))));

                  lastFound = timetableStr.indexOf('classroomidss":[[', lastFound) + 17;
                  str = timetableStr.substring(lastFound, timetableStr.indexOf(']]', lastFound) );
                  if (str.isEmpty) {
                    classroomsIds.elementAt(periodIndex).add("");
                  } else {
                    int start, end = -1;
                    while (true) { // loop for each teacherCode
                      start = str.indexOf('"', end + 1) + 1;
                      if (start == 0) {
                        break;
                      }
                      end = str.indexOf('"', start);
                      classroomsIds.elementAt(periodIndex).add(str.substring(start, end));
                    }
                  }

                  periodIndex++;

                }

                //TODO: use the lessonIds, departmentIds, teacherCodesIds, classroomIds to find the rest of the data

                // lessons:
                int searchStart = timetableStr.indexOf("lessonid"), searchStart_;
                int listIndex = 0;
                lessonIds.forEach((lessonId) {

                  searchStart_ = searchStart;
                  day.add([]);
                  beginningHr.add([]);
                  while (true) { // because we might have the same lessonid with different days and begging hours
                    lastFound = timetableStr.indexOf('lessonid":"$lessonId"', searchStart_) + 'lessonid":"$lessonId"'.length;
                    searchStart_ = lastFound;
                    str = timetableStr.substring(timetableStr.indexOf('period":"', lastFound) + 9, timetableStr.indexOf('","days"', lastFound));
                    if (str.isNotEmpty) {
                      beginningHr[listIndex].add(int.parse(str));
                    }
                    lastFound = timetableStr.indexOf('days":"', lastFound) + 7;
                    day[listIndex].add(timetableStr.substring(lastFound, timetableStr.indexOf('"', lastFound)).indexOf('1') + 1);
                    if (!timetableStr.contains('lessonid":"$lessonId"', searchStart_)) {
                      break;
                    }

                  }
                  listIndex++;

                });

                // This will only enhance the peroformance of the engineering loading page,
                // TODO: apply the rest for the other faculties:
                // AE 1 is only for the first semester...
                //searchStart = faculty == "Engineering" ? (timetableStr.indexOf('"name":"AE 1 ","short":"AE 1 ","teacherid":""') - 57) : 0;
                searchStart = 0;

                // departments (classIds):
                classIds.forEach((element) {
                  if (element.isNotEmpty) {
                    lastFound = searchStart_ = timetableStr.indexOf('"id":"$element","name":"', searchStart) + 16 +
                        element.length;
                    str = timetableStr.substring(
                        lastFound, timetableStr.indexOf('"', lastFound));
                    classes.add(str);
                  }
                });

                // TODO: This only works for eng and civ aviation facs, make it for all the facs too:
                //searchStart = timetableStr.indexOf('"id":"teachers","name":"Öğretim Elemanları","item_name":"Öğretim Elemanı"');
                searchStart = 0;

                // teacherCodes:
                periodIndex = 0;
                teacherCodesIds.forEach((element1) {
                  if (element1.isNotEmpty) {
                    teacherCodes.add([]);
                    element1.forEach((element2) {
                      if (element2.isNotEmpty) {
                        lastFound = timetableStr.indexOf('"id":"$element2","short":"', searchStart) +
                            17 + element2.length;
                        str = timetableStr.substring(lastFound, timetableStr.indexOf('"', lastFound));
                        teacherCodes.elementAt(periodIndex).add(str);

                      }
                    });
                    periodIndex++;
                  }
                });
                //print("$teacherCodesIds");
                //print("$teacherCodes");

                // classrooms:
                searchStart = timetableStr.indexOf('id":"buildings","name":"Binalar","item_name":"Bina","icon"'); // the icon file could change which could break the whole thing!
                periodIndex = 0;
                classroomsIds.forEach((element1) {
                  if (element1.isNotEmpty){
                    classrooms.add([]);
                    element1.forEach((element2) {
                      if (element2.isNotEmpty) {
                        lastFound = timetableStr.indexOf('"id":"$element2', searchStart) + 6 + element2.length;
                        lastFound = timetableStr.indexOf('short":"', lastFound) + 8; // find the short, not the name
                        classrooms.elementAt(periodIndex).add(timetableStr.substring(lastFound, timetableStr.indexOf('"', lastFound)));
                      }
                    });
                    periodIndex++;
                  }
                });

                // TODO: then fill it inside this class
                subjects.add(Subject(customName: names[subjectIndex], hours: hrs, bgnPeriods: beginningHr, classCode: subjectId.key,
                    classrooms: classrooms, days: day, departments: classes, teacherCodes: teacherCodes));

                subjectIndex++;

              });
            } // end for each subject

            //facultyData.subjects = subjects;
            // TO SEE THE RESULTS ONLY /
            //facultyData.subjects.forEach((element) {print("${element.classCode} : $element");});
            sPort.send(["facultyData", subjects]); // Main.facultyData = facultyData;

            sPort.send(["setState", 4]); // state = 4;

          }

        } else {
          print("ERROR, the received message is not a list!");
        }
      } catch(error) {
        print("ERROR: an error was found inside the data classification function: \n${error.toString()}");
        sPort.send(["error", error]);
      }

    });

    sPort.send(["sPort", rPort.sendPort]);
    //rPort.close(); // it is causing the app to freeze

  }

  static WebpageState? currWidget;

  void finish() {

    Navigator.pushNamed(context, "/home");

  }

}
