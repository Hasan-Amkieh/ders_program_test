
import 'dart:async';
import 'dart:ffi';
import 'dart:io' show Platform;
import 'dart:isolate';

import 'package:path/path.dart' as p;

import 'package:Atsched/scrapers/scraper.dart';
import 'package:Atsched/wp_computer.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

import '../main.dart';
import '../others/subject.dart';
import '../others/university.dart';
import '../pages/loading_update_page.dart';

class AtilimScraperComputer extends Scraper {

  late Timer timer;
  late String timetableData;

  @override
  void getTimetableData(controller, request) async { // controller and request pars are only for the phone version

    print("Calling Atilim Scraper");

    final webview = await WebviewWindow.create(
      configuration: CreateConfiguration(
        windowHeight: 10,
        windowWidth: 10,
        title: "Timetable Webpage",
        titleBarTopPadding: Platform.isMacOS ? 20 : 0,
        userDataFolderWindows: await _getWebViewPath(),
        titleBarHeight: 0,
      ),
    );
    WPComputerState.state = 2;
    webview
      ..registerJavaScriptMessageHandler("test", (name, body) {
        // debugPrint('on javaScipt message: $name $body');
      })
      ..setApplicationNameForUserAgent(" WebviewExample/1.0.0")
      ..setPromptHandler((prompt, defaultText) {
        if (prompt == "test") {
          return "Hello World!";
        } else if (prompt == "init") {
          return "initial prompt";
        }
        return "";
      })
      ..addScriptToExecuteOnDocumentCreated("""
  const mixinContext = {
    platform: 'Desktop',
    conversation_id: 'conversationId',
    immersive: false,
    app_version: '1.0.0',
    appearance: 'dark',
  }
  window.MixinContext = {
    getContext: function() {
      return JSON.stringify(mixinContext)
    }
  }
""")
      ..addScriptToExecuteOnDocumentCreated("""
var rawOpen = XMLHttpRequest.prototype.open;
XMLHttpRequest.prototype.open = function() {
	if (!this._hooked) {
		this._hooked = true;
		setupHook(this);
	}
	rawOpen.apply(this, arguments);
}
var ret;
function setupHook(xhr) {
	function getter() {
		console.log('get responseText');
		delete xhr.responseText;
		var r;
		if (xhr.responseURL.includes("regularttGetData")) {
			ret = xhr.responseText;
			setup();
			return ret;
		} else {
			r = xhr.responseText;
			setup();
			return r;
		}
	}
	function setter(str) {
		console.log('set responseText: %s', str);
	}
	function setup() {
		Object.defineProperty(xhr, 'responseText', {
			get: getter,
			set: setter,
			configurable: true
		});
	}
	setup();
}
      """)
      ..launch(await University.getFacultyLink(Main.department));

    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      try {

        // print("EXECUTING the CPP code: ");
        final _hideWebView = LoadingUpdateState.nativeApiLib?.lookup<NativeFunction<Void Function()>>('hideWebView');
        Function hideWebView = _hideWebView!.asFunction<void Function()>();
        hideWebView();

      } catch (e) {
        print("An error happened while executing the CPP code: $e");
      }
      try {
        timetableData = await webview.evaluateJavaScript("ret") ?? "";
        timetableData = timetableData.replaceAll('\\"', '"');
        // print("timetable DATA: $timetableData\n\n\n");
        if (timetableData.length > 1000) { // then it is a success and stop the timer
          timer.cancel();
          // print("The timetable has been received!\nSuccess!!!");
          webview.close();
          if (timetableData.isNotEmpty) { // ROOT:
            WPComputerState.state = 3;
            // print("Timetable Retrieved!\nLength of the response: ${timetableData.length}");
            //dataClassification(request.responseText);
            ReceivePort rPort = ReceivePort(); // TODO:
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
                  WPComputerState.doNotRestart = true;
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
                  WPComputerState.state = msg[1] as int;
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
      } catch (e) {
        debugPrint('evaluateJavaScript error: $e\n');
      }
    });

  }

  Future<String> _getWebViewPath() async {
    final document = await getApplicationDocumentsDirectory();
    return p.join(
      document.path,
      'desktop_webview_window',
    );
  }

  AtilimScraperComputer._privateConstructor();

  static late final Scraper instance = AtilimScraperComputer._privateConstructor();

}
