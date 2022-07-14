import 'dart:isolate';
import 'package:stream_channel/stream_channel.dart';

import 'package:ders_program_test/pages/loading_update_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ders_program_test/main.dart';
import 'package:ders_program_test/others/subject.dart';

import 'others/departments.dart';

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

    /*WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Navigator.pushNamed(context, "/loadingupdate");
      ;
    });*/
    super.initState();

    currentState = this;

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
                            sPort?.send(["timetableData", request.responseText]);
                          }

                          if (msg[0] == "setDoNotRestart") {
                            doNotRestart = true;
                          }

                          if (msg[0] == "facultyData") { // Main.facultyData =
                            Main.facultyData = FacultySemester(facName: Main.faculty, lastUpdate: DateTime.now());
                            Main.facultyData.subjects = msg[1] as List<Subject>;
                          }

                          if (msg[0] == "setState") { // Main.facultyData =
                            currWidget = this;
                            state = msg[1] as int;
                            //rPort.close(); // it is causing the app to freeze!
                            isolate?.kill();
                            //
                          }

                        } else {
                          print("The received object is NOT A LIST!!!");
                        }
                      });

                      isolate = (await Isolate.spawn(dataClassification, rPort.sendPort));
                    }
                    else { // if the response is empty then smth is wrong, restart!
                      Main.restart();
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

  // TODO: Make multiple threads inside this function to finish faster
  static void dataClassification(SendPort sPort) {

    ReceivePort rPort = ReceivePort();

    rPort.listen((msg) {

      if (msg is List) {

        if (msg[0] == "timetableData") {

          String timetableStr = msg[1];

          print("Starting classification:\n");
          sPort.send(["setDoNotrestart"]); // doNotRestart = true;

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

          print("Resolving all ids with subjectid!");
          // TODO: Second, store all the classcodes with their data in Main.semesters
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

              // departments (classIds):
              classIds.forEach((element) {
                if (element.isNotEmpty) {
                  lastFound = timetableStr.indexOf('"id":"$element","name":"') + 16 +
                      element.length;
                  str = timetableStr.substring(
                      lastFound, timetableStr.indexOf('"', lastFound));
                  classes.add(str);
                }
              });

              // teacherCodes:
              periodIndex = 0;
              teacherCodesIds.forEach((element1) {
                if (element1.isNotEmpty) {
                  teacherCodes.add([]);
                  element1.forEach((element2) {
                    if (element2.isNotEmpty) {
                      lastFound = timetableStr.indexOf('"id":"$element2","short":"') +
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
              searchStart = timetableStr.indexOf('/global/pics/ui/classroom_32.svg');
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

    });

    sPort.send(["sPort", rPort.sendPort]);
    //rPort.close(); // it is causing the app to freeze

  }

  static WebpageState? currWidget;

  void finish() {

    print("Finishing the webpage off!");
    Navigator.pushNamed(context, "/home");

  }

}
