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

  @override
  void initState() {

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Navigator.pushNamed(context, "/loadingupdate");
      ;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
          child: Visibility(
              visible: false,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              // These properties will make the webpage load but nothing is shown on the display
              child: InAppWebView(
                  onAjaxReadyStateChange: (controller, request) async {
                    if (request.url
                        .toString()
                        .contains("__func=regularttGetData") &&
                        request.readyState == AjaxRequestReadyState.DONE) {
                      state = 3;
                      print("Timetable Retrieved!\nLength of the response: ${request.responseText?.length}");
                      dataClassification(request.responseText);
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
                  onLoadStart: (controller, url) async {
                    print("Loading of te page started!");
                    state = 1;
                  },
                  onLoadStop: (controller, url) async {
                    print("Loading of the page finished!");
                    state = 2;
                  }))),
    );
  }

  // TODO: Make this in a different class, because if it fails retrieving the data or connecting to the internet, then go to Home and load it again in the background
  // TODO: Make multiple threads inside this function to finish faster
  void dataClassification(String? timetableStr) {

    timetableStr ??= "";
    if (timetableStr.isEmpty) {
      print("ERROR: Data classification could not be done because it is empty or null!");
    }

    print("Starting classification:\n");

    //int validStart = timetableStr.indexOf("Validity:", 0)+10;
    //print("Found validStart at $validStart");
    // TODO: Wait for two semesters to show up to understand how the validity date works
    //String dateStr = timetableStr.substring(validStart, timetableStr.indexOf("-", validStart));
    Main.semesters.add(FacultySemester(facName: Main.faculty, validDate: DateTime.now(), lastUpdate: DateTime.now()));

    // Finding all the classcodes with their names
    var classCodes_names = Main.classcodes;
    var classesInSemester = [];
    List<MapEntry<String, String>> subjectIds = [];
    List<Subject> subjects = [];

    int classCodesEnd, classCodesBegin;
    classCodesEnd = timetableStr.indexOf(
        '{"id":"picture_url","name":"Fotoğraf"},{"id":"timeoff","type":"object","name":"Zaman Tablosu"},{"id":"contract_weight","type":"float","name":"Öğretmen Sözleşmesi İçin Uzunluk Değeri"}]', 0);
    classCodesBegin = timetableStr.indexOf("data_rows", classCodesEnd) + 9;
    classCodesEnd = timetableStr.indexOf("data_columns", classCodesBegin);

    int lastFound = classCodesBegin;
    String name, classCodeWithSec, classCodeWithoutSec;
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

      if (!classCodes_names.containsKey(classCodeWithoutSec)) {
        classCodes_names.addEntries([MapEntry(classCodeWithoutSec, name)]);
      }
      classesInSemester.add(classCodeWithSec);

      lastFound = timetableStr.lastIndexOf('"id":"', lastFound) + 6;
      subjectIds.add(MapEntry(classCodeWithSec, timetableStr.substring(lastFound, timetableStr.indexOf('"', lastFound))));
      lastFound = timetableStr.indexOf('short":"', lastFound) + 8; // so we dont loop forever

    }

    Main.classcodes = classCodes_names;
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
          lastFound = continueAfter = timetableStr!.indexOf('"subjectid":"${subjectId.value}"', continueAfter)
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
        if (subjectId.key.contains("NURS102")) {
          print("Triggered!");
        }
        lessonIds.forEach((lessonId) {

          searchStart_ = searchStart;
          day.add([]);
          beginningHr.add([]);
          while (true) { // because we might have the same lessonid with different days and begging hours
            lastFound = timetableStr!.indexOf('lessonid":"$lessonId"', searchStart_) + 'lessonid":"$lessonId"'.length;
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
            lastFound = timetableStr!.indexOf('"id":"$element","name":"') + 16 +
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
                lastFound = timetableStr!.indexOf('"id":"$element2","short":"') +
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
                lastFound = timetableStr!.indexOf('"id":"$element2', searchStart) + 6 + element2.length;
                lastFound = timetableStr.indexOf('short":"', lastFound) + 8; // find the short, not the name
                classrooms.elementAt(periodIndex).add(timetableStr.substring(lastFound, timetableStr.indexOf('"', lastFound)));
              }
            });
            periodIndex++;
          }
        });

        // TODO: then fill it inside this class
        subjects.add(Subject(hours: hrs, bgnPeriods: beginningHr, classCode: subjectId.key,
            classrooms: classrooms, days: day, departments: classes, teacherCodes: teacherCodes));

      });
    } // end for each subject

    Main.semesters.elementAt(0).subjects = subjects;
    // TO SEE THE RESULTS ONLY /
    Main.semesters.elementAt(0).subjects.forEach((element) {print("${element.classCode} : $element");});

    state = 4;

    // TODO: Store all the data inside all the appropriate files
    ;

    currWidget = this;
    state = 5; // Finish off, pop the loadingPage

  }

  static WebpageState? currWidget;

  void finish() {

    print("Finishing the webpage off!");
    Navigator.popAndPushNamed(context, "/home");

  }

}
