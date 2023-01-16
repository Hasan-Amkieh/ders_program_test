import 'dart:async';
import 'dart:ffi';

// import 'dart:async'; // Deep Links:
import 'dart:io';

import 'package:Atsched/others/university.dart';
import 'package:Atsched/widgets/choice_box.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:Atsched/language/dictionary.dart';
import 'package:Atsched/others/subject.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
// import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_branch_sdk/flutter_branch_sdk.dart'; // Deep Links:
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:lottie/lottie.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restart_app/restart_app.dart';
// import 'package:path_provider/path_provider.dart'; // Deep Links:

import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../others/appthemes.dart';
// import '../widgets/counterbutton.dart';
import '../widgets/emptycontainer.dart';
import 'loading_update_page.dart';

class Home extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }

}

class HomeState extends State<Home> with SingleTickerProviderStateMixin, WidgetsBindingObserver {

  int pageIndex = 0;

  late double width;
  late double height;

  static HomeState? currentState;

  List<CollisionData> collisions = [];

  // Branch IO vars:

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();

  BranchContentMetaData metadata = BranchContentMetaData();
  BranchUniversalObject? buo;
  BranchLinkProperties lp = BranchLinkProperties();

  StreamSubscription<Map>? streamSubscription;
  StreamController<String> controllerData = StreamController<String>();
  StreamController<String> controllerInitSession = StreamController<String>();
  StreamController<String> controllerUrl = StreamController<String>();

  late AnimationController toggleButtonController;

