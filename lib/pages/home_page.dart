import 'dart:async';
import 'dart:io';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:ders_program_test/language/dictionary.dart';
import 'package:ders_program_test/others/subject.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:ders_program_test/others/departments.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';

import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../others/appthemes.dart';
import '../widgets/counterbutton.dart';

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

    Main.forceUpdate = false;

    WidgetsBinding.instance.addObserver(this);

    toggleButtonController = AnimationController(duration: const Duration(seconds: 1), vsync: this);

    currentState = this;

    print("Initializing the home page state!");

    listenDynamicLinks();

    checkScheduleAddition();


  }

  void checkScheduleAddition() {

    print("Trying to find extra files: ");
    String content = "";
    try {
      final file = File('${Main.appDocDir}/schedule.txt'); // FileSystemException

      content = file.readAsStringSync();
      file.deleteSync();
      if (content.isNotEmpty) {
        print("Extra Schedule was found with the content of: $content");
        List<String> lines = content.split("\n");
        String scheduleName = lines[0];
        String faculty = lines[1];
        lines.removeAt(0); // schedule name
        lines.removeAt(0); // faculty
        confirmScheduleAddtion(scheduleName, lines, faculty);
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

    print("The state of the app has changed!");

    switch (state) {
      case AppLifecycleState.detached:
        print("The lifecycle has changed into detached");
        Main.save();
        break;
      case AppLifecycleState.inactive:
        print("The lifecycle has changed into inactive");
        Main.save();

        break;
      case AppLifecycleState.paused:
        print("The lifecycle has changed into paused");
        Main.save();

        break;
      case AppLifecycleState.resumed:
        print("The lifecycle has changed into resumed");

        break;
    }

  }

  @override
  void dispose() {

    toggleButtonController.dispose();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Main.appTheme.headerBackgroundColor,
      systemNavigationBarColor: Main.appTheme.navigationBarColor,
    ));

    width = (window.physicalSize / window.devicePixelRatio).width;
    height = (window.physicalSize / window.devicePixelRatio).height;
    // if (MediaQuery.of(context).orientation == Orientation.landscape) { // it screwed the other pages, only apply for the counter button inside here!
    //   double x = height;
    //   height = width;
    //   width = x;
    // }

    var isPortrait = MediaQuery
        .of(context)
        .orientation == Orientation.portrait;

    Widget? schedulePage;
    if (pageIndex == 0) {
      schedulePage = buildSchedulePage();
    }

    Widget? servicesPage;
    if (pageIndex == 1) {
      servicesPage = Container(
          padding: EdgeInsets.symmetric(horizontal: 0.02 * width, vertical: 0.05 * width),
          child: ListView(
            children: [
              ListTile(
                onTap: () {
                  Navigator.pushNamed(context, "/home/editcourses");
                },
                title: Text(translateEng('Edit Courses'), style: TextStyle(color: Main.appTheme.titleTextColor)),
                subtitle: Text(translateEng('Add and edit the courses on the current schedule'), style: TextStyle(color: Main.appTheme.subtitleTextColor)),
                leading: Icon(Icons.edit, color: Main.appTheme.titleIconColor),
              ),
              SizedBox(height: height * 0.01),
              ListTile(
                onTap: () {
                  Navigator.pushNamed(context, "/home/searchcourses");
                },
                title: Text(translateEng('Search for Courses'), style: TextStyle(color: Main.appTheme.titleTextColor)),
                subtitle: Text(translateEng('Search for courses using its name, classroom number, teacher or department'), style: TextStyle(color: Main.appTheme.subtitleTextColor)),
                leading: Icon(Icons.search, color: Main.appTheme.titleIconColor),
              ),
              SizedBox(height: height * 0.01),
              ListTile(
                onTap: () {
                  Navigator.pushNamed(context, "/home/favcourses");
                },
                title: Text(translateEng('Favourite Courses'), style: TextStyle(color: Main.appTheme.titleTextColor)),
                leading: Icon(Icons.star, color: Main.appTheme.titleIconColor),
              ),
              SizedBox(height: height * 0.01),
              ListTile(
                onTap: () {
                  Navigator.pushNamed(context, "/home/scheduler");
                },
                title: Text(translateEng('Scheduler'), style: TextStyle(color: Main.appTheme.titleTextColor)),
                subtitle: Text(translateEng('Choose the courses with the sections with specific options, then choose your appropriate schedule'), style: TextStyle(color: Main.appTheme.subtitleTextColor)),
                leading: Icon(Icons.calendar_today, color: Main.appTheme.titleIconColor),
              ),
              SizedBox(height: height * 0.01),
              ListTile(
                onTap: () {
                  // TODO:
                  ;
                },
                title: Text(translateEng('Department Plans'), style: TextStyle(color: Main.appTheme.titleTextColor)),
                subtitle: Text(translateEng('These plans are provided by the university'), style: TextStyle(color: Main.appTheme.subtitleTextColor)),
                leading: Icon(CupertinoIcons.square_arrow_right, color: Main.appTheme.titleIconColor),
              ),
              SizedBox(height: height * 0.01),
              ListTile(
                onTap: () {
                  Navigator.pushNamed(context, "/home/savedschedules");
                },
                title: Text(translateEng('Saved Schedules'), style: TextStyle(color: Main.appTheme.titleTextColor)),
                subtitle: Text(translateEng('You can save schedules and set them back again'), style: TextStyle(color: Main.appTheme.subtitleTextColor)),
                leading: Icon(Icons.edit_calendar, color: Main.appTheme.titleIconColor),
              ),
            ],
          )
      );
    }

    Widget? settingsPage;
    if (pageIndex == 2) {
      String hours = "", day, hr, mins;
      int days;

      hr = (Main.facultyData.lastUpdate.hour < 10 ? "0" : "") + Main.facultyData.lastUpdate.hour.toString();
      mins = (Main.facultyData.lastUpdate.minute < 10 ? "0" : "") + Main.facultyData.lastUpdate.minute.toString();
      hours = hr + ":" + mins;
      days = Main.facultyData.lastUpdate.difference(DateTime.now()).inDays;

      if (days == 0) {
        day = "Today";
      } else if (days == 1) {
        day = "Yesterday";
      } else {
        day = "$days days ago";
      }

      settingsPage = ListView(
        padding: EdgeInsets.all(width * 0.02),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(translateEng("Language"), style: TextStyle(color: Main.appTheme.titleTextColor)),
              DropdownButton<String>(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(translateEng("Faculty"), style: TextStyle(color: Main.appTheme.titleTextColor)),
              DropdownButton<String>(
                dropdownColor: Main.appTheme.scaffoldBackgroundColor,
                value: Main.faculty,
                items: faculties.keys.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem(value: value, child: Text(translateEng(value), style: TextStyle(color: Main.appTheme.titleTextColor)));
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue == Main.faculty) {
                    return;
                  }
                  setState(() {
                    showDialog(context: context, builder: (context) {
                      return AlertDialog(
                        backgroundColor: Main.appTheme.scaffoldBackgroundColor,
                        title: Text(translateEng("Restarting the application"), style: TextStyle(color: Main.appTheme.titleTextColor)),
                        actions: [
                          TextButton(onPressed: () {
                            Main.forceUpdate = true;
                            Main.faculty = newValue!;
                            Main.department = faculties[Main.faculty]?.keys.elementAt(0) as String;
                            Main.restart();
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
                  });
                },
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(translateEng("Department"), style: TextStyle(color: Main.appTheme.titleTextColor)),
              DropdownButton<String>(
                dropdownColor: Main.appTheme.scaffoldBackgroundColor,
                value: Main.department,
                items: faculties[Main.faculty]?.keys.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem(value: value, child: Row(children: [
                    Text(translateEng(value) + "  ", style: TextStyle(color: Main.appTheme.titleTextColor)), Text(translateEng(faculties[Main.faculty]![value] as String), style: TextStyle(fontSize: 10, color: Main.appTheme.titleTextColor))
                  ],),);
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    Main.department = newValue!;
                  });
                },
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                translateEng("Last Updated") + "    ${day}  ${hours}",
                style: TextStyle(color: Colors.red.shade500, fontWeight: FontWeight.bold),
              ),
              TextButton(onPressed: () {
                setState(() {
                  Main.forceUpdate = true;
                  Main.restart();
                });
              }, child: Text(translateEng("Update now"))),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(translateEng("Update Timeout (hours)"), style: TextStyle(color: Main.appTheme.titleTextColor)),
              Row(
                children: [
                  SizedBox(
                    width: 0.08 * (MediaQuery.of(context).orientation == Orientation.portrait ? width : height),
                    height: 0.08 * (MediaQuery.of(context).orientation == Orientation.portrait ? width : height),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 4),
                            color: Colors.pink.withOpacity(0.3),
                            blurRadius: 8.0,
                            spreadRadius: 0.0,
                          ),
                        ],
                      ),
                      child: CounterButton(
                        isIncrement: false,
                        onPressed: () {
                          setState(() {
                            if (Main.hourUpdate == 12) return;
                            Main.hourUpdate--;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.03,
                    height: height * 0.03,
                  ),
                  Text("${Main.hourUpdate}", style: TextStyle(color: Main.appTheme.titleTextColor)),
                  SizedBox(
                    width: width * 0.03,
                    height: height * 0.03,
                  ),
                  SizedBox(
                    width: 0.08 * (MediaQuery.of(context).orientation == Orientation.portrait ? width : height),
                    height: 0.08 * (MediaQuery.of(context).orientation == Orientation.portrait ? width : height),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 4),
                            color: Colors.pink.withOpacity(0.3),
                            blurRadius: 8.0,
                            spreadRadius: 0.0,
                          ),
                        ],
                      ),
                      child: CounterButton(
                        isIncrement: true,
                        onPressed: () {
                          setState(() {
                            if (Main.hourUpdate == 24) return;
                            Main.hourUpdate++;
                          });
                        },
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(translateEng("Theme"), style: TextStyle(color: Main.appTheme.titleTextColor)),
              TextButton(
                  child: Lottie.asset(
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
                  ),
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
        ],
      );
    }

    Widget? linksPage;
    if (pageIndex == 3) {
      linksPage = ListView(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(0.1 * width, 0.03 * width, 0, 0),
            child: ListTile(
              leading: Image.asset("lib/icons/atacs.png", width: IconTheme.of(context).size!, height: IconTheme.of(context).size!),
              title: Text('Atacs', style: TextStyle(color: Main.appTheme.titleTextColor)),
              onTap: () async {
                const url = 'https://atacs.atilim.edu.tr/Anasayfa/Student';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0.1 * width, 0, 0, 0),
            child: ListTile(
              leading: Icon(Icons.schedule, color: Main.appTheme.titleTextColor),
              title: Text(translateEng("School's Schedules"), style: TextStyle(color: Main.appTheme.titleTextColor)),
              onTap: () async {
                const url = 'https://www.atilim.edu.tr/en/dersprogrami';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
          ),Container(
            padding: EdgeInsets.fromLTRB(0.1 * width, 0, 0, 0),
            child: ListTile(
              leading: Icon(Icons.calculate, color: Main.appTheme.titleTextColor),
              title: Text(translateEng("GPA Calculator"), style: TextStyle(color: Main.appTheme.titleTextColor)),
              onTap: () async {
                const url = 'https://metugpa.com';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
          ),

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
        ],
      );
    }

    Widget? aboutPage;
    if (pageIndex == 4) {
      aboutPage = ListView(
        children: [
          ListTile(
            title: Text(translateEng('Send a Message'), style: TextStyle(color: Main.appTheme.titleTextColor)),
            leading: Icon(CupertinoIcons.mail_solid, color: Main.appTheme.titleIconColor),
            subtitle: Text(translateEng("Complains and Suggestions"), style: TextStyle(color: Main.appTheme.subtitleTextColor)),
            onTap: () async { // TODO: Change in the future:
              const url = 'mailto:hassan1551@outlook.com?subject:Scheduling%20App&body=%0A%0A%0AThank you for 2 months of effort'; // %0A new line / %20 white space
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
            },
          ),
          ListTile(
            title: Row(
              children: [
                Icon(Icons.person, color: Main.appTheme.titleIconColor),
                SizedBox(width: width * 0.03),
                Text(translateEng('About the Creator'), style: TextStyle(color: Main.appTheme.titleTextColor)),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(context, "/home/personalinfo");
            },
          ),
          // ListTile(
          //   title: Text(translateEng('Donate me')),
          //   onTap: () async {
          //     const url = 'https://www.buymeacoffee.com/hasanamkieh?new=1';
          //     if (await canLaunch(url)) {
          //       await launch(url);
          //     } else {
          //       throw 'Could not launch $url';
          //     }
          //   },
          // ),
        ],
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
      aboutPage ?? errorPage,
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
          height: isPortrait ? height * 0.08 : width * 0.08,
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
            NavigationDestination(icon: Icon(Icons.info_outlined, color: Main.appTheme.navIconColor), selectedIcon: Icon(Icons.info, color: Main.appTheme.navIconColor), label: translateEng('About')),
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

  Widget buildSchedulePage() {

    double colWidth = (width) / 7; // 6 days and a col for the clock
    double rowHeight = (height * 1) / 11; // 10 for the lock and one for the empty box // 91 percent because of the horizontal borders
    
    Color emptyCellColor = Main.appTheme.emptyCellColor;
    Color horizontalBorderColor = Colors.black38; // bgnHours seperator
    Container emptyCell = Container(decoration: BoxDecoration(
        color: emptyCellColor,
        border: Border.symmetric(
            horizontal: BorderSide(color: horizontalBorderColor, width: 1)
        )),
        child: SizedBox(width: colWidth, height: rowHeight,));

    List<Widget> coursesList = [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Main.appTheme.headerBackgroundColor,
            child: Column( // Headers
              children: [
                SizedBox(width: colWidth, height: rowHeight),
                Container(
                    color: Main.appTheme.headerBackgroundColor,
                    child: Center(child: Text('9:30', style: Main.appTheme.headerSchedulePageTextStyle)),
                    height: rowHeight),
                Container(
                    color: Main.appTheme.headerBackgroundColor,
                    child: Center(child: Text('10:30', style: Main.appTheme.headerSchedulePageTextStyle)),
                    height: rowHeight),
                Container(
                    color: Main.appTheme.headerBackgroundColor,
                    child: Center(child: Text('11:30', style: Main.appTheme.headerSchedulePageTextStyle,)),
                    height: rowHeight),
                Container(
                    color: Main.appTheme.headerBackgroundColor,
                    child: Center(child: Text('12:30', style: Main.appTheme.headerSchedulePageTextStyle,)),
                    height: rowHeight),
                Container(
                    color: Main.appTheme.headerBackgroundColor,
                    child: Center(child: Text('13:30', style: Main.appTheme.headerSchedulePageTextStyle,)),
                    height: rowHeight),
                Container(
                    color: Main.appTheme.headerBackgroundColor,
                    child: Center(child: Text('14:30', style: Main.appTheme.headerSchedulePageTextStyle,)),
                    height: rowHeight),
                Container(
                    color: Main.appTheme.headerBackgroundColor,
                    child: Center(child: Text('15:30', style: Main.appTheme.headerSchedulePageTextStyle,)),
                    height: rowHeight),
                Container(
                    color: Main.appTheme.headerBackgroundColor,
                    child: Center(child: Text('16:30', style: Main.appTheme.headerSchedulePageTextStyle,)),
                    height: rowHeight),
                Container(
                    color: Main.appTheme.headerBackgroundColor,
                    child: Center(child: Text('17:30', style: Main.appTheme.headerSchedulePageTextStyle,)),
                    height: rowHeight),
                Container(
                    color: Main.appTheme.headerBackgroundColor,
                    child: Center(child: Text('18:30', style: Main.appTheme.headerSchedulePageTextStyle,)),
                    height: rowHeight + height * 0.04),
              ],
            ),
          ),
          Container(
            color: Main.appTheme.headerBackgroundColor,
            child: Column( // Headers
              children: [
                Container(
                  color: Main.appTheme.headerBackgroundColor,
                  child: Center(
                    child: Text(translateEng('Mon'), style: Main.appTheme.headerSchedulePageTextStyle)),
                  height: rowHeight,
                  width: colWidth,),
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
              ],
            ),
          ),
          Container(
            color: Main.appTheme.headerBackgroundColor,
            child: Column( // Headers
              children: [
                Container(
                    color: Main.appTheme.headerBackgroundColor,
                    child: Center(
                    child: Text(translateEng('Tue'), style: Main.appTheme.headerSchedulePageTextStyle,)),
                    height: rowHeight,
                    width: colWidth),
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
              ],
            ),
          ),
          Container(
            color: Main.appTheme.headerBackgroundColor,
            child: Column( // Headers
              children: [
                Container(
                    color: Main.appTheme.headerBackgroundColor,
                    child: Center(
                    child: Text(translateEng('Wed'), style: Main.appTheme.headerSchedulePageTextStyle,)),
                    height: rowHeight,
                    width: colWidth),
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
              ],
            ),
          ),
          Container(
            color: Main.appTheme.headerBackgroundColor,
            child: Column( // Headers
              children: [
                Container(
                    child: Center(
                    child: Text(translateEng('Thur'), style: Main.appTheme.headerSchedulePageTextStyle)),
                    height: rowHeight,
                    width: colWidth),
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
              ],
            ),
          ),
          Container(
            color: Main.appTheme.headerBackgroundColor,
            child: Column( // Headers
              children: [
                Container(
                  color: Main.appTheme.headerBackgroundColor,
                    child: Center(
                    child: Text(translateEng('Fri'), style: Main.appTheme.headerSchedulePageTextStyle)),
                    height: rowHeight,
                    width: colWidth),
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
              ],
            ),
          ),
          Container(
            color: Main.appTheme.headerBackgroundColor,
            child: Column( // Headers
              children: [
                Container(
                    color: Main.appTheme.headerBackgroundColor,
                    child: Center(
                    child: Text(translateEng('Sat'), style: Main.appTheme.headerSchedulePageTextStyle)),
                    height: rowHeight,
                    width: colWidth),
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
                emptyCell,
              ],
            ),
          ),
        ],
      ),
    ];

    Main.schedules[Main.currentScheduleIndex].scheduleCourses.forEach((element) {print(element.subject.toString());});
    // First find all the collisions:
    collisions = findCourseCollisions();
    print("All the collisions are: ");
    //collisions.forEach((col) { print("\nCOLLISION:"); col.subjects.forEach((element) {print(element.classCode);}); });

    int colorIndex = -1;

    Main.schedules[Main.currentScheduleIndex].scheduleCourses.forEach((course) {
      colorIndex++;
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
                print("Drawing the collisioned course: ${course.subject.classCode}");
                collisions[colIndex].isDrawn[atIndex] = true;
                isCol = true;
                isColOf3 = collisions[colIndex].subjects.length >= 3;
                drawingIndex = atIndex;
                colSize = col.subjects.length;
                continue;
              } else {
                print("NOT Drawing the collisioned course bcs the period is different: ${course.subject.classCode}");
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

          coursesList.add(
            Positioned(child: TextButton(
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
                            text: course.subject.classCode,
                            style: TextStyle(
                                color: whiteThemeScheduleColors[colorIndex][1],
                                fontSize: 11.0),
                          ),
                          TextSpan(
                            text: (isCol ? "  " : "\n") + (i < course.subject.classrooms.length ? deleteRepitions(course.subject.classrooms[i]).toString().replaceAll(RegExp("[\\[.*?\\]]"), "") : ""),
                            style: TextStyle(
                                color: whiteThemeScheduleColors[colorIndex][1],
                                fontSize: 9.0),
                          ),
                        ]
                    ),
                  ),
                ),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                      isColOf3 ? EdgeInsets.symmetric(vertical: 0.01 * width, horizontal: 0.005 * width) : EdgeInsets.all(0.01 * width)),
                  backgroundColor: MaterialStateProperty.all(
                      whiteThemeScheduleColors[colorIndex][0]),
                  shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero)),
                  overlayColor: MaterialStateProperty.all(
                      const Color.fromRGBO(255, 255, 255, 0.2)),
                )),
              width: isCol ? colWidth / colSize : colWidth,
              height: rowHeight * course.subject.hours[i],
              left: colWidth * course.subject.days[i][j] +
                  (isCol ? (drawingIndex * colWidth) / colSize : 0),
              top: rowHeight * course.subject.bgnPeriods[i][j] +
                  2 * (course.subject.bgnPeriods[i][j] - 1),
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

                      Subject commonSub = data[1] == 1 ? course1.subject : course2.subject;
                      int bgnHour = data[1] == 1 ? bgnHour1 : bgnHour2;
                      int hours = data[1] == 1 ? hours1 : hours2;
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
    print("Started listening to deep links!");
    streamSubscription = FlutterBranchSdk.initSession().listen((data) async {

      print('listenDynamicLinks - DeepLink Data: $data');
      controllerData.sink.add((data.toString()));

      if (data.containsKey('+clicked_branch_link') && data['+clicked_branch_link'] == true) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/schedule.txt');

        print('Schedule Name: ${data['schedule_name']}');
        print('Faculty: ${data['faculty']}');

        String str;
        str = data['schedule_name'] + "\n" + data['faculty'];
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
      print('InitSession error: ${platformException.code} - ${platformException.message}');
      controllerInitSession.add('InitSession error: ${platformException.code} - ${platformException.message}');
    });
  }

  String fac = "", scheduleName = "";
  void confirmScheduleAddtion(String scheduleName, List<String> courses, String faculty) {

    fac = faculty;this.scheduleName = scheduleName;
    List<Course> courses_ = [];
    courses.forEach((course) { courses_.add(Course(subject: Subject.fromStringWithClassCode(course), note: "")); });

    // print("Adding the schedule: ");
    // print("Courses are: ");
    // courses_.forEach((element) {print(element.subject.classCode);});
    Main.schedules.add(Schedule(scheduleName: scheduleName, scheduleCourses: courses_));

  }

  void showSnackBar() {

    if (fac.isEmpty) {
      return;
    }

    String faculty = fac;
    fac = "";
    if (faculty == Main.faculty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(scheduleName + " has been added to the "),
        action: SnackBarAction(
          label: 'Set Active',
          onPressed: () {
            setState(() {
              Main.currentScheduleIndex = Main.schedules.length - 1;
            });
          },
        ),
      ));
    } else { // If the faculty is different, warn the user, choose b/w CONTINUE or CANCEL
      setState(() {
        showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: Text(translateEng("Adding Schedule")),
            content: Center(
              child: Text(
                  "The faculty of the received schedule is $faculty, but your faculty is ${Main.faculty},\nDo you want to add the schedule?",
                  style: const TextStyle(fontSize: 18)),
            ),
            actions: [
              TextButton(onPressed: () {
                Navigator.pop(context);
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
      ..addCustomMetadata('faculty', Main.faculty);
    for (int i = 0 ; i < Main.schedules[shceduleIndex].scheduleCourses.length ; i++) {
      metadata.addCustomMetadata("course_${i+1}", Main.schedules[shceduleIndex].scheduleCourses[i].subject.classCode + "|"
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
        keywords: ['Atilim University', 'Schedule', 'Timetable'],
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
