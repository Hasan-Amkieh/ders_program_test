
import 'dart:isolate';

import 'package:Atsched/classifiers/classifier.dart';

import '../others/subject.dart';

class BilkentClassifier extends Classifier {

  @override
  void classifyData(SendPort sPort) {

    ReceivePort rPort = ReceivePort();

    rPort.listen((msg) {

      try {
        if (msg is List) {

          if (msg[0] == "timetableData") {

            Map timetableData = msg[1];

            print("Starting classification:\n");
            sPort.send(["setDoNotRestart"]); // doNotRestart = true;

            //FacultySemester facultyData = FacultySemester(facName: Main.faculty, lastUpdate: DateTime.now());

            List<Subject> subjects = [];

            // List<String> classes; // in other words, departments
            List<List<String>> teacherCodes = [];
            List<List<String>> classrooms = [];
            List<int> hrs = [];
            List<List<int>> beginningHr = [], day = [];

            String courseCode, courseName;

            // Omit the faculty, it is unnecessary
            timetableData.values.toList().forEach((groupOfSubs) { //

              for (int i = 0 ; i < (groupOfSubs as Map).length ; i++) {

                courseCode = groupOfSubs.keys.toList()[i]; // the course code does have the section number

                courseName = groupOfSubs.values.toList()[i]["name"];
                Map<String, dynamic> // Map<String, Map<String, dynamic /*could be map or str*/>>
                secsInfo = groupOfSubs.values.toList()[i]["sections"];

                int countSecs = 0;
                for (int j = 1 ; countSecs < secsInfo.length ; j++) { // j is the section number
                  // Has two keys, instructor and schedule

                  if (secsInfo["$j"] == null) {
                    continue;
                  } else {
                    countSecs++;
                  }

                  day = []; beginningHr = []; hrs = []; classrooms = [];

                  teacherCodes = [[secsInfo["$j"]!["instructor"]]];
                  (secsInfo["$j"]!["schedule"] as Map<String, dynamic>).forEach((key, value) { // Looping through each period of a course section
                    // the key is the box number and the value is the classroom
                    // the box number starts counting from 0, the days are from mon. till sunday
                    // the hours are from 8:30 till 21:30
                    // examples: 0 means mon. 8:30 - 9:20 / 7 means mon. 9:30 - 10:20
                    // use the reminder of 7 to get the day number 0 - 6 = 1 - 7
                    // use the division on 7 and grounding the result to get the bgnHr 0 - 13 = 8 - 21
                    // the hours are by default 1 hour

                    day.add([(int.parse(key) % 7) + 1]);
                    beginningHr.add([(int.parse(key) / 7).floor() + 8]);
                    hrs.add(1); // it is always for 1 hr

                    classrooms.add([value]);

                  });

                  // If one of the periods is on the same day and the (bgnHr + hrs) diff. with bgnHr of the other period is 0 and the classroom is the same
                  // then combine them into one period, otherwise leave them unchanged:

                  for (int pIndex1 = 0 ; pIndex1 < day.length ; pIndex1++) {
                    for (int pIndex1_ = 0 ; pIndex1_ < day[pIndex1].length ; pIndex1_++) {
                      for (int pIndex2 = 0 ; pIndex2 < day.length ; pIndex2++) {
                        for (int pIndex2_ = 0 ; pIndex2_ < day[pIndex2].length ; pIndex2_++) {
                          if (pIndex1 != pIndex2) {
                            if (day[pIndex1][pIndex1_] == day[pIndex2][pIndex2_]) { // if the day is the same
                              if (((beginningHr[pIndex1][pIndex1_] + hrs[pIndex1]) - beginningHr[pIndex2][pIndex2_]).abs() == 0 &&
                                  classrooms[pIndex1][pIndex1_] == classrooms[pIndex2][pIndex2_]) {

                                hrs[pIndex1] = hrs[pIndex1] + 1;
                                if (beginningHr[pIndex1][pIndex1_] > beginningHr[pIndex2][pIndex2_]) {
                                  beginningHr[pIndex1][pIndex1_] = beginningHr[pIndex2][pIndex2_];
                                }

                                day[pIndex2].removeAt(pIndex2_);
                                beginningHr[pIndex2].removeAt(pIndex2_);
                                hrs.removeAt(pIndex2);
                                classrooms[pIndex2].removeAt(pIndex2_);
                                // teacherCodes[pIndex2].removeAt(pIndex2_);

                                if (pIndex2_ - 1 < day[pIndex2].length) {
                                  pIndex2_--;
                                  if (pIndex2_ < 0) {
                                    pIndex2_ = 0;
                                  }
                                }

                                if (day[pIndex2].isEmpty) {
                                  day.removeAt(pIndex2);
                                  beginningHr.removeAt(pIndex2);
                                  classrooms.removeAt(pIndex2);
                                  // teacherCodes.removeAt(pIndex2);
                                  pIndex2--;
                                  break;
                                }

                              }
                            }
                          }
                        }
                      }
                    }
                  }

                  // Then add the subject:
                  subjects.add(Subject(courseCode: courseCode.replaceAll(" ", "") + "-" + (j < 10 ? "0" : "") + "$j",
                      customName: courseName, departments: [],
                      teacherCodes: teacherCodes, days: day, bgnPeriods: beginningHr,
                      hours: hrs, classrooms: classrooms));

                }

              }

            });

            // TO SEE THE RESULTS ONLY /
            //facultyData.subjects.forEach((element) {print("${element.courseCode} : $element");});
            sPort.send(["facultyData", subjects]); // Main.facultyData = facultyData;

            sPort.send(["setState", 4]); // state = 4;

          }

        } else {
          print("ERROR, the received message is not a list!");
        }
      } catch(error, stacktrace) {
        print("ERROR: an error was found inside the data classification function: \n${error.toString()}\nStacktrace: " + stacktrace.toString());
        sPort.send(["error", error]);
      }

    });

    sPort.send(["sPort", rPort.sendPort]);
    //rPort.close(); // it is causing the app to freeze

  }

  BilkentClassifier._privateConstructor();

  static late final Classifier instance = BilkentClassifier._privateConstructor();


}