  @override
  void initState() {

    super.initState();

    if (Platform.isWindows) {

      final _changeWindowName = LoadingUpdateState.nativeApiLib?.lookup<NativeFunction<Void Function()>>('changeWindowName');
      Function changeWindowName = _changeWindowName!.asFunction<void Function()>();
      changeWindowName();

    }

    bool isFacInited = true;
    try {
      Main.facultyData.semesterName;
    } catch(err) {
      isFacInited = false;
      print("[ERROR] Faculty Data field has not been intialized, but it should be alrewady initialized!");
    }

    if (isFacInited) {
      try {
        if (Main.facultyData.semesterName == Main.facultyDataOld!.semesterName) { // both semesters have to be the same to compare the courses
          // check the newCourses list with all the courses inside all the schedules:
          for (int i = 0 ; i < Main.schedules.length ; i++) {
            for (int j = 0 ; j < Main.schedules[i].scheduleCourses.length ; j++) {
              for (int k = 0 ; k < Main.newCourses.length ; k++) {
                if (Main.newCourses[k].courseCode == Main.schedules[i].scheduleCourses[j].subject.courseCode) { // if the subjects are the same:
                  if (Main.newCoursesChanges[k][0]) { // if the time has changed:

                    var change = Change(courseCode: Main.schedules[i].scheduleCourses[j].subject.courseCode, typeOfChange: "time",
                        oldData: Main.schedules[i].scheduleCourses[j].subject.days.toString() + " | " + Main.schedules[i].scheduleCourses[j].subject.bgnPeriods.toString() + " | " + Main.schedules[i].scheduleCourses[j].subject.hours.toString(),
                        newData: Main.newCourses[k].days.toString() + " | " + Main.newCourses[k].bgnPeriods.toString() + " | " + Main.newCourses[k].hours.toString(),
                        time: DateTime.now());
                    var r = change.formatData();
                    Main.schedules[i].changes.add(change);

                    InAppNotifications.show(
                        title: '${change.courseCode} time has changed',
                        leading: const Icon(
                          Icons.access_time,
                          color: Colors.green,
                          size: 50,
                        ),
                        ending: const Icon(
                          Icons.arrow_right_alt,
                          color: Colors.blue,
                        ),
                        description:
                        'Changed from ${r[0]} into ${r[1]}',
                        onTap: () {
                          // Do whatever you need!
                        }
                    );

                    Main.schedules[i].scheduleCourses[j].subject.days = Main.newCourses[k].days;
                    Main.schedules[i].scheduleCourses[j].subject.bgnPeriods = Main.newCourses[k].bgnPeriods;
                    Main.schedules[i].scheduleCourses[j].subject.hours = Main.newCourses[k].hours;
                  }
                  if (Main.newCoursesChanges[k][1]) { // if the classrooms have changed:
                    var change = Change(courseCode: Main.schedules[i].scheduleCourses[j].subject.courseCode, typeOfChange: "classroom",
                        oldData: Main.schedules[i].scheduleCourses[j].subject.classrooms.toString(),
                        newData: Main.newCourses[k].classrooms.toString(),
                        time: DateTime.now());
                    Main.schedules[i].changes.add(change);
                    InAppNotifications.show(
                        title: '${change.courseCode} Classroom has changed',
                        ending: const Icon(
                          Icons.arrow_right_alt,
                          color: Colors.red,
                        ),
                        description:
                        'Changed from ${change.oldData} into ${change.newData}',
                        onTap: () {
                          // Do whatever you need!
                        }
                    );
                    Main.schedules[i].scheduleCourses[j].subject.classrooms = Main.newCourses[k].classrooms;
                  }
                }
              }
            }
          }
        }
      } catch(e, stacktrace) {
        print("Error: $e\n$stacktrace");
      }
    }

    Main.forceUpdate = false;

    WidgetsBinding.instance.addObserver(this);

    toggleButtonController = AnimationController(duration: const Duration(seconds: 1), vsync: this);

    currentState = this;

    if (Main.isFacChange && University.areFacsSupported() && University.areDepsSupported()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(context: context, builder: (context) => AlertDialog(
          backgroundColor: Main.appTheme.scaffoldBackgroundColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(translateEng("Choose your Department"), style: TextStyle(color: Main.appTheme.titleTextColor)),
              Container(
                color: Main.appTheme.scaffoldBackgroundColor,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return DropdownButton<String>(
                      underline: Container(),
                      dropdownColor: Main.appTheme.scaffoldBackgroundColor,
                      value: Main.department,
                      items: University.getFacultyDeps(Main.faculty).keys.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem(value: value, child: Row(children: [
                          Text(translateEng(value) + "  ",
                              style: TextStyle(color: Main.appTheme.titleTextColor)),
                          Text(translateEng(University.getFacultyDeps(Main.faculty)[value] as String),
                              style: TextStyle(fontSize: 10, color: Main.appTheme.titleTextColor))
                        ],),);
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          Main.department = newValue!;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Ok", ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ));
      });
      Main.isFacChange = false;
    }

    if (Main.firstTime) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        InAppNotifications.show(
            title: 'Welcome to Atsched!',
            duration: const Duration(seconds: 5),
            leading: Image.asset("lib/icons/atsched.PNG"),
            description:
            translateEng('To watch a demonstrative video about Atsched, click me!'),
            onTap: () async {
              const url = 'https://www.youtube.com/watch?v=LldHI16tvtY';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url));
              } else {
                throw 'Could not launch $url';
              }
            }
        );
      });
    }

    // Deep Links:

    if (!Platform.isWindows) {
      listenDynamicLinks();
      checkScheduleAddition();
    }

    if (isFacInited && Main.facultyData.subjects.isNotEmpty) {
      Main.scheduleClassroomsCounter();
    }

  }

  void checkScheduleAddition() {

    // print("Trying to find extra files: ");
    String content = "";
    try {
      final file = File(Main.appDocDir + (Platform.isWindows ? '\\' : '/') +  'schedule.txt'); // FileSystemException

      content = file.readAsStringSync();
      file.deleteSync();
      if (content.isNotEmpty) {
        // print("Extra Schedule was found with the content of: $content");
        List<String> lines = content.split("\n");
        String scheduleName = lines[0];
        String uni = lines[1];
        String faculty = lines[2];
        lines.removeAt(0); // schedule name
        lines.removeAt(0); // uni
        lines.removeAt(0); // faculty
        confirmScheduleAddtion(scheduleName, lines, uni, faculty);
      }
    } catch(err) {
      print("The file was not opened bcs: $err");
    }

    if (fac.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => showSnackBar());
    }

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    // print("The state of the app has changed!");

    if (HomeState.currentState != null) {
      HomeState.currentState?.setState(() { checkScheduleAddition(); });
    }

    switch (state) {
      case AppLifecycleState.detached:
        // print("The lifecycle has changed into detached");
        Main.save();
        break;
      case AppLifecycleState.inactive:
        // print("The lifecycle has changed into inactive");
        Main.save();

        break;
      case AppLifecycleState.paused:
        // print("The lifecycle has changed into paused");
        Main.save();

        break;
      case AppLifecycleState.resumed:
        // print("The lifecycle has changed into resumed");

        break;
    }

  }

  @override
  void dispose() {

    toggleButtonController.dispose();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();

  }

  static bool isCloseFuncSet = false;

  @override
  Widget build(BuildContext context) {

    double iconSize = const Icon(Icons.info_outline, color: Colors.blue).size ?? ((window.physicalSize / window.devicePixelRatio).width) * 0.025;

    if (Platform.isWindows && !isCloseFuncSet) {
      isCloseFuncSet = true;
      FlutterWindowClose.setWindowShouldCloseHandler(() async {
        return await showDialog(
            context: context,
            builder: (context) {
              if (Main.isUniChange) {
                if (Main.newUni.isNotEmpty) { // then it is a uni change:
                  return AlertDialog(
                      title: const Text('Do you want to change the university?\nThis will delete all your schedules'),
                      actions: [
                        ElevatedButton(
                            onPressed: () {
                              Main.forceUpdate = true;
                              Main.uni = Main.newUni;
                              Main.faculty = University.getFaculties().isNotEmpty ? University.getFaculties()[0] : "";
                              Main.department = University.getFacultyDeps(Main.faculty).keys.isNotEmpty ? University.getFacultyDeps(Main.faculty).keys.elementAt(0) : "";
                              Main.isFacChange = true;
                              Main.deleteSchedules();
                              Main.writeSettings();
                              Navigator.of(context).pop(true);
                            },
                            child: const Text('Yes')),
                        ElevatedButton(
                            onPressed: () { Main.newUni = ""; Navigator.of(context).pop(false); },
                            child: const Text('No')),
                      ]
                  );
                }
              } else { // then it is a faculty change:
                if (Main.newFaculty.isNotEmpty) { // then it is a faculty change
                  return AlertDialog(
                      title: const Text('Do you want to change the faculty?\nNext time you open Atsched the faculty will change'),
                      actions: [
                        ElevatedButton(
                            onPressed: () async {
                              Main.forceUpdate = true;
                              Main.faculty = Main.newFaculty;
                              Main.department = University.getFacultyDeps(Main.faculty).keys.elementAt(0);
                              Main.isFacChange = true;
                              Main.writeSettings();
                              Main.writeFavCourses();
                              await Main.writeSchedules(); // Note: This should be called the last
                              Navigator.of(context).pop(true);
                            },
                            child: const Text('Yes')),
                        ElevatedButton(
                            onPressed: () { Main.newFaculty = ""; Navigator.of(context).pop(false); },
                            child: const Text('No')),
                      ]
                  );
                }
                else {
                  return AlertDialog(
                      title: Text('Do you really want to quit?' + (Main.forceUpdate ? "\nNext time you open Atsched the update will start" : "")),
                      actions: [
                        ElevatedButton(
                            onPressed: () {
                              Main.save();
                              Navigator.of(context).pop(true);
                            },
                            child: const Text('Yes')),
                        ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('No')),
                      ]
                  );
                }
              }

              return AlertDialog(
                  title: Text('Do you really want to quit?' + (Main.forceUpdate ? "\nNext time you open Atsched the update will start" : "")),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          Main.save();
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Yes')),
                    ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('No')),
                  ]
              );
            });
      });
    }

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Main.appTheme.headerBackgroundColor,
      systemNavigationBarColor: Main.appTheme.navigationBarColor,
    ));

    width = (window.physicalSize / window.devicePixelRatio).width;
    height = (window.physicalSize / window.devicePixelRatio).height;

    var isPortrait = MediaQuery
        .of(context)
        .orientation == Orientation.portrait;

    Widget? schedulePage;
    if (pageIndex == 0) {
      schedulePage = buildSchedulePage();
    }

    bool isInited = true;

    try {
      Main.facultyData.semesterName;
    } catch(e) {
      isInited = false;
    }

    Widget? servicesPage;
    if (pageIndex == 1) {

      List<Widget> icons = [
        const Icon(Icons.edit, color: Colors.white),
        const Icon(Icons.search, color: Colors.white),
        const Icon(Icons.play_lesson, color: Colors.white),
        const Icon(CupertinoIcons.calendar_badge_plus, color: Colors.white),
        const Icon(Icons.star, color: Colors.white),
        const Icon(CupertinoIcons.calendar_today, color: Colors.white),
      ];

      List<Text> topics = [
        Text(translateEng('Edit Courses'), style: const TextStyle(color: Colors.white)),
        Text(translateEng('Courses Search'), style: const TextStyle(color: Colors.white)),
        Text(translateEng('Empty Classrooms'), style: const TextStyle(color: Colors.white)),
        Text(translateEng('Scheduler'), style: const TextStyle(color: Colors.white)),
        Text(translateEng('Favourite Courses'), style: const TextStyle(color: Colors.white)),
        Text(translateEng('Saved Schedules'), style: const TextStyle(color: Colors.white)),
      ];

      List<Widget> descrips = [
        Text(translateEng('Add and edit the courses on the current schedule'), style: TextStyle(color: Main.appTheme.subtitleTextColor)),
        Text(translateEng('Search for courses using its name, classroom number, teacher or department'), style: TextStyle(color: Main.appTheme.subtitleTextColor)),
        Text(translateEng('Find empty classrooms inside the university'), style: TextStyle(color: Main.appTheme.subtitleTextColor)),
        Text(translateEng('Choose the courses with the sections you prefer, then choose your appropriate schedule'), style: TextStyle(color: Main.appTheme.subtitleTextColor)),
        EmptyContainer(),
        Text(translateEng('You can save schedules and set them back again'), style: TextStyle(color: Main.appTheme.subtitleTextColor)),
      ];

      List<int> counts = [
        Main.schedules[Main.currentScheduleIndex].scheduleCourses.length,
        Main.facultyData.subjects.length,
        Main.classroomsCountForCurHr,
        -1, // -1 means there is no count on the scheduler
        Main.favCourses.length,
        Main.schedules.length,
      ];

      List<Null Function()> onTaps = [
            () {
          Navigator.pushNamed(context, "/home/editcourses").then((value) { // bcs the count numbers might have changed, thus refresh
            setState(() {});
          });
        },
            () {
          if (Main.isFacDataFilled) {
            Navigator.pushNamed(context, "/home/searchcourses").then((value) {
              setState(() {});
            });
          } else {
            showToast(
              translateEng("The courses could not be loaded!"),
              duration: const Duration(milliseconds: 1500),
              position: ToastPosition.bottom,
              backgroundColor: Colors.blue.withOpacity(0.8),
              radius: 100.0,
              textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
            );
          }
        },
            () {
          if (Main.isFacDataFilled) {
            Navigator.pushNamed(context, "/home/emptyclassrooms").then((value) {
              setState(() {});
            });
          } else {
            showToast(
              translateEng("The courses could not be loaded!"),
              duration: const Duration(milliseconds: 1500),
              position: ToastPosition.bottom,
              backgroundColor: Colors.blue.withOpacity(0.8),
              radius: 100.0,
              textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
            );
          }
        },
        () {
          if (Main.isFacDataFilled) {
            Navigator.pushNamed(context, "/home/scheduler").then((value) {
              setState(() {});
            });
          } else {
            showToast(
              translateEng("The courses could not be loaded!"),
              duration: const Duration(milliseconds: 1500),
              position: ToastPosition.bottom,
              backgroundColor: Colors.blue.withOpacity(0.8),
              radius: 100.0,
              textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
            );
          }
        },
        () {
          Navigator.pushNamed(context, "/home/favcourses").then((value) {
            setState(() {});
          });
        },
            () {
          Navigator.pushNamed(context, "/home/savedschedules").then((value) {
            setState(() {});
          });
        },
      ];

      if (University.areExamsSupported()) {
        icons.add(SvgPicture.asset("lib/icons/exam_icon.svg", height: iconSize * 0.85, color: Colors.white));
        topics.add(Text(translateEng('Upcoming Exams'), style: TextStyle(color: Colors.white)));
        descrips.add(Text(translateEng('Find all the exams of your schedule'), style: TextStyle(color: Main.appTheme.subtitleTextColor)));
        counts.add(Main.exams.length);
        onTaps.add(() {
          Navigator.pushNamed(context, "/home/examspage").then((value) {
            setState(() {});
          });
        });
      }

      List<Widget> children = [];
      List<Widget> widgets_ = [];

      for (int i = 0 ; i < icons.length ;) { // each row has 4/2 widgets
        widgets_ = [];
        for (int j = 0 ; j < (Platform.isWindows ? 4 : 2) ; j++, i++) { // take 4/2 widgets and fill them into the row
          if (i >= icons.length) {
            while (widgets_.length < 4) { // Empty Choice Box to fill in the empty spaces
              widgets_.add(ChoiceBox(icon: icons[icons.length-1], mainText: topics[icons.length-1],
                  description: descrips[icons.length-1], number: counts[icons.length-1], onTap: onTaps[icons.length-1], isVisible: false));
            }
            break;
          }
          widgets_.add(ChoiceBox(icon: icons[i], mainText: topics[i], description: descrips[i], number: counts[i], onTap: onTaps[i], isVisible: true));
        }
        children.add(Row(children: widgets_, mainAxisAlignment: MainAxisAlignment.spaceBetween));
        children.add(SizedBox(height: height * 0.03,));
      }

      servicesPage = Container(
          padding: EdgeInsets.symmetric(horizontal: 0.02 * width, vertical: 0.05 * width),
          child: SingleChildScrollView(
            child: Column(
              children: children,
            ),
          )
      );
    }

    Widget? settingsPage;
    if (pageIndex == 2) {
      String hours = "", day = "", hr, mins;
      int days;

      if (Main.isFacDataFilled) {
        // print("Faculty Data is FILLED!");
        hr = (Main.facultyData.lastUpdate.hour < 10 ? "0" : "") + Main.facultyData.lastUpdate.hour.toString();
        mins = (Main.facultyData.lastUpdate.minute < 10 ? "0" : "") + Main.facultyData.lastUpdate.minute.toString();
        hours = hr + ":" + mins;
        days = Main.facultyData.lastUpdate.difference(DateTime.now()).inDays;

        if (days == 0) {
          day = "Today";
        } else if (days == 1) {
          day = "Yesterday";
        } else { // basically taking the absolute of the number:
          day = "${days < 0 ? (days * -1) : days} days ago";
        }
      }

      var themeWidget = Lottie.asset(
        "lib/icons/theme_mode_toggle_button.json",
        animate: false,
        repeat: false,
        onLoaded: (_) {
          setState(() {
            if (Main.theme == ThemeMode.dark) {
              toggleButtonController.animateTo(0.5, duration: const Duration(seconds: 1));
            }
          });
        },
        controller: toggleButtonController,
        width: IconTheme.of(context).size! * 3.5,
        height: IconTheme.of(context).size! * 3.5,
      );

      settingsPage = ListView(
        padding: EdgeInsets.all(width * 0.02),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(translateEng("Language"), style: TextStyle(color: Main.appTheme.titleTextColor)),
              DropdownButton<String>(
                underline: Container(),
                dropdownColor: Main.appTheme.scaffoldBackgroundColor,
                value: Main.language,
                items: langs.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem(
                      value: value,
                      child: TextButton.icon(onPressed: null, icon: Image.asset("lib/icons/" + value + ".png"),
                          label: Text(translateEng(value), style: TextStyle(color: Main.appTheme.titleTextColor))
                      ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    Main.language = newValue!;
                  });
                },
              )
            ],
          ),
          SizedBox(
            height: height * 0.02,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(translateEng("University"), style: TextStyle(color: Main.appTheme.titleTextColor)),
              DropdownButton<String>(
                underline: Container(),
                dropdownColor: Main.appTheme.scaffoldBackgroundColor,
                value: Main.uni,
                items: Main.unis.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem(
                    value: value, // Image.asset("lib/icons/atacs.png", width: IconTheme.of(context).size!, height: IconTheme.of(context).size!)
                    child: TextButton.icon(onPressed: null, icon: Image.asset("lib/icons/" + value.toLowerCase() + ".png"),
                        label: Text(translateEng(value), style: TextStyle(color: Main.appTheme.titleTextColor))
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue == Main.uni) {
                    return;
                  }
                  setState(() {
                    if (Platform.isWindows) {
                      Main.newUni = newValue!;
                      Main.isUniChange = true;
                      FlutterWindowClose.closeWindow();
                    } else {
                      showDialog(context: context, builder: (context) {
                        return AlertDialog(
                          backgroundColor: Main.appTheme.scaffoldBackgroundColor,
                          title: Text(translateEng("Do you want to change the university?\n\nThis will delete all your schedules"),
                          style: TextStyle(color: Main.appTheme.titleTextColor)
                          ),
                          actions: [
                            TextButton(onPressed: () {
                              Main.forceUpdate = true;
                              Main.faculty = University.getFaculties().isNotEmpty ? University.getFaculties()[0] : "";
                              Main.department = University.getFacultyDeps(Main.faculty).keys.isNotEmpty ? University.getFacultyDeps(Main.faculty).keys.elementAt(0) : "";
                              Main.isFacChange = true;
                              Main.uni = newValue!;
                              Main.isUniChange = true;

                              Main.deleteSchedules();

                              Main.writeSettings();
                              Restart.restartApp().then((value) { ; });
                            },
                              child: Text(translateEng("RESTART")),
                            ),
                            TextButton(onPressed: () {
                              Navigator.pop(context);
                            },
                              child: Text(translateEng("CANCEL")),
                            )
                          ],
                        );
                      });
                    }
                  });
                },
              )
            ],
          ),
          University.areFacsSupported() ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(translateEng("Faculty"), style: TextStyle(color: Main.appTheme.titleTextColor)),
              DropdownButton<String>(
                underline: Container(),
                dropdownColor: Main.appTheme.scaffoldBackgroundColor,
                value: Main.faculty,
                items: University.getFaculties().map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem(value: value, child: Text(translateEng(value), style: TextStyle(color: Main.appTheme.titleTextColor)));
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue == Main.faculty) {
                    return;
                  }
                  setState(() {
                    if (Platform.isWindows) {
                      Main.newFaculty = newValue!;
                      Main.isUniChange = false;
                      FlutterWindowClose.closeWindow();
                    } else {
                      showDialog(context: context, builder: (context) {
                        return AlertDialog(
                          backgroundColor: Main.appTheme.scaffoldBackgroundColor,
                          title: Text(translateEng("Restarting the application"), style: TextStyle(color: Main.appTheme.titleTextColor)),
                          actions: [
                            TextButton(onPressed: () async {
                              Main.forceUpdate = true;
                              Main.faculty = newValue!;
                              Main.department = University.getFacultyDeps(Main.faculty).keys.elementAt(0);
                              Main.isFacChange = true;
                              Main.writeSettings();
                              Main.writeFavCourses();
                              await Main.writeSchedules(); // Note: This should be called the last
                              Restart.restartApp().then((value) { ; });
                            },
                              child: Text(translateEng("RESTART")),
                            ),
                            TextButton(onPressed: () {
                              Navigator.pop(context);
                            },
                              child: Text(translateEng("CANCEL")),
                            )
                          ],
                        );
                      });
                    }
                  });
                },
              )
            ],
          ) : EmptyContainer(),
          University.areDepsSupported() ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(translateEng("Department"), style: TextStyle(color: Main.appTheme.titleTextColor)),
              DropdownButton<String>(
                underline: Container(),
                dropdownColor: Main.appTheme.scaffoldBackgroundColor,
                value: Main.department,
                items: University.getFacultyDeps(Main.faculty).keys.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem(value: value, child: Row(children: [
                    Text(translateEng(value) + "  ", style: TextStyle(color: Main.appTheme.titleTextColor)),
                    Text(translateEng(University.getFacultyDeps(Main.faculty)[value]!),
                        style: TextStyle(fontSize: 10, color: Main.appTheme.titleTextColor))
                  ],),);
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    Main.department = newValue!;
                  });
                },
              )
            ],
          ) : EmptyContainer(),
          SizedBox(
            height: height * 0.02,
          ),
          isInited ? (Main.facultyData.semesterName.isEmpty ? Container() : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                translateEng("Current Semester")  + ": ",
                style: TextStyle(color: Main.appTheme.titleTextColor),
              ),
              Expanded(
                child: Text(
                  Main.facultyData.semesterName,
                  textAlign: TextAlign.end,
                  style: TextStyle(color: Main.appTheme.titleTextColor),
                ),
              ),
            ],
          )) : Container(),
          SizedBox(
            height: height * 0.02,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Main.isFacDataFilled ? (translateEng("Last Updated") + "    ${day} at ${hours}") : translateEng("Unknown"),
                style: TextStyle(color: Colors.red.shade500, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                icon: const Icon(Icons.update),
                  onPressed: () {
                setState(() {
                  Main.forceUpdate = true;
                  if (Platform.isWindows) {
                    Main.save();
                    FlutterWindowClose.closeWindow();
                  } else {
                    Main.restart();
                  }
                });
              }, label: Text(translateEng("Update now"))),
            ],
          ),
          SizedBox(
            height: height * 0.02,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(translateEng("Update Timeout (days)"), style: TextStyle(color: Main.appTheme.titleTextColor))),
              Row(
                children: [
                  Slider(
                    value: Main.days,
                    onChanged: (newValue) {
                      setState(() {
                        // print("New value: " + newValue.toString());
                        Main.days = newValue;
                        Main.hourUpdate = (Main.days * 24.0).toInt();
                      });
                    },
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: "${(Main.days.toInt())} days",
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(translateEng("Theme"), style: TextStyle(color: Main.appTheme.titleTextColor)),
              TextButton(
                  child: themeWidget,
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  onPressed: () {
                    setState(() {
                      toggleButtonController.animateTo(Main.theme == ThemeMode.light ? 0.5 : 1.0, duration: const Duration(seconds: 1));
                      if (Main.theme == ThemeMode.dark) {
                        Main.theme = ThemeMode.light;
                      } else {
                        Main.theme = ThemeMode.dark;
                      }
                      Main.appTheme = AppTheme(); // reset the styles depending on the new theme
                    });
                  }
              ),
            ],
          ),
          Row(
            children: [
              Text(
                translateEng("Current Version") + ": " + (Platform.isWindows ? Main.atschedVersionForWindows : Main.packageInfo.version),
                style: TextStyle(color: Main.appTheme.titleTextColor, fontSize: 14),
              ),
            ],
          ),
        ],
      );
    }

    List<Widget> widgetsList = University.getLinksPageWidgets(width, IconTheme.of(context).size!);
    widgetsList.addAll([
      ListTile(
        title: Text(translateEng('Source Code of the application'), style: TextStyle(color: Main.appTheme.titleTextColor)),
        subtitle: Text(translateEng("You can read and make changes of the app's source code"), style: TextStyle(color: Main.appTheme.subtitleTextColor)),
        leading: Icon(Icons.code, color: Main.appTheme.titleIconColor),
        onTap: () async {
          const url = 'https://github.com/Hasan-Amkieh/ders_program_test'; // %0A new line / %20 white space
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url));
          } else {
            throw 'Could not launch $url';
          }
        },
      ),
      ListTile(
        title: Text(translateEng('Send a Message'), style: TextStyle(color: Main.appTheme.titleTextColor)),
        leading: Icon(CupertinoIcons.mail_solid, color: Main.appTheme.titleIconColor),
        subtitle: Text(translateEng("Complains and Suggestions"), style: TextStyle(color: Main.appTheme.subtitleTextColor)),
        onTap: () async {
          const url = 'mailto:hassan1551@outlook.com?subject=Atsched&body=%0A%0A%0ARegards,'; // %0A new line / %20 white space
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url));
          } else {
            throw 'Could not launch $url';
          }
        },
      ),
      ListTile(
        title: Text(translateEng('About the Creator'), style: TextStyle(color: Main.appTheme.titleTextColor)),
        leading: Icon(Icons.person, color: Main.appTheme.titleIconColor),
        onTap: () {
          Navigator.pushNamed(context, "/home/personalinfo");
        },
      ),
      ListTile(
        title: Text(translateEng('Donate'), style: TextStyle(color: Main.appTheme.titleTextColor)),
        subtitle: Text(
            translateEng("Iphone version requires 100\$ every year, if enough was collected then both MACOS and Iphone versions will be supported"),
            style: TextStyle(color: Main.appTheme.subtitleTextColor)),
        leading: Icon(Icons.attach_money_rounded, color: Main.appTheme.titleIconColor),
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                    title: Column(
                      children: [
                        const Text('If you live in Turkey İŞ Bank is preferable\n'),
                        TextButton.icon(
                          label: const Text("TR27 0006 4000 0014 2381 0343 20", style: TextStyle(fontWeight: FontWeight.bold)),
                          icon: Image.asset("lib/icons/isbank.jpg", width: IconTheme.of(context).size!, height: IconTheme.of(context).size!),
                          onPressed: () { // Copy to clipboard and give him a message that it was copied
                            Clipboard.setData(const ClipboardData(text: "TR27 0006 4000 0014 2381 0343 20")).then((value) {
                              showToast(
                                translateEng("The IBAN is copied"),
                                duration: const Duration(milliseconds: 1500),
                                position: ToastPosition.bottom,
                                backgroundColor: Colors.blue.withOpacity(0.8),
                                radius: 100.0,
                                textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
                              );
                            });
                          },
                        ),
                        TextButton.icon(
                          label: const Text("Buy me a coffee", style: TextStyle(fontWeight: FontWeight.bold)),
                          icon: const Icon(Icons.coffee, color: Colors.black),
                          onPressed: () async {
                            const url = 'https://www.buymeacoffee.com/hasanamkieh';
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url));
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                        ),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('OK'),
                      ),
                    ]
                );
              });
        },
      ),
      // Container(
      //   padding: EdgeInsets.fromLTRB(0 * width, 0, 0, 0),
      //   child: ListTile(
      //     leading: Icon(Icons.calculate, color: Main.appTheme.titleTextColor),
      //     title: Text(translateEng("GPA Calculator"), style: TextStyle(color: Main.appTheme.titleTextColor)),
      //     onTap: () async {
      //       const url = 'https://metugpa.com';
      //       if (await canLaunchUrl(Uri.parse(url))) {
      //         await launchUrl(Uri.parse(url));
      //       } else {
      //         throw 'Could not launch $url';
      //       }
      //     },
      //   ),
      // ),

      // Container(
      //   padding: EdgeInsets.fromLTRB(0.05 * width, 0.03 * width, 0, 0),
      //   child: const Text(
      //     "Announcements",
      //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
      //   ),
      // ),
      // Divider(
      //   height: 2.0,
      //   thickness: 2.0,
      //   indent: 0.03 * width,
      //   endIndent: 0.03 * width,
      //   color: Colors.blueGrey.withOpacity(0.8),
      // ),
      // TODO: Use this link to list all the latest announcements, only list the last 6, show thw title of the announcement, date and part of its article, like first 10 words:
      // https://www.atilim.edu.tr/en/home/announcement/list
    ]);

    Widget? linksPage;
    if (pageIndex == 3) {
      linksPage = ListView(
        children: widgetsList,
      );
    }

    Widget errorPage = Container(
      child: const Center(
        child: Text("An error has occured while trying to load the page", style: TextStyle(color: Colors.red, fontSize: 22)),
      ),
    );

    List<Widget> pages = [
      schedulePage ?? errorPage,
      servicesPage ?? errorPage,
      settingsPage ?? errorPage,
      linksPage ?? errorPage,
    ];

    return Scaffold(
      backgroundColor: Main.appTheme.scaffoldBackgroundColor,
      body: SafeArea(
          child: pages[pageIndex]
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
            indicatorColor: Main.appTheme.navigationBarColor,
            labelTextStyle: MaterialStateProperty.all(TextStyle(color: Main.appTheme.navIconColor)),
        ),
        child: NavigationBar(
          backgroundColor: Main.appTheme.navigationBarColor,
          animationDuration: const Duration(seconds: 1),
          height: Platform.isWindows ? (height * 0.08) : (isPortrait ? height * 0.08 : width * 0.08),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          selectedIndex: pageIndex,
          onDestinationSelected: (int newIndex) {
            setState(() {
              pageIndex = newIndex;
            });
          },
          destinations: [
            NavigationDestination(icon: Icon(CupertinoIcons.calendar_today, color: Main.appTheme.navIconColor), selectedIcon: Icon(CupertinoIcons.calendar_circle_fill, color: Main.appTheme.navIconColor), label: translateEng('Schedule')),
            NavigationDestination(icon: Icon(Icons.hardware_outlined, color: Main.appTheme.navIconColor), selectedIcon: Icon(Icons.hardware, color: Main.appTheme.navIconColor), label: translateEng('Tools')),
            NavigationDestination(icon: Icon(Icons.settings_outlined, color: Main.appTheme.navIconColor), selectedIcon: Icon(Icons.settings, color: Main.appTheme.navIconColor), label: translateEng('Settings')),
            NavigationDestination(icon: Icon(CupertinoIcons.link_circle, color: Main.appTheme.navIconColor), selectedIcon: Icon(CupertinoIcons.link_circle_fill, color: Main.appTheme.navIconColor), label: translateEng('Links')),
          ],
        ),
      ),
    );
  }

  Container? showCourseInfo(Course course) {

    Subject subject = course.subject;

    String name = subject.customName;

    String classrooms = "", teachers = "", departments = "";

    List<List<String>> classroomsList = subject.classrooms;

    classrooms = classroomsList.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");
    departments = subject.departments.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");
    if (subject.getTranslatedTeachers().isEmpty) {
      teachers = subject.teacherCodes.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");
    } else {
      teachers = subject.getTranslatedTeachers();
    }

    List<String> list = classrooms.split(",").toList();
    list = deleteRepitions(list);
    classrooms = list.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");

    list = teachers.split(",").toList();
    list = deleteRepitions(list);
    teachers = list.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");

    classrooms.trim();
    teachers.trim();
    departments.trim();

    showAdaptiveActionSheet(
      bottomSheetColor: Main.appTheme.scaffoldBackgroundColor,
      context: context,
      title: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Center(child: Text(name, style: TextStyle(color: Main.appTheme.titleTextColor, fontSize: 16, fontWeight: FontWeight.bold))),
            ),
            ]
          ),
          SizedBox(
            height: height * 0.03,
          ),
          SizedBox(
            height: classrooms.isNotEmpty ? height * 0.03 : 0,
          ),
          Visibility(
            visible: classrooms.isNotEmpty,
            child: Row(children: [
              classrooms.isNotEmpty ? Icon(CupertinoIcons.placemark_fill, color: Main.appTheme.titleTextColor) : Container(width: 0),
              Expanded(child: Container(padding: EdgeInsets.fromLTRB(width * 0.05, 0, 0, 0), child: Text(classrooms, style: TextStyle(color: Main.appTheme.titleTextColor)))),
              ]
            ),
          ),
          SizedBox(
            height: teachers.isNotEmpty ? height * 0.03 : 0,
          ),
          Visibility(
            visible: teachers.isNotEmpty,
            child: Row(
                children: [
                  teachers.isNotEmpty ? Icon(CupertinoIcons.group_solid, color: Main.appTheme.titleTextColor) : Container(),
                  Expanded(child: Container(padding: EdgeInsets.fromLTRB(width * 0.05, 0, 0, 0), child: Text(teachers, style: TextStyle(color: Main.appTheme.titleTextColor)))),
                ]
            ),
          ),
          SizedBox(
            height: departments.isNotEmpty ? height * 0.03 : 0,
          ),
          Visibility(
            visible: departments.isNotEmpty,
            child: Row(
                children: [
                  departments.isNotEmpty ? Icon(CupertinoIcons.building_2_fill, color: Main.appTheme.titleTextColor) : Container(),
                  Expanded(child: Container(padding: EdgeInsets.fromLTRB(width * 0.05, 0, 0, 0), child: Text(departments, style: TextStyle(color: Main.appTheme.titleTextColor)))),
                ]
            ),
          ),
          SizedBox(
            height: departments.isNotEmpty ? height * 0.03 : 0,
          ),
          Visibility(
            visible: departments.isNotEmpty,
            child: Row(
                children: [
                  course.note.isNotEmpty ? Icon(CupertinoIcons.text_aligncenter, color: Main.appTheme.titleTextColor) : Container(),
                  Expanded(child: Container(padding: EdgeInsets.fromLTRB(width * 0.05, 0, 0, 0), child: Text(course.note, style: TextStyle(color: Main.appTheme.titleTextColor)))),
                ]
            ),
          ),
        ],
      ),
      actions: [],
      cancelAction: CancelAction(title: const Text('Close')),
    );

    return null;

  }

  String courseBeingHovered = "";
  bool isHovered = false; // only for Computer Versions

  Widget buildSchedulePage() {

    bool isSatNeeded = false, isSunNeeded = false;

    for (int subIndex = 0 ; subIndex < Main.schedules[Main.currentScheduleIndex].scheduleCourses.length ; subIndex++) {

      for (int x = 0 ; x < Main.schedules[Main.currentScheduleIndex].scheduleCourses[subIndex].subject.days.length ; x++) {
        for (int y = 0 ; y < Main.schedules[Main.currentScheduleIndex].scheduleCourses[subIndex].subject.days[x].length ; y++) {
          if (!isSatNeeded || !isSunNeeded) {
            if (Main.schedules[Main.currentScheduleIndex].scheduleCourses[subIndex].subject.days[x][y] == 6) {
              isSatNeeded = true;
            }
            if (Main.schedules[Main.currentScheduleIndex].scheduleCourses[subIndex].subject.days[x][y] == 7) {
              isSunNeeded = true;
            }
          } else {
            break;
          }
        }
        if (isSatNeeded && isSunNeeded) {
          break;
        }
      }
      if (isSatNeeded && isSunNeeded) {
        break;
      }
    }

    int bgnHour = 9, endHour = 16;

    List<int> neededHours = []; // 15 and 16 were deleted, now it depends on the courses we have

    Main.schedules[Main.currentScheduleIndex].scheduleCourses.forEach((crs) {

      for (int i = 0 ; i < crs.subject.days.length ; i++) {

        for (int j = 0 ; j < crs.subject.days[i].length ; j++) {

          if (bgnHour > crs.subject.bgnPeriods[i][j]) { // first convert the hours
            bgnHour = crs.subject.bgnPeriods[i][j];
          }

          if (endHour < (crs.subject.bgnPeriods[i][j] + crs.subject.hours[i])) {
            print("The end hour has been changed into ${crs.subject.bgnPeriods[i][j] + crs.subject.hours[i]}");
            endHour = crs.subject.bgnPeriods[i][j] + crs.subject.hours[i];
          }

        }

      }

    });

    for (int i = bgnHour ; i <= endHour ; i++) { // equivalent to bgnHour:1:endHour in MATLAB
      neededHours.add(i);
    }

    double colWidth = (width) / ( 6 + (isSatNeeded ? 1 : 0) + (isSunNeeded ? 1 : 0) ); // 5 days and a col for the clock
    double rowHeight = (height * 1) / (neededHours.length + 1); // some for the clock and one for the empty box // 91 percent because of the horizontal borders

    Color emptyCellColor = Main.appTheme.emptyCellColor;
    Color horizontalBorderColor = Colors.black38; // bgnHours seperator
    Container emptyCell = Container(decoration: BoxDecoration(
        color: emptyCellColor,
        border: Border.symmetric(
            horizontal: BorderSide(color: horizontalBorderColor, width: 1)
        )),
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        child: SizedBox(width: colWidth, height: rowHeight,)
    );

    List<Widget> hoursWidgets = [];

    hoursWidgets.add(SizedBox(width: colWidth, height: rowHeight));
    int cnt = 0;
    neededHours.forEach((hr) {
      hoursWidgets.add(Container(
          padding: EdgeInsets.fromLTRB(0, cnt * 1 /*1 is the width of the line seperator*/, 0, 0),
          // margin: EdgeInsets.zero,
          color: Main.appTheme.headerBackgroundColor,
          child: Center(child: Text(hr.toString() + ':' + University.getBgnMinutes().toString(), textAlign: TextAlign.center, style: Main.appTheme.headerSchedulePageTextStyle)),
          height: rowHeight
      ));
      cnt++;
    });

    List<Widget> colsList = [
      Container(
        color: Main.appTheme.headerBackgroundColor, // Main.appTheme.headerBackgroundColor.withGreen(50)
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: hoursWidgets,
        ),
        height: rowHeight * (1 + neededHours.length),
      ),
      Container(
        color: Main.appTheme.headerBackgroundColor,
        child: Column( // Headers
          children: prepareDay("Mon", rowHeight, colWidth, neededHours.length, emptyCell),
        ),
      ),
      Container(
        color: Main.appTheme.headerBackgroundColor,
        child: Column( // Headers
          children: prepareDay("Tue", rowHeight, colWidth, neededHours.length, emptyCell),
        ),
      ),
      Container(
        color: Main.appTheme.headerBackgroundColor,
        child: Column( // Headers
          children: prepareDay("Wed", rowHeight, colWidth, neededHours.length, emptyCell),
        ),
      ),
      Container(
        color: Main.appTheme.headerBackgroundColor,
        child: Column( // Headers
          children: prepareDay("Thur", rowHeight, colWidth, neededHours.length, emptyCell),
        ),
      ),
      Container(
        color: Main.appTheme.headerBackgroundColor,
        child: Column( // Headers
          children: prepareDay("Fri", rowHeight, colWidth, neededHours.length, emptyCell),
        ),
      ),
      isSatNeeded ? (
          Container(
            color: Main.appTheme.headerBackgroundColor,
            child: Column( // Headers
              children: prepareDay("Sat", rowHeight, colWidth, neededHours.length, emptyCell),
            ),
          )
      ) : Container(),
      isSunNeeded ? (
          Container(
            color: Main.appTheme.headerBackgroundColor,
            child: Column( // Headers
              children: prepareDay("Sun", rowHeight, colWidth, neededHours.length, emptyCell),
            ),
          )
      ) : Container(),
    ];

    List<Widget> coursesList = [
      Row(
        children: colsList,
      ),
    ];

    // Main.schedules[Main.currentScheduleIndex].scheduleCourses.forEach((element) {print(element.subject.toString());});
    // First find all the collisions:
    collisions = findCourseCollisions();
    // print("All the collisions are: ");
    //collisions.forEach((col) { print("\nCOLLISION:"); col.subjects.forEach((element) {print(element.classCode);}); });

    int colorIndex = -1;

    Main.schedules[Main.currentScheduleIndex].scheduleCourses.forEach((course) {
      colorIndex++;
      int classroomCount = 0;
      for (int i = 0; i < course.subject.days.length; i++) {
        for (int j = 0; j < course.subject.days[i].length; j++) {
          bool isCol = false, isColOf3 = false;
          int atIndex = 0, drawingIndex = 0, colSize = 1; // colSize determines how many subjects are actually in this collision
          int colIndex = 0;
          collisions.forEach((col) {
            atIndex = 0;
            Subject sub;
            for( ; atIndex < col.subjects.length ; atIndex++ ) {
              sub = col.subjects[atIndex];
              //print("${sub.classCode} N ${course.subject.classCode}");
              if (sub.isEqual(course.subject) && course.subject.days[i][j] == col.subjectsData[atIndex].day &&
                  course.subject.bgnPeriods[i][j] == col.subjectsData[atIndex].bgnPeriod && !col.isDrawn[atIndex]) {
                // print("Drawing the collisioned course: ${course.subject.classCode}");
                collisions[colIndex].isDrawn[atIndex] = true;
                isCol = true;
                isColOf3 = collisions[colIndex].subjects.length >= 3;
                drawingIndex = atIndex;
                colSize = col.subjects.length;
                continue;
              } else {
                // print("NOT Drawing the collisioned course bcs the period is different: ${course.subject.classCode}");
              }
              if (isCol) {
                continue;
              }
            }
            colIndex++;
            if (isCol) {
              return;
            }
          });
          //print("index of ${course.subject.classCode} is $drawingIndex N $colSize");

          //print("classrooms: ${course.subject.classrooms}");

          String classroomStr = (classroomCount) < course.subject.classrooms.length ? deleteRepitions(course.subject.classrooms[classroomCount]).toString().replaceAll(RegExp("[\\[.*?\\]]"), "") : "";
          if (classroomStr.isEmpty) {
            for (int j_ = 0 ; j_ < course.subject.classrooms.length ; j_++) {
              if (classroomStr.isNotEmpty && course.subject.classrooms[j_].isNotEmpty && deleteRepitions(course.subject.classrooms[j_]).toString().replaceAll(RegExp("[\\[.*?\\]]"), "") != classroomStr) {
                classroomStr = "";
                break;
              }
              if (course.subject.classrooms[j_].isNotEmpty) {
                classroomStr = deleteRepitions(course.subject.classrooms[j_]).toString().replaceAll(RegExp("[\\[.*?\\]]"), "");
              }
            }
          } else {
            classroomCount++;
          }
          //print("Of period $i of subject ${course.subject.classCode} has classrooms $classroomStr");

          coursesList.add(
            Positioned(
              child: TextButton(
                //clipBehavior: Clip.none,
                onPressed: () => showCourseInfo(course),
                child: RotatedBox(
                  quarterTurns: isCol ? 1 : 0,
                  child: RichText(
                    text: TextSpan(
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyText2,
                        children: [
                          TextSpan(
                            text: course.subject.courseCode,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.0),
                          ),
                          TextSpan(
                            text: (isCol ? "  " : "\n") + classroomStr,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.0
                            ),
                          ),
                        ]
                    ),
                  ),
                ),
                onHover: (isHovering) {
                  setState(() {
                    isHovered = isHovering;
                    courseBeingHovered = course.subject.courseCode;
                  });
                },
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                      isColOf3 ? EdgeInsets.symmetric(vertical: 0.01 * width, horizontal: 0.005 * width) : EdgeInsets.all(0.01 * width)
                  ),
                  backgroundColor: MaterialStateProperty.all(
                      ((isHovered && course.subject.courseCode == courseBeingHovered)) ?
                      AppTheme.getColor(colorIndex)
                          .withBlue(AppTheme.getColor(colorIndex).blue + 15)
                          .withGreen(AppTheme.getColor(colorIndex).green + 15)
                          .withRed(AppTheme.getColor(colorIndex).red + 15)
                          :
                      AppTheme.getColor(colorIndex),
                  ),
                  shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero)),
                  overlayColor: MaterialStateProperty.all(
                      const Color.fromRGBO(255, 255, 255, 0.2)
                  ),
                )),
              width: isCol ? colWidth / colSize : colWidth,
              height: rowHeight * course.subject.hours[i],
              left: colWidth * (course.subject.days[i][j] - ((course.subject.days[i][j] == 7 && !isSatNeeded) ? 1 : 0)) +
                  (isCol ? (drawingIndex * colWidth) / colSize : 0),
              top: rowHeight * (course.subject.bgnPeriods[i][j] - bgnHour + 1) +
                  2 * (course.subject.bgnPeriods[i][j] - bgnHour),
            ),
          );
        }
      }
    });

    return Stack(
        children: [
          SingleChildScrollView(
            child: Stack(
              children: [
                Stack(
                  children: coursesList,
                )
              ],
            ),
          ),
        ]
    );

  }

  static List<Widget> prepareDay(String day, double rowHeight, double colWidth, int neededRows, Widget emptyCell) {

    List<Widget> list = [
      Container(
          color: Main.appTheme.headerBackgroundColor,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          child: Center(
              child: Text(translateEng(day), style: Main.appTheme.headerSchedulePageTextStyle)),
          height: rowHeight,
          width: colWidth
      )
    ];

    for (int i = 0 ; i < neededRows ; i++) {
      list.add(emptyCell);
    }

    return list;

  }

  List<CollisionData> collisionsTemp = []; // Temporary

  List<CollisionData> findCourseCollisions() {

    collisionsTemp = [];

    Main.schedules[Main.currentScheduleIndex].scheduleCourses.forEach((course1) {

      for (int i1 = 0 ; i1 < course1.subject.days.length ; i1++) {
        for (int j1 = 0 ; j1 < course1.subject.days[i1].length ; j1++) {

          int day1 = course1.subject.days[i1][j1], bgnHour1 = course1.subject.bgnPeriods[i1][j1], hours1 = course1.subject.hours[i1];

          Main.schedules[Main.currentScheduleIndex].scheduleCourses.forEach((course2) {

            // Check if they are not the same:
            if (course1.subject.isEqual(course2.subject)) {
              return;
            }

            for (int i2 = 0 ; i2 < course2.subject.days.length ; i2++) {
              for (int j2 = 0 ; j2 < course2.subject.days[i2].length ; j2++) {

                int day2 = course2.subject.days[i2][j2], bgnHour2 = course2.subject.bgnPeriods[i2][j2], hours2 = course2.subject.hours[i2];

                // Check if both courses collide:
                if (day1 == day2 &&
                    ((bgnHour1 >= bgnHour2 && bgnHour1 < (bgnHour2 + hours2)) || ((bgnHour1 + hours1) > bgnHour2 && (bgnHour1 + hours1) < (bgnHour2 + hours2)))) {
                  // yes, they collide
                  // Then check if they BOTH already exist inside collisions List:
                  if (!checkIfBothTogetherExistInCollisions(course1.subject, bgnHour1, course2.subject, bgnHour2, day1)) { // No they dont BOTH TOGETHER exist inside one collision:

                    // Then, check if ONLY one of both exist inside a collision:
                    List<int> data = checkIfOneExistInCollisions(course1.subject, bgnHour1, course2.subject, bgnHour2, day1);
                    if (data[0] != -1) {
                      // If yes, then check if one of course1, course2 or the rest of the courses actually collide with the rest of the courses in the collision:

                      //if (checkIfCommonCourseCollidesWithAll(commonSub, day1, bgnHour, data[0])) {
                        // if yes, then add the course that is NOT in common:
                      collisionsTemp[data[0]].subjects.add(data[1] == 2 ? course1.subject : course2.subject);
                      collisionsTemp[data[0]].subjectsData.add(PeriodData(day: day1, bgnPeriod: data[1] == 2 ? bgnHour1 : bgnHour2, hours: data[1] == 2 ? hours1 : hours2));
                      collisionsTemp[data[0]].isDrawn.add(false);
                      //}

                    } else { // Since they both collide, and none of one them already collides with any other course and they were not already added to cols
                      // So add them as a collision of 2:
                      PeriodData data1 = PeriodData(day: day1, bgnPeriod: bgnHour1, hours: hours1), data2 = PeriodData(day: day2, bgnPeriod: bgnHour2, hours: hours2);
                      collisionsTemp.add(CollisionData(subjects: [course1.subject, course2.subject], subjectsData: [data1, data2]));
                    }
                  }
                  // They already exist inside collisions, so dont add them
                }
                // if both courses dont collide, then do nothing!
              }
            }

          });

        }

      }

    });

    ;

    return collisionsTemp;

  }

  bool checkIfBothTogetherExistInCollisions(Subject sub1, int bgnHour1, Subject sub2, int bgnHour2, int day) {

    bool isFound1 = false, isFound2 = false;
    for (int i = 0 ; i < collisionsTemp.length ; i++) {

      for (int j = 0 ; j < collisionsTemp[i].subjects.length ; j++) {

        if (isFound1 && isFound2) {
          break;
        } else {
          if (!isFound1 && collisionsTemp[i].subjects[j].isEqual(sub1)) { // if it was not found and both courses are the same: then check the period:
            if (collisionsTemp[i].subjectsData[j].day == day && collisionsTemp[i].subjectsData[j].bgnPeriod == bgnHour1) {
              isFound1 = true;
            }
          }
          if (!isFound2 && collisionsTemp[i].subjects[j].isEqual(sub2)) { // if it was not found and both courses are the same: then check the period:
            if (collisionsTemp[i].subjectsData[j].day == day && collisionsTemp[i].subjectsData[j].bgnPeriod == bgnHour2) {
              isFound2 = true;
            }
          }
        }
      }
      if (isFound1 && isFound2) {
        break;
      } else { // reset at the end of each collision
        isFound1 = false;
        isFound2 = false;
      }
    }

    return isFound1 && isFound2;

  }

  // a list of two integers, the first is the collision index, the second is either 1 or 2, represents the subject number that is in common
  // if the first number is -1, then there is nothing in common
  List<int> checkIfOneExistInCollisions(Subject sub1, int bgnHour1, Subject sub2, int bgnHour2, int day) {

    for (int i = 0 ; i < collisionsTemp.length ; i++) {

      for (int j = 0 ; j < collisionsTemp[i].subjects.length ; j++) {

        if (collisionsTemp[i].subjects[j].isEqual(sub1) && collisionsTemp[i].subjectsData[j].day == day && collisionsTemp[i].subjectsData[j].bgnPeriod == bgnHour1) {
          return [i, 1];
        }

        if (collisionsTemp[i].subjects[j].isEqual(sub2) && collisionsTemp[i].subjectsData[j].day == day && collisionsTemp[i].subjectsData[j].bgnPeriod == bgnHour2) {
          return [i, 2];
        }

      }
    }

    return [-1];

  }

  // Branch IO code:

  void listenDynamicLinks() async {
    // print("Started listening to deep links!");
    print("Received a deep link!");
    FlutterBranchSdk.disableTracking(false);
    streamSubscription = FlutterBranchSdk.initSession().listen((data) async {

      // print('listenDynamicLinks - DeepLink Data: $data');
      controllerData.sink.add((data.toString()));

      if (data.containsKey('+clicked_branch_link') && data['+clicked_branch_link'] == true) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/schedule.txt');

        // print('Schedule Name: ${data['schedule_name']}');
        // print('Faculty: ${data['faculty']}');

        String str;
        String schedName = data['schedule_name'] ?? "Copied Schedule";
        str = schedName + "\n" + data['university'] + "\n" + data['faculty'];
        //
        for (int i = 0 ; i < int.parse(data['number_of_courses']) ; i++) {
          str = str + "\n" + data['course_${i+1}'];
        }

        print("Writing the following string to the file: $str");
        await file.writeAsString(str, mode: FileMode.write, flush: true);

        if (HomeState.currentState != null) {
          HomeState.currentState?.setState(() { checkScheduleAddition(); });
        }

      }
    }, onError: (error) {
      PlatformException platformException = error as PlatformException;
      // print('InitSession error: ${platformException.code} - ${platformException.message}');
      controllerInitSession.add('InitSession error: ${platformException.code} - ${platformException.message}');
    });
  }

  String fac = "", uni = "", scheduleName = "";

  void confirmScheduleAddtion(String scheduleName, List<String> courses, String uni, String faculty) {

    fac = faculty;
    this.uni = uni;
    this.scheduleName = scheduleName;
    List<Course> courses_ = [];
    courses.forEach((course) { courses_.add(Course(subject: Subject.fromStringWithCourseCode(course), note: "")); });

    // print("Adding the schedule: ");
    // print("Courses are: ");
    // courses_.forEach((element) {print(element.subject.classCode);});
    Main.schedules.add(Schedule(scheduleName: scheduleName, scheduleCourses: courses_));

  }

  void showSnackBar() {

    if (fac.isEmpty && this.uni.isEmpty) {
      return;
    }

    String faculty = fac, uni = this.uni;
    fac = "";
    this.uni = "";
    if (faculty == Main.faculty && uni == Main.uni) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("The schedule " + scheduleName + " has been added"),
        action: SnackBarAction(
          label: 'Set Active',
          onPressed: () {
            setState(() {
              Main.currentScheduleIndex = Main.schedules.length - 1;
            });
          },
        ),
      ));
    } else { // If the faculty or uni is different, warn the user, choose b/w CONTINUE or CANCEL
      setState(() {
        showDialog(context: context, builder: (context) {
          return AlertDialog(
            backgroundColor: Main.appTheme.scaffoldBackgroundColor,
            title: Text(translateEng("Adding Schedule"), style: TextStyle(color: Main.appTheme.titleTextColor)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                      Main.uni != uni ? "The university from the link is $uni, but the university chosen is ${Main.uni}, \nDo you want to add the schedule?" :
                      "The faculty of the received schedule is $faculty, but your faculty is ${Main.faculty},\nDo you want to add the schedule?",
                      style: TextStyle(fontSize: 18, color: Main.appTheme.titleTextColor)),
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () {
                setState(() {
                  Navigator.pop(context);
                  Main.currentScheduleIndex = Main.schedules.length - 1;
                });
              },
                child: Text(translateEng("CONTINUE")),
              ),
              TextButton(onPressed: () {
                Main.schedules.removeAt(Main.schedules.length - 1);
                Navigator.pop(context);
              },
                child: Text(translateEng("CANCEL")),
              )
            ],
          );
        });
      });
    }

  }

  void initDeepLinkData(int shceduleIndex) {
    metadata = BranchContentMetaData()
      ..addCustomMetadata('schedule_name', Main.schedules[shceduleIndex].scheduleName)
      //..addCustomMetadata('schedule_courses', Subject.convertToListWithClassCodes(Main.schedules[Main.currentScheduleIndex].scheduleCourses))
      ..addCustomMetadata('number_of_courses', Main.schedules[shceduleIndex].scheduleCourses.length)
      ..addCustomMetadata('university', Main.uni)
      ..addCustomMetadata('faculty', Main.faculty);
    for (int i = 0 ; i < Main.schedules[shceduleIndex].scheduleCourses.length ; i++) {
      metadata.addCustomMetadata("course_${i+1}", Main.schedules[shceduleIndex].scheduleCourses[i].subject.courseCode + "|"
          + Main.schedules[shceduleIndex].scheduleCourses[i].subject.toString());
    }

    buo = BranchUniversalObject(
        canonicalIdentifier: 'flutter/branch',
        //parameter canonicalUrl
        //If your content lives both on the web and in the app, make sure you set its canonical URL
        // (i.e. the URL of this piece of content on the web) when building any BUO.
        // By doing so, we’ll attribute clicks on the links that you generate back to their original web page,
        // even if the user goes to the app instead of your website! This will help your SEO efforts.
        title: 'Schedule Share',
        contentDescription: 'Schedule Share using Deep Links',
        contentMetadata: metadata,
        keywords: ['${Main.uni} University', 'Schedule', 'Timetable'],
        publiclyIndex: true,
        locallyIndex: true,
        expirationDateInMilliSec: DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch);

    lp = BranchLinkProperties(
        channel: 'Dersbottest App',
        feature: 'sharing',

        stage: 'Schedule Sharing',
        //campaign: '',
        tags: [Main.faculty, Main.department])
      ..addControlParam('\$uri_redirect_mode', '1')
      ..addControlParam('referring_user_id', 'default');

  }

  Future<BranchResponse?> generateLink() async {
    BranchResponse response =
    await FlutterBranchSdk.getShortUrl(buo: buo!, linkProperties: lp);
    if (response.success) {
      controllerUrl.sink.add('${response.result}');
      return response;
    } else {
      controllerUrl.sink
          .add('Error : ${response.errorCode} - ${response.errorMessage}');
    }

    return null;
  }

}
