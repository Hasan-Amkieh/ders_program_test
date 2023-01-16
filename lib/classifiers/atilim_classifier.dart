// NOTE: This is the code meant for version 1.4.0 of Atsched, it extracted the info correctly for the semester "2022-2023 FALL"

import 'dart:isolate';

import 'package:Atsched/classifiers/classifier.dart';

import '../others/subject.dart';

class AtilimClassifier extends Classifier {

  @override
  void classifyData(SendPort sPort) {

    print("Classification has begun!");

    ReceivePort rPort = ReceivePort();

    rPort.listen((msg) {

      try {
        if (msg is List) {

          if (msg[0] == "timetableData") {

            print("Timetable data received!");
            String timetableStr = msg[1];

            //print("Starting classification:\n");
            sPort.send(["setDoNotRestart"]); // doNotRestart = true;

            //FacultySemester facultyData = FacultySemester(facName: Main.faculty, lastUpdate: DateTime.now());

            List<String> names = [];
            List<MapEntry<String, String>> subjectIds = [];
            List<Subject> subjects = [];

            int classCodesEnd = 0, classCodesBegin;
            classCodesEnd = timetableStr.indexOf(
                '{id: picture_url, name: Fotoğraf}, {id: timeoff, type: object, name: Zaman Tablosu}, {id: contract_weight, type: float, name: Öğretmen Sözleşmesi İçin Uzunluk Değeri}]', 0);
            classCodesBegin = timetableStr.indexOf("data_rows", classCodesEnd) + 9;
            classCodesEnd = timetableStr.indexOf("data_columns", classCodesBegin);

            int lastFound = classCodesBegin;
            String name = "", classCodeWithSec;
            while (lastFound < classCodesEnd) {

              lastFound = timetableStr.indexOf('name: ', lastFound) + 6;
              name = timetableStr.substring(lastFound, timetableStr.indexOf(',', lastFound));

              lastFound = timetableStr.indexOf('short: ', lastFound) + 7;
              classCodeWithSec = timetableStr.substring(lastFound, timetableStr.indexOf(',', lastFound));

              names.add(name);

              lastFound = timetableStr.lastIndexOf('id: ', lastFound) + 4;
              subjectIds.add(MapEntry(classCodeWithSec, timetableStr.substring(lastFound, timetableStr.indexOf(',', lastFound))));
              lastFound = timetableStr.indexOf('short: ', lastFound) + 8; // so we dont loop forever

            }

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
                  lastFound = continueAfter = timetableStr.indexOf('subjectid: ${subjectId.value},', continueAfter)
                      + 'subjectid: ${subjectId.value},'.length;
                  if (continueAfter - 'subjectid: ${subjectId.value},'.length == -1) {
                    break;
                  }

                  i = timetableStr.lastIndexOf('{id: ', lastFound) + 5;
                  // if (subjectId.key.contains("MATH151- 01-")) {
                  //   print("adding lessonId ${timetableStr.substring(i, timetableStr.indexOf(',', i))} to the course MATH151- 01-");
                  // }
                  lessonIds.add(timetableStr.substring(i, timetableStr.indexOf(',', i)));

                  lastFound = timetableStr.indexOf('teacherids: [', lastFound) + 13;
                  str = timetableStr.substring(lastFound, timetableStr.indexOf(']', lastFound) + 1);
                  if (str.isEmpty) {
                    teacherCodesIds.elementAt(periodIndex).add("");
                  } else {
                    int start = 0;
                    while (true) { // loop for each teacherCode
                      if (!str.contains(',', start + 1)) {
                        teacherCodesIds.elementAt(periodIndex).add(str.substring(start, str.indexOf(']', start)));
                        break;
                      }
                      teacherCodesIds.elementAt(periodIndex).add(str.substring(start, str.indexOf(',', start)));
                      start = str.indexOf(',', start) + 2; // bcs after the comma there is a space
                    }
                  }

                  lastFound = timetableStr.indexOf('classids: [', lastFound) + 11;
                  str = timetableStr.substring(lastFound, timetableStr.indexOf(']', lastFound) + 1);
                  if (str.isEmpty) {
                    classIds.add("");
                  } else {
                    int start = 0;
                    while (true) { // loop for each classid
                      /*if (!str.contains(',', start + 1)) {
                        teacherCodesIds.elementAt(periodIndex).add(str.substring(start, str.indexOf(']', start)));
                        break;
                      }
                      teacherCodesIds.elementAt(periodIndex).add(str.substring(start, str.indexOf(',', start)));
                      start = str.indexOf(',', start) + 2; // bcs after the comma there is a space*/
                      if (!str.contains(',', start + 1)) {
                        if (!classIds.contains(str.substring(start, str.indexOf(']', start)))) {
                          classIds.add(str.substring(start, str.indexOf(']', start)));
                        }
                        break;
                      }
                      str_ = str.substring(start, str.indexOf(',', start));
                      if (!classIds.contains(str_)) {
                        classIds.add(str_);
                      }
                      start = str.indexOf(',', start) + 2;
                    }
                  }

                  lastFound = timetableStr.indexOf('durationperiods: ', lastFound) + 17;
                  hrs.add(int.parse(timetableStr.substring(lastFound, timetableStr.indexOf(',', lastFound))));

                  // lastFound = timetableStr.indexOf('classroomidss":[[', lastFound) + 17;
                  // str = timetableStr.substring(lastFound, timetableStr.indexOf(']]', lastFound) );
                  // if (str.isEmpty) {
                  //   classroomsIds.elementAt(periodIndex).add("");
                  // } else {
                  //   int start, end = -1;
                  //   while (true) { // loop for each teacherCode
                  //     start = str.indexOf('"', end + 1) + 1;
                  //     if (start == 0) {
                  //       break;
                  //     }
                  //     end = str.indexOf('"', start);
                  //     classroomsIds.elementAt(periodIndex).add(str.substring(start, end));
                  //   }
                  // }

                  periodIndex++;

                }

                // lessons:
                int searchStart = timetableStr.indexOf("lessonid"), searchStart_;
                int listIndex = 0;
                int classroomsIndex = 0;
                lessonIds.forEach((lessonId) {
                  searchStart_ = searchStart;
                  day.add([]);
                  beginningHr.add([]);
                  while (true) { // because we might have the same lessonid with different days and begging hours
                    lastFound = timetableStr.indexOf('lessonid: $lessonId,', searchStart_) + 'lessonid: $lessonId,'.length;
                    searchStart_ = lastFound;
                    str = timetableStr.substring(timetableStr.indexOf('period: ', lastFound) + 8, timetableStr.indexOf(', days', lastFound));
                    if (str.isNotEmpty) {
                      beginningHr[listIndex].add(int.parse(str));
                    }
                    lastFound = timetableStr.indexOf('days: ', lastFound) + 6;
                    day[listIndex].add(timetableStr.substring(lastFound, timetableStr.indexOf(RegExp("[\\,\\]]"), lastFound)).indexOf('1') + 1);

                    // classrooms:
                    lastFound = timetableStr.indexOf('classroomids: [', lastFound) + 15;
                    str = timetableStr.substring(lastFound, timetableStr.indexOf(']', lastFound) + 1);
                    if (str.isEmpty) {
                      classroomsIds.elementAt(periodIndex).add("");
                    } else {
                      int start = 0;
                      while (true) { // loop for each classroom id
                        if (classroomsIds.length <= classroomsIndex) {
                          classroomsIds.add([]);
                        }
                        if (!str.contains(',', start + 1)) {
                          classroomsIds.elementAt(classroomsIndex).add(str.substring(start, str.indexOf(']', start)));
                          break;
                        }
                        classroomsIds.elementAt(classroomsIndex).add(str.substring(start, str.indexOf(',', start)));
                        start = str.indexOf(',', start) + 2; // bcs after the comma there is a space
                      }
                      classroomsIndex++;
                    }
                    // classrooms;

                    if (!timetableStr.contains('lessonid: $lessonId,', searchStart_)) {
                      break;
                    }

                  }
                  listIndex++;

                });

                searchStart = 0;

                // departments (classIds):
                classIds.forEach((element) {
                  if (element.isNotEmpty) {
                    lastFound = searchStart_ = timetableStr.indexOf('id: $element, name:', searchStart) + 11 +
                        element.length;
                    str = timetableStr.substring(
                        lastFound, timetableStr.indexOf(RegExp("[\\,\\]]"), lastFound));
                    classes.add(str);
                  }
                });

                searchStart = 0;

                // teacherCodes:
                periodIndex = 0;
                teacherCodesIds.forEach((element1) {
                  if (element1.isNotEmpty) {
                    teacherCodes.add([]);
                    element1.forEach((element2) {
                      if (element2.isNotEmpty) {
                        lastFound = timetableStr.indexOf('id: $element2, short: ', searchStart) +
                            13 + element2.length;
                        str = timetableStr.substring(lastFound, timetableStr.indexOf(RegExp("[\\,\\]]"), lastFound));
                        teacherCodes.elementAt(periodIndex).add(str);

                      }
                    });
                    periodIndex++;
                  }
                });
                //print("$teacherCodesIds");
                //print("$teacherCodes");

                // classrooms:
                searchStart = timetableStr.indexOf('id: buildings, name: Binalar, item_name: Bina, icon'); // the icon file could change which could break the whole thing!
                periodIndex = 0;
                classroomsIds.forEach((element1) {
                  if (element1.isNotEmpty){
                    classrooms.add([]);
                    element1.forEach((element2) {
                      if (element2.isNotEmpty) {
                        lastFound = timetableStr.indexOf('id: $element2', searchStart) + 4 + element2.length;
                        lastFound = timetableStr.indexOf('short: ', lastFound) + 7; // find the short, not the name
                        classrooms.elementAt(periodIndex).add(timetableStr.substring(lastFound, timetableStr.indexOf(RegExp("[\\,\\]]"), lastFound)));
                      }
                    });
                    periodIndex++;
                  }
                });

                // Translate the bgnHrs into the corresponding clock hours, they are originally 9:30 - 1 / 10:30 - 2 and so on
                for (int i = 0 ; i < beginningHr.length ; i++) {
                  for (int j = 0 ; j < beginningHr[i].length ; j++) {
                    beginningHr[i][j] = beginningHr[i][j] + 8;
                    if (beginningHr[i][j] >= 24) {
                      beginningHr[i][j] = beginningHr[i][j] - 24;
                    }
                  }
                }

                // If the day is not between 1 - 7 then that period should be deleted:

                for (int i = 0 ; i < day.length ; i++) {
                  for (int j = 0 ; j < day[i].length ; j++) {
                    if (day[i][j] < 1 || day[i][j] > 7) {
                      // print("A day out of the range is found at : ${names[subjectIndex]}");
                      day.removeAt(i);
                      if (beginningHr.length > i) {
                        beginningHr.removeAt(i);
                      }
                      if (hrs.length > i) {
                        hrs.removeAt(i);
                      }
                      break;
                    }
                  }
                }

                // print("${names[subjectIndex]} has the hrs $hrs");

                // TEST:
                // if (subjectId.key.contains("MATH151")) {
                //   print("Changing ${subjectId.key}");
                //   hrs[hrs.length - 1] = hrs[hrs.length - 1] + 1;
                //   classrooms[classrooms.length - 1][0] = "B2000";
                // }
                // TEST;

                subjects.add(Subject(customName: names[subjectIndex], hours: hrs, bgnPeriods: beginningHr, courseCode: subjectId.key,
                    classrooms: classrooms, days: day, departments: classes, teacherCodes: teacherCodes));

                subjectIndex++;

              });
            } // end for each subject

            //facultyData.subjects = subjects;
            // TO SEE THE RESULTS ONLY /
            //facultyData.subjects.forEach((element) {print("${element.courseCode} : $element");});
            sPort.send(["facultyData", subjects]); // Main.facultyData = facultyData;

            sPort.send(["setState", 4]); // state = 4;
            print("Classification is done!");

          }

        } else {
          print("ERROR, the received message is not a list!");
        }
      } catch(error, stacktrace) {
        print("ERROR: an error was found inside the data classification function: \n${error.toString()}\n${stacktrace.toString()}");
        sPort.send(["error", error]);
      }

    });

    sPort.send(["sPort", rPort.sendPort]);
    //rPort.close(); // it is causing the app to freeze

  }

  AtilimClassifier._privateConstructor();

  static late final Classifier instance = AtilimClassifier._privateConstructor();


}
