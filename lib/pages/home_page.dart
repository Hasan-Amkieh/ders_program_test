import 'package:ders_program_test/language/dictionary.dart';
import 'package:ders_program_test/others/subject.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:ders_program_test/others/departments.dart';
import 'package:flutter/services.dart';

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

class HomeState extends State<Home> {

  int pageIndex = 0;

  TextStyle headerTxtStyle = const TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
  late double width;
  late double height;
  static const navigationBarColor = Color.fromRGBO(80, 114, 150, 1.0);

  List<CollisionData> collisions = [];

  @override
  void initState() {

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.blue,
      systemNavigationBarColor: navigationBarColor,
    ));

  }

  @override
  Widget build(BuildContext context) {
    width = (window.physicalSize / window.devicePixelRatio).width;
    height = (window.physicalSize / window.devicePixelRatio).height;

    isLangEng = Main.language == "English";

    var isPortrait = MediaQuery
        .of(context)
        .orientation == Orientation.portrait;

    Widget? schedulePage;
    if (pageIndex == 0) {
      double colWidth = (width) / 7; // 6 days and a col for the clock
      double rowHeight = (height * 1) / 11; // 10 for the lock and one for the empty box // 91 percent because of the horizontal borders

      Color headerColor = Colors.blue;
      Color emptyCellColor = Colors.white;
      Color horizontalBorderColor = Colors.blueGrey.shade200;
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
            color: headerColor,
            child: Column( // Headers
              children: [
                SizedBox(width: colWidth, height: rowHeight),
                Container(
                    child: Center(child: Text('9:30', style: headerTxtStyle,)),
                    height: rowHeight),
                Container(
                    child: Center(child: Text('10:30', style: headerTxtStyle,)),
                    height: rowHeight),
                Container(
                    child: Center(child: Text('11:30', style: headerTxtStyle,)),
                    height: rowHeight),
                Container(
                    child: Center(child: Text('12:30', style: headerTxtStyle,)),
                    height: rowHeight),
                Container(
                    child: Center(child: Text('13:30', style: headerTxtStyle,)),
                    height: rowHeight),
                Container(
                    child: Center(child: Text('14:30', style: headerTxtStyle,)),
                    height: rowHeight),
                Container(
                    child: Center(child: Text('15:30', style: headerTxtStyle,)),
                    height: rowHeight),
                Container(
                    child: Center(child: Text('16:30', style: headerTxtStyle,)),
                    height: rowHeight),
                Container(
                    child: Center(child: Text('17:30', style: headerTxtStyle,)),
                    height: rowHeight),
                Container(
                    child: Center(child: Text('18:30', style: headerTxtStyle,)),
                    height: rowHeight + height * 0.04),
              ],
            ),
          ),
          Container(
            color: headerColor,
            child: Column( // Headers
              children: [
                Container(child: Center(
                    child: Text(translateEng('Mon'), style: headerTxtStyle)),
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
            color: headerColor,
            child: Column( // Headers
              children: [
                Container(child: Center(
                    child: Text(translateEng('Tue'), style: headerTxtStyle,)),
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
            color: headerColor,
            child: Column( // Headers
              children: [
                Container(child: Center(
                    child: Text(translateEng('Wed'), style: headerTxtStyle,)),
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
            color: headerColor,
            child: Column( // Headers
              children: [
                Container(child: Center(
                    child: Text(translateEng('Thur'), style: headerTxtStyle)),
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
            color: headerColor,
            child: Column( // Headers
              children: [
                Container(child: Center(
                    child: Text(translateEng('Fri'), style: headerTxtStyle)),
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
            color: headerColor,
            child: Column( // Headers
              children: [
                Container(child: Center(
                    child: Text(translateEng('Sat'), style: headerTxtStyle)),
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

      // First find all the collisions:
      collisions = findCourseCollisions();

      int colorIndex = 0;

      Main.schedules[Main.currentScheduleIndex].scheduleCourses.forEach((course) {
      colorIndex++;
      for (int i = 0; i < course.subject.days.length; i++) {
        for (int j = 0; j < course.subject.days[i].length; j++) {
          bool isCol = false, isColOf3 = false;
          int atIndex = 0,
              drawingIndex = 0,
              colSize = 1; // colSize determines how many subjects are actually in this collision
          int colIndex = 0;
          collisions.forEach((col) {
            atIndex = 0;
            col.subjects.forEach((sub) {
              if (sub.isEqual(course.subject) && i == col.i[atIndex] &&
                  j == col.j[atIndex] && !col.isDrawn[atIndex]) {
                collisions[colIndex].isDrawn[atIndex] = true;
                isCol = true;
                isColOf3 = collisions[colIndex].is3Col;
                drawingIndex = atIndex;
                colSize = col.subjects.length;
                return;
              }
              if (isCol) {
                return;
              }
              atIndex++;
            });
            colIndex++;
            if (isCol) {
              return;
            }
          });
          print("index $drawingIndex");

          coursesList.add(
            Positioned(child: TextButton(
              //clipBehavior: Clip.none,
                onPressed: () => showCourseInfo(course.subject),
                // TODO: Make it pass a class called "PeriodData" / which holds only the info of the current period!
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
                                fontSize: 12.0),
                          ),
                          TextSpan(
                            text: (isCol ? "  " : "\n") + course.subject
                                .classrooms[i].toString().replaceAll(
                                RegExp("[\\[.*?\\]]"), ""),
                            style: TextStyle(
                                color: whiteThemeScheduleColors[colorIndex][1],
                                fontSize: 10.0),
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

      schedulePage = Stack(
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
                title: Text(translateEng('Edit Courses')),
                subtitle: Text(translateEng('Add and edit the courses on the current schedule')),
                leading: const Icon(Icons.edit),
              ),
              SizedBox(height: height * 0.01),
              ListTile(
                onTap: () {
                  Navigator.pushNamed(context, "/home/searchcourses");
                },
                title: Text(translateEng('Search for Courses')),
                subtitle: Text(translateEng('Search for courses using its name, classroom number, teacher or department')),
                leading: const Icon(Icons.search),
              ),
              SizedBox(height: height * 0.01),
              ListTile(
                onTap: () {
                  Navigator.pushNamed(context, "/home/favcourses");
                },
                title: Text(translateEng('Favourite Courses')),
                leading: const Icon(Icons.star_border),
              ),
              SizedBox(height: height * 0.01),
              ListTile(
                onTap: () {
                  // TODO:
                  ;
                },
                title: Text(translateEng('Scheduler')),
                subtitle: Text(translateEng('Choose the courses with the sections with specific options, then choose your appropriate schedule')),
                leading: const Icon(Icons.calendar_today),
              ),
              SizedBox(height: height * 0.01),
              ListTile(
                onTap: () {
                  // TODO:
                  ;
                },
                title: Text(translateEng('Choose Made-up Plans')),
                subtitle: Text(translateEng('These plans are provided by the university')),
                leading: const Icon(CupertinoIcons.square_arrow_right),
              ),
              SizedBox(height: height * 0.01),
              ListTile(
                onTap: () {
                  Navigator.pushNamed(context, "/home/savedschedules");
                },
                title: Text(translateEng('Saved Schedules')),
                subtitle: Text(translateEng('You can save schedules and set them back again')),
                leading: const Icon(Icons.edit_calendar),
              ),
            ],
          )
      );
    }

    Widget? settingsPage;
    if (pageIndex == 2) {
      String hours = "", day, hr, mins;
      int days;

      hr = (Main.semesters[0].lastUpdate.hour < 10 ? "0" : "") + Main.semesters[0].lastUpdate.hour.toString();
      mins = (Main.semesters[0].lastUpdate.minute < 10 ? "0" : "") + Main.semesters[0].lastUpdate.minute.toString();
      hours = hr + ":" + mins;
      days = Main.semesters[0].lastUpdate.difference(DateTime.now()).inDays;

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
              Text(translateEng("Language")),
              DropdownButton<String>(
                value: Main.language,
                items: langs.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem(value: value, child:
                  TextButton.icon(onPressed: null, icon: Image.asset("lib/icons/" + value + ".png"), label: Text(translateEng(value)))
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    Main.language = newValue!;
                    Main.saveSettings();
                  });
                },
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(translateEng("Faculty")),
              DropdownButton<String>(
                value: Main.faculty,
                items: faculties.keys.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem(value: value, child: Text(translateEng(value)));
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue == Main.faculty) {
                    return;
                  }
                  setState(() {
                    showDialog(context: context, builder: (context) {
                      return AlertDialog(
                        title: Text(translateEng("Restarting the application")),
                        actions: [
                          TextButton(onPressed: () {
                            Main.forceUpdate = true;
                            Main.faculty = newValue!;
                            Main.department = faculties[Main.faculty]?.keys.elementAt(0) as String;
                            Main.save();
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
              Text(translateEng("Department")),
              DropdownButton<String>(
                value: Main.department,
                items: faculties[Main.faculty]?.keys.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem(value: value, child: Row(children: [
                    Text(translateEng(value) + "  "), Text(translateEng(faculties[Main.faculty]![value] as String), style: TextStyle(fontSize: 10))
                  ],),);
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    Main.department = newValue!;
                    Main.saveSettings();
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
                style: TextStyle(color: Colors.red.shade500),
              ),
              TextButton(onPressed: () {
                setState(() {
                  Main.forceUpdate = true;
                  Main.save();
                  Main.restart();
                });
              }, child: Text(translateEng("Update now"))),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(translateEng("Update Timeout (hours)")),
              Row(
                children: [
                  SizedBox(
                    width: 0.08 * width,
                    height: 0.08 * width,
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
                            Main.saveSettings();
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.03,
                    height: height * 0.03,
                  ),
                  Text("${Main.hourUpdate}"),
                  SizedBox(
                    width: width * 0.03,
                    height: height * 0.03,
                  ),
                  SizedBox(
                    width: 0.08 * width,
                    height: 0.08 * width,
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
                            Main.saveSettings();
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
              Text(translateEng("Theme")),
              TextButton.icon(
                  icon: Main.theme == ThemeMode.dark ? const Icon(CupertinoIcons.moon_fill) : const Icon(CupertinoIcons.sun_max),
                  label: const Text(""),
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  onPressed: () {
                    setState(() {
                      if (Main.theme == ThemeMode.dark) {
                        Main.theme = ThemeMode.light;
                      } else {
                        Main.theme = ThemeMode.dark;
                      }
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
            padding: EdgeInsets.fromLTRB(0.05 * width, 0.03 * width, 0, 0),
            child: const Text(
              "Important Links",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
          ),
          Divider(
            height: 2.0,
            thickness: 2.0,
            indent: 0.03 * width,
            endIndent: 0.03 * width,
            color: Colors.blueGrey.withOpacity(0.8),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0.1 * width, 0.03 * width, 0, 0),
            child: ListTile(
              title: Text('Atacs'),
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
              title: Text(translateEng("School's Schedules")),
              onTap: () async {
                const url = 'https://www.atilim.edu.tr/en/dersprogrami';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0.05 * width, 0.03 * width, 0, 0),
            child: const Text(
              "Announcements",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
          ),
          Divider(
            height: 2.0,
            thickness: 2.0,
            indent: 0.03 * width,
            endIndent: 0.03 * width,
            color: Colors.blueGrey.withOpacity(0.8),
          ),
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
            title: Text(translateEng('Donate me')),
            onTap: () async {
              const url = 'https://www.buymeacoffee.com/hasanamkieh?new=1';
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            },
          )
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
      body: SafeArea(
          child: pages[pageIndex]
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: const NavigationBarThemeData(
            indicatorColor: Color.fromRGBO(80, 154, 167, 0.8),
        ),
        child: NavigationBar(
          backgroundColor: navigationBarColor,
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
            // TODO: Check, how do I know the size of the icon? is there a way to know? amd apply it to the width of the tools image:
            NavigationDestination(icon: const Icon(CupertinoIcons.calendar_today), selectedIcon: const Icon(CupertinoIcons.calendar_circle_fill), label: translateEng('Schedule')),
            NavigationDestination(icon: Image.asset("lib/icons/tools_outlines.png", width: IconTheme.of(context).size!), selectedIcon: Image.asset("lib/icons/tools_filled.png", width: IconTheme.of(context).size!), label: translateEng('Tools')),
            NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: translateEng('Settings')),
            NavigationDestination(icon: const Icon(CupertinoIcons.link_circle), selectedIcon: const Icon(CupertinoIcons.link_circle_fill), label: translateEng('Links')),
            NavigationDestination(icon: const Icon(Icons.info_outlined), selectedIcon: const Icon(Icons.info), label: translateEng('About')),
          ],
        ),
      ),
    );
  }

  Container? showCourseInfo(Subject subject) {

    String? name;
    if (subject.customName.isEmpty) {
      if (subject.classCode.contains("(")) {
        name = Main.classcodes[subject.classCode.substring(0, subject.classCode.indexOf("("))];
      } else {
        name = Main.classcodes[subject.classCode];
      }
    } else {
    name = subject.customName;
    }

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

    showDialog(context: context,
      builder: (context) => AlertDialog(
        title: Text(subject.classCode),
        content: Builder(
            builder: (context) {
              return Container(
                  height: height * 0.4,
                  child: Scrollbar( // Just to make the scrollbar viewable
                    thumbVisibility: true,
                    child: ListView(
                      children: [
                        ListTile(
                          title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Expanded(
                                child: Text(name!),
                            ),
                          ]),
                          onTap: null,
                        ),
                        ListTile(
                          title: Row(children: [
                            classrooms.isNotEmpty ? const Icon(CupertinoIcons.placemark_fill) : Container(width: 0),
                            Expanded(child: Container(padding: EdgeInsets.fromLTRB(width * 0.05, 0, 0, 0), child: Text(classrooms))),
                          ]),
                          onTap: null,
                        ),
                        ListTile(
                          title: Row(
                              children: [
                                teachers.isNotEmpty ? const Icon(CupertinoIcons.group_solid) : Container(),
                                Expanded(child: Container(padding: EdgeInsets.fromLTRB(width * 0.05, 0, 0, 0), child: Text(teachers))),
                          ]),
                          onTap: null,
                        ),
                        ListTile(
                          title: Row(
                              children: [
                                departments.isNotEmpty ? const Icon(CupertinoIcons.building_2_fill) : Container(),
                                Expanded(child: Container(padding: EdgeInsets.fromLTRB(width * 0.05, 0, 0, 0), child: Text(departments))),
                          ]),
                          onTap: null,
                        ),
                      ],
                    ),
                  ));
            }
        ),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); }, child: Text(translateEng("OK"))),
        ],
      ),
    );
        return null;

  }

  List<CollisionData> findCourseCollisions() {

    List<CollisionData> collisions = [];

    Main.schedules[Main.currentScheduleIndex].scheduleCourses.forEach((course) {

      for (int i = 0 ; i < course.subject.days.length ; i++) {
        for (int j = 0 ; j < course.subject.days[i].length ; j++) {
          int day = course.subject.days[i][j], bgnHour = course.subject.bgnPeriods[i][j], hours = course.subject.hours[i];
          print("Searching for bgnPeriods b/w $bgnHour and ${bgnHour + hours} for the course ${course.subject.classCode}");

          Main.schedules[Main.currentScheduleIndex].scheduleCourses.forEach((courseToComp) {

            for (int i_ = 0 ; i_ < courseToComp.subject.days.length ; i_++) {
              for (int j_ = 0 ; j_ < courseToComp.subject.days[i_].length ; j_++) {
                print("Doing indices: $i_ and $j_");
                if (courseToComp.subject.days[i_][j_] == day) {
                  if (!courseToComp.subject.isEqual(course.subject) &&
                      (courseToComp.subject.bgnPeriods[i_][j_] >= bgnHour && courseToComp.subject.bgnPeriods[i_][j_] < (bgnHour + hours))
                  || ((courseToComp.subject.bgnPeriods[i_][j_] + courseToComp.subject.hours[i_]) >= bgnHour && (courseToComp.subject.bgnPeriods[i_][j_] + courseToComp.subject.hours[i_]) < (bgnHour + hours))) {
                    // Check if it was not already added before:
                    bool isFound = false;
                    collisions.forEach((col) {
                      if ((col.subjects[0].isEqual(course.subject) || col.subjects[0].isEqual(courseToComp.subject))
                          && (col.subjects[1].isEqual(course.subject) || col.subjects[1].isEqual(courseToComp.subject))
                          && (col.subjects[col.subjects.length-1].isEqual(course.subject) || col.subjects[col.subjects.length-1].isEqual(courseToComp.subject))) {
                        if (col.i.contains(i) && col.i.contains(i_) && col.j.contains(j) && col.j.contains(j_)) { // if both subjects with their i's and j's were found, then don't add them..
                          isFound = true;
                        }
                      } else { // collisions of 3, if one subject with its i's and j's, then add the other subject
                        // ((col.subjects[0].isEqual(course.subject) || col.subjects[1].isEqual(course.subject) || col.subjects[col.subjects.length-1].isEqual(course.subject)) && col.i.contains(i) && col.j.contains(j))
                        //   || ((col.subjects[0].isEqual(courseToComp.subject) || col.subjects[1].isEqual(courseToComp.subject) || col.subjects[col.subjects.length-1].isEqual(courseToComp.subject)) && col.i.contains(i_) && col.j.contains(j_))
                        if (true) {
                          if ((isCollidingWith3(course.subject, i, j, col)) || (isCollidingWith3(courseToComp.subject, i_, j_, col))) {
                          //print("A collision of 3 subjects was found between ${course.subject.classCode} and ${courseToComp.subject.classCode}!");
                              if ((col.subjects[0].isEqual(course.subject) ||
                                col.subjects[1].isEqual(course.subject)
                                || col.subjects[col.subjects.length - 1].isEqual(
                                    course
                                      .subject))) { // check if course exists or not, if it does, then add courseToComp
                              col.subjects.add(courseToComp.subject);
                              col.i.add(i_);
                              col.j.add(j_);
                            } else { // otherwise add course:
                              col.subjects.add(course.subject);
                              col.i.add(i);
                             col.j.add(j);
                            }
                              col.isDrawn.add(false);
                              isFound = true;
                          } else {
                            print("Potential col of 2 b/w ${course.subject.classCode} and ${courseToComp.subject.classCode}!!!");
                            ;
                          }

                        }
                      }
                    });

                    if (!isFound) {
                      print("Collision found b/w ${course.subject.classCode} N ${courseToComp.subject.classCode}");
                      collisions.add(CollisionData(subjects: [course.subject, courseToComp.subject], i: [i, i_], j: [j, j_]));
                      return ;
                    }

                  }
                }
              }
            }

          });

        }

      }

    });

    // TODO: Fix this bug, or maybe leave it it might be fine: If there is a collision of 3 courses, they are added multiple times:
    // Find all the collisions of the subjects of size 3 or more, and refine them:
    // When you find them, find the 3 unique values of each list of subjects, i and j lists, and store them solely in the same order:

    print("Beginning ther refinement process of collisions: (only for 3 cols) /");
    for (int i = 0 ; i < collisions.length ; i++) {

      if (collisions[i].subjects.length >= 3) {

        print("A 3 collision was found: ${collisions[i].subjects[0].classCode} N ${collisions[i].subjects[1].classCode} N ${collisions[i].subjects[2].classCode}");
        collisions[i].is3Col = true;
        for (int j = 3 ; j < collisions[i].subjects.length ; ) {
          collisions[i].subjects.removeAt(j);
          collisions[i].i.removeAt(j);
          collisions[i].j.removeAt(j);
          collisions[i].isDrawn.removeAt(j);
        }

      }

    }

    // TODO: Now, take all the cols of 3 and make sure that they all collide together, if not, then delete the one that does not collide with both and reset isColOf3 to false:
    ;

    return collisions;

  }

  bool isCollidingWith3(Subject subjectToCheck, int i, int j,  CollisionData col) {

    // STEP 1: Find all the values used to check up the possible collision:
    int day = subjectToCheck.days[i][j], bgnHour = subjectToCheck.bgnPeriods[i][j], hours = subjectToCheck.hours[i];

    // STEP 2: Finf out if the values above inside each values of the col.subjects, if not return false, if yes then continue checking:
    for (int k = 0 ; k < col.subjects.length ; k++) {
      if (!(subjectToCheck.isEqual(col.subjects[k]))) {
        i = col.i[k];
        j = col.j[k];
        if (!((col.subjects[k].days[i][j] == day) &&
            ((bgnHour >= col.subjects[k].bgnPeriods[i][j] && bgnHour < (col.subjects[k].bgnPeriods[i][j] + col.subjects[k].hours[i]))
            || ((bgnHour + hours) >= col.subjects[k].bgnPeriods[i][j] && (bgnHour + hours) < (col.subjects[k].bgnPeriods[i][j] + col.subjects[k].hours[i]))))) {
          // if they dont collide, then do this:
          return false;
        }
      }
    }

    return true;

  }

  bool isMoreThan3Cols() { // Returns true if there are more than 3 collisions inside the scheduledCourses List:
    // this function should be called every time we edit on the schedule:

    //TODO:
    return false;

  }

}