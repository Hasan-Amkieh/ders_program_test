
import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpClient, Platform;
import 'dart:isolate';

import 'package:Atsched/wp_phone.dart';
import 'package:dio/dio.dart';

import 'package:Atsched/scrapers/scraper.dart';
import 'package:Atsched/wp_computer.dart';

import '../main.dart';
import '../others/subject.dart';
import '../others/university.dart';
import '../pages/loading_update_page.dart';

class AtilimScraperComputer extends Scraper {

  static doesContainMonth(String str) {
    const l = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    for (String s in l) {
      if (str.contains(s)) {
        return true;
      }
    }
    return false;
  }

  String timetableData = "";

  static final Dio _dio = Dio();

  @override
  void getTimetableData() async { // controller and request pars are only for the phone version

    await University.getFacultyLink(Main.department);

    try {

      // sends the request

      String str = (await University.getFacultyLink(Main.department));
      int tdNum = int.parse(str.substring(str.indexOf('num=') + 4, str.indexOf('&', str.indexOf('num=') + 4)));
      String domain = str.substring(0, str.indexOf('/timetable'));

      var headers = {
        'authority': domain.substring(8), // https://
        'origin': domain,
        'referer': domain,
        'cookie' : "PHPSESSID=3c6a20fde6e9fdae72ad787719a257b1"
      };
      // print("headers are : $headers");

      var response = await _dio.post(domain + "/timetable/server/regulartt.js?__func=regularttGetData", options: Options(contentType: "application/json",headers: headers),
          data: '{"__args" : [null,"$tdNum"],"__gsh" : "00000000"}',
      );

      // print("The status code is : ${response.statusCode}");
      // print("Response: ${response.data.toString()}");
      // transforms and prints the response
      if (response.statusCode == 200) {
        timetableData = response.data.toString();
        // print("The new length of the timetable is : ${timetableData.length}");
      }
      _dio.close();

      // print("found the following links: "
      //     "${Main.artsNSciencesLink}\n${Main.fineArtsLink}\n${Main.businessLink}\n${Main.engineeringLink}\n${Main.civilAviationLink}\n${Main.healthSciencesLink}\n${Main.lawLink}");


    } catch (e, stacktrace) {
      print("ERROR: $e\n$stacktrace");
    }

    // debugPrint(timetableData, wrapWidth: 1024);
    {
      {
        // print("timetable DATA: $timetableData\n\n\n");
        if (timetableData.length > 1000) { // then it is a success
          // print("The timetable has been received!\nSuccess!!!");
          if (timetableData.isNotEmpty) { // ROOT:
            // print("Pre classification");
            if (Platform.isWindows) {
              WPComputerState.state = 3;
            } else {
              WPPhoneState.state = 3;
            }
            // print("Timetable Retrieved!\nLength of the response: ${timetableData.length}");
            //dataClassification(request.responseText);
            ReceivePort rPort = ReceivePort();
            SendPort? sPort;
            Isolate? isolate;

            rPort.listen((msg) {
              if (msg is List) {

                // print("RECEIVED FROM THE ISOLATE: " + msg[0].toString());

                if (msg[0] == "sPort") {
                  sPort = msg[1] as SendPort;
                  sPort?.send(["timetableData", timetableData, Main.faculty]);
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
                // print("The received object is NOT A LIST!!!");
              }
            });

            isolate = (await Isolate.spawn(Main.classifier.classifyData, rPort.sendPort));
            // print("Isolate spawned!");
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
      }  {
        // debugPrint('evaluateJavaScript error: $e\n');
      }
    }

    // Do the exams:

    String htmlPage = "";
    String sem = Main.semesterName.toLowerCase();
    sem = sem.substring(0, (sem.contains("fall") ? (sem.indexOf("fall") + 4) : (sem.indexOf("spring") + 6)) + 1);
    // print("sem name is $sem");
    try {

      var request = await (HttpClient()..connectionTimeout = const Duration(seconds: 5)).getUrl(Uri.parse('https://www.atilim.edu.tr/en/dersprogrami#content_tab_tab_0_1_0_1_1_2'));
      var response = await request.close();

      if (response.statusCode == 200) {
        await for (var contents in response.transform(const Utf8Decoder())) {
          htmlPage += contents.toLowerCase();
        }
      }
    } catch (e) {
      print("ERROR: $e");
    }

    htmlPage = htmlPage.replaceAll("&nbsp;", " ");

    List<String> examLinks = [];
    int pos = 0;
    String str;
    while (pos != -1) {
      pos = htmlPage.indexOf(sem, pos + 50);
      // print("index found at : $pos");
      if (pos == -1) {
        break;
      }
      if (htmlPage.substring(pos, htmlPage.indexOf('<', pos)).contains("exam schedule")) { // an exam link was found:
        str = htmlPage.substring(pos, htmlPage.indexOf("</table>", pos)); // this string may contain multiple exam links:
        int pos_ = str.indexOf("https://dersprogramiyukle");
        while (pos_ != -1) {

          examLinks.add(str.substring(pos_, str.indexOf('"', pos_)));

          pos_ = str.indexOf("https://dersprogramiyukle", pos_ + 30);
        }
        // then find the second table:
        pos = htmlPage.indexOf("</table>", pos) + 10;
        str = htmlPage.substring(pos, htmlPage.indexOf("</table>", pos)); // this string may contain multiple exam links:
        pos_ = str.indexOf("https://dersprogramiyukle");
        while (pos_ != -1) {

          examLinks.add(str.substring(pos_, str.indexOf('"', pos_)));

          pos_ = str.indexOf("https://dersprogramiyukle", pos_ + 30);
        }
      }
    }

    // print("Found examlinks: ${examLinks}");

    // Then extract all the exams from each link:
    examLinks.forEach((element) async {
      try {
        var request = await (HttpClient()..connectionTimeout = const Duration(seconds: 5)).getUrl(Uri.parse(element + "/index_files/sheet001.htm")); // This page uses frames, but your browser doesn't support them
        var response = await request.close();
        htmlPage = "";

        if (response.statusCode == 200) {
          await for (var contents in response.transform(const Utf8Decoder())) {
            htmlPage += contents;
          }
        }
      } catch(e) {
        print("ERROR: $e");
      }

      try {

        htmlPage = htmlPage.substring(htmlPage.toLowerCase().indexOf("course code"));
        List<String> cols;
        String subject, classrooms, date, time;
        htmlPage.split("<tr ").forEach((row) {

          try {
            cols = row.split("</td>");
            subject = "";
            classrooms = "";
            date = "";
            time = "";
            int indicator = 0;
            if (!cols[0].toLowerCase().contains("course code") &&
                !cols[1].toLowerCase().contains("course code") &&
                !cols[0].contains(sem.split(" ").toList()[0]) &&
                !cols[1].contains(sem.split(" ").toList()[0])) {
              for (int i = 0 ; i < cols.length; i++, indicator++) {
                if (cols[i].contains("&nbsp;") || doesContainMonth(cols[i])) { // if an empty cell or the date column (always contains a month) is found, then skip it
                  indicator--;
                  continue;
                }
                switch (indicator) {
                  case 0:
                    subject = cols[i].substring(cols[i].lastIndexOf(">") + 1);
                    break;
                  case 1:
                    classrooms = cols[i].substring(cols[i].lastIndexOf(">") + 1);
                    break;
                  case 2:
                    date = cols[i].substring(cols[i].lastIndexOf(">") + 1);
                    break;
                  case 3:
                    time = cols[i].substring(cols[i].lastIndexOf(">") + 1);
                    break;
                }
              }
              print("$subject $classrooms $date $time");
              List<String> data = date.split('.');
              // print("$date became $data");
              if (data.length == 3 && subject.length < 50) {
                if (data[2].length == 2) { // sometimes it is 23, where it should be 2023
                  data[2] = "20" + data[2];
                }
                var date_ = DateTime(int.parse(data[2]), int.parse(data[1]), int.parse(data[0]));
                if (subject.isNotEmpty && data.isNotEmpty && DateTime.now().isBefore(date_)) {
                  // For some reason, many exams are being repeated, so check if it exists first or not:
                  if (!doesExamExist(subject.replaceAll("\n", ""), date_, time.replaceAll("\n", ""))) {
                    Main.exams.add(Exam(
                        subject: subject.replaceAll("\n", ""),
                        time: time.replaceAll("\n", ""),
                        date: date_,
                        classrooms: classrooms.replaceAll("\n", "")
                    ));
                  }
                }
              }
            }
          } catch(e/*, s*/) {
            // print("$e\n$s");
          }

        });

      } catch (e, s) {
        print("$e\n$s");
      }
    });

    checkState();

  }

  bool doesExamExist(sub, date, time) {

    for (Exam e in Main.exams) {
      if (e.subject == sub && e.date.toString() == date.toString() && time == e.time) {
        return true;
      }
    }

    return false;

  }

  void checkState() {

    if (Platform.isWindows && WPComputerState.state != 4) {
      Timer(const Duration(milliseconds: 100), checkState);
      return;
    }
    if (!Platform.isWindows && WPPhoneState.state != 4) {
      Timer(const Duration(milliseconds: 100), checkState);
      return;
    }

    if (Platform.isWindows) {
      WPComputerState.state = 5;
    } else {
      WPPhoneState.state = 5;
    }

  }

  AtilimScraperComputer._privateConstructor();

  static late final Scraper instance = AtilimScraperComputer._privateConstructor();

}
