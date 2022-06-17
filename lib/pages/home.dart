import 'package:ders_program_test/language/dictionary.dart';
import 'package:ders_program_test/others/subject.dart';
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
  Icon icon = const Icon(Icons.date_range_outlined);
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

      Main.currentSchedule.scheduleCourses.forEach((course) {
      colorIndex++;
      for (int i = 0; i < course.subject.days.length; i++) {
        for (int j = 0; j < course.subject.days[i].length; j++) {
          bool isCol = false;
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
                drawingIndex = atIndex;
                colSize = col.subjects.length;
                print("${course.subject
                    .classCode} is being drawn collisioned!\nindex of $atIndex with size $colSize");
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
                      EdgeInsets.all(0.01 * width)),
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
                leading: const Icon(Icons.next_plan_outlined),
              ),
              SizedBox(height: height * 0.01),
              ListTile(
                onTap: () {
                  ;
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
                            child: Text(translateEng("NOT NOW")),
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
                translateEng("Last Updated") + "    ${Main.semesters[0].lastUpdate.hour}:${"${Main.semesters[0].lastUpdate.minute} " + Main.semesters[0].lastUpdate.day.toString() + "/" + Main.semesters[0].lastUpdate.month.toString()}",
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(translateEng("Light  ")),
                  Checkbox(value: Main.theme == ThemeMode.light, onChanged: (bool? newVal) {
                    setState(() {Main.theme = ThemeMode.light;Main.saveSettings();});
                  }),
                  Text(translateEng("Dark  ")),
                  Checkbox(value: Main.theme == ThemeMode.dark, onChanged: (bool? newVal) {
                    setState(() {Main.theme = ThemeMode.dark;Main.saveSettings();});
                  })
                ],)
            ],
          ),
        ],
      );
    }

    Widget? linksPage;
    if (pageIndex == 3) {
      linksPage = ListView(
        children: [
          ListTile(
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
          ListTile(
            title: Text(translateEng("School's Schedules")),
            onTap: () async {
              const url = 'https://www.atilim.edu.tr/en/dersprogrami';
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
            NavigationDestination(icon: icon, selectedIcon: const Icon(Icons.date_range), label: translateEng('Schedule')),
            NavigationDestination(icon: Image.asset("lib/icons/tools_outlines.png", width: IconTheme.of(context).size!), selectedIcon: Image.asset("lib/icons/tools_filled.png", width: IconTheme.of(context).size!), label: translateEng('Tools')),
            NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: translateEng('Settings')),
            NavigationDestination(icon: const Icon(Icons.dataset_linked_outlined), selectedIcon: const Icon(Icons.link), label: translateEng('Links')),
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
                          title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ // name!
                            Expanded(child: RichText(text: TextSpan(
                              style: Theme.of(context).textTheme.bodyText2,
                              children: [
                                TextSpan(text: translateEng("Name: "), style: AppThemes.headerStyle),
                                TextSpan(text: name!),
                              ]
                            ))),
                          ]),
                          onTap: null,
                        ),
                        ListTile(
                          title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Expanded(child: RichText(text: TextSpan(
                                style: Theme.of(context).textTheme.bodyText2,
                                children: [
                                  TextSpan(text: translateEng("Classrooms: "), style: AppThemes.headerStyle),
                                  TextSpan(text: classrooms),
                                ]
                            ))),
                          ]),
                          onTap: null,
                        ),
                        ListTile(
                          title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Expanded(child: RichText(text: TextSpan(
                                style: Theme.of(context).textTheme.bodyText2,
                                children: [
                                  TextSpan(text: translateEng("Teachers: "), style: AppThemes.headerStyle),
                                  TextSpan(text: teachers),
                                ]
                            ))),
                          ]),
                          onTap: null,
                        ),
                        ListTile(
                          title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Expanded(child: RichText(text: TextSpan(
                                style: Theme.of(context).textTheme.bodyText2,
                                children: [
                                  TextSpan(text: translateEng("Departments: "), style: AppThemes.headerStyle),
                                  TextSpan(text: departments),
                                ]
                            ))),
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

    Main.currentSchedule.scheduleCourses.forEach((course) {

      for (int i = 0 ; i < course.subject.days.length ; i++) {
        for (int j = 0 ; j < course.subject.days[i].length ; j++) {
          int day = course.subject.days[i][j], bgnHour = course.subject.bgnPeriods[i][j], hours = course.subject.hours[i];
          print("Searching for bgnPeriods b/w $bgnHour and ${bgnHour + hours} for the course ${course.subject.classCode}");

          Main.currentSchedule.scheduleCourses.forEach((courseToComp) {

            for (int i_ = 0 ; i_ < courseToComp.subject.days.length ; i_++) {
              for (int j_ = 0 ; j_ < courseToComp.subject.days[i_].length ; j_++) {
                print("Doing indices: $i_ and $j_");
                if (courseToComp.subject.days[i_][j_] == day) { /////// TODO:
                  print("Same day with ${courseToComp.subject.bgnPeriods[i_][j_]}");
                  if (!courseToComp.subject.isEqual(course.subject) && courseToComp.subject.bgnPeriods[i_][j_] >= bgnHour && courseToComp.subject.bgnPeriods[i_][j_] < (bgnHour + hours)) {
                    // Check if it was not already added before:
                    bool isFound = false;
                    collisions.forEach((col) {
                      if (col.subjects[0].isEqual(course.subject) || col.subjects[0].isEqual(courseToComp.subject)) {
                        if (col.subjects[1].isEqual(course.subject) || col.subjects[1].isEqual(courseToComp.subject)) {
                          if (col.i.contains(i) && col.i.contains(i_) && col.j.contains(j) && col.j.contains(j_)) {
                            isFound = true;
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

    return collisions;

  }

}