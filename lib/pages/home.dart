import 'package:ders_program_test/language/dictionary.dart';
import 'package:ders_program_test/others/subject.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:ders_program_test/others/departments.dart';
import 'package:flutter/services.dart';
import 'package:restart_app/restart_app.dart';

import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

List<Color> coursesColorsLight = [ // light mode
  const Color.fromRGBO(128, 105, 103, 1.0),
  const Color.fromRGBO(6, 153, 127, 1.0),
  const Color.fromRGBO(6, 102, 153, 1.0),
  const Color.fromRGBO(180, 6, 60, 1.0),
  const Color.fromRGBO(10, 166, 62, 1.0),
  const Color.fromRGBO(156, 42, 133, 1.0),
  const Color.fromRGBO(145, 140, 78, 1.0),
  const Color.fromRGBO(212, 196, 0, 1.0),
  const Color.fromRGBO(104, 102, 217, 1.0),
  const Color.fromRGBO(29, 120, 117, 1.0),
];

class Home extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }

}

class HomeState extends State<Home> {

  int pageIndex = 0;

  TextStyle headerTxtStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
  late double width;
  late double height;
  Icon icon = Icon(Icons.date_range_outlined);

  @override
  void initState() {

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.blue,
    ));

  }

  @override
  Widget build(BuildContext context) {

    width = (window.physicalSize / window.devicePixelRatio).width;
    height = (window.physicalSize / window.devicePixelRatio).height;

    isLangEng = Main.language == "English";

    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    double colWidth = (width) / 7; // 6 days and a col for the clock
    double rowHeight = (height * 1) / 11; // 10 for the lock and one for the empty box // 91 percent because of the horizontal borders

    Color headerColor = Colors.blue;
    Color emptyCellColor = Colors.white;
    Color horizontalBorderColor = Colors.blueGrey.shade200;
    Container emptyCell = Container(decoration: BoxDecoration(color: emptyCellColor, border: Border.symmetric(horizontal: BorderSide(color: horizontalBorderColor, width: 1))), child: SizedBox(width: colWidth, height: rowHeight,));


    List<Widget> coursesList = [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: headerColor,
            child: Column( // Headers
              children: [
                SizedBox(width: colWidth, height: rowHeight),
                Container(child: Center(child: Text('9:30', style: headerTxtStyle, )), height: rowHeight),
                Container(child: Center(child: Text('10:30', style: headerTxtStyle,)), height: rowHeight),
                Container(child: Center(child: Text('11:30', style: headerTxtStyle,)), height: rowHeight),
                Container(child: Center(child: Text('12:30', style: headerTxtStyle,)), height: rowHeight),
                Container(child: Center(child: Text('13:30', style: headerTxtStyle,)), height: rowHeight),
                Container(child: Center(child: Text('14:30', style: headerTxtStyle,)), height: rowHeight),
                Container(child: Center(child: Text('15:30', style: headerTxtStyle,)), height: rowHeight),
                Container(child: Center(child: Text('16:30', style: headerTxtStyle,)), height: rowHeight),
                Container(child: Center(child: Text('17:30', style: headerTxtStyle,)), height: rowHeight),
                Container(child: Center(child: Text('18:30', style: headerTxtStyle,)), height: rowHeight + height * 0.04),
              ],
            ),
          ),
          Container(
            color: headerColor,
            child: Column( // Headers
              children: [
                Container(child: Center(child: Text(translateEng('Mon'), style: headerTxtStyle)), height: rowHeight, width: colWidth,),
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
                Container(child: Center(child: Text(translateEng('Tue'), style: headerTxtStyle,)), height: rowHeight, width: colWidth),
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
                Container(child: Center(child: Text(translateEng('Wed'), style: headerTxtStyle,)), height: rowHeight, width: colWidth),
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
                Container(child: Center(child: Text(translateEng('Thur'), style : headerTxtStyle)), height: rowHeight, width: colWidth),
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
                Container(child: Center(child: Text(translateEng('Fri'), style: headerTxtStyle)), height: rowHeight, width: colWidth),
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
                Container(child: Center(child: Text(translateEng('Sat'), style: headerTxtStyle)), height: rowHeight, width: colWidth),
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

    // TODO:
    // NOTE: This is the AlertDialog that is used for the showing the course info: 
    var showCourseInfo = (Subject subject) => showDialog(context: context,
        builder: (context) => AlertDialog(
          title: Text("MATH151(1)"),
          content: Builder(
            builder: (context) {
              return Container(
                height: height * 0.4,
                child: Scrollbar( // Just to make the scrollbar viewable
                  thumbVisibility: true,
                  child: ListView(
                    children: [
                      ListTile(
                        title: Row(children: [Expanded(child: Text(translateEng("Name: ") + "MATH151(1) - Calculus 1"))]),
                        onTap: null,
                      ),
                      ListTile(
                        title: Row(children: [Expanded(child: Text(translateEng("Classrooms: ") + "B1029"))]),
                        onTap: null,
                      ),
                      ListTile(
                        title: Row(children: [Expanded(child: Text(translateEng("Teachers: ") + "Shihan Bin Zahrawi"))]),
                        onTap: null,
                      ),
                      ListTile(
                        title: Row(children: [Expanded(child: Text(translateEng("Departments: ") + "CMPE 1 Reg."))]),
                        onTap: null,
                      ),
                    ],
                  ),
                ));
            }
          ),
        actions: [
          TextButton(onPressed: () => print("To do this part in future"), child: Text(translateEng("EDIT")))
        ],
      ),
    );

    Subject emptySubject = Subject(classCode: "classCode", departments: ["departments"], teacherCodes: [["teacherCodes"]], hours: [1, 2, 3], bgnPeriods: [1,2, 3], days: [1,2 ,3], classrooms: [[]]);

    // NOTE: This is how I add courses:
    /*
    coursesList.add(Positioned(child: TextButton(onPressed: () => showCourseInfo(emptySubject), child: Text("MATH152"), style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red.shade800))), width: colWidth, height: rowHeight * 2, left: colWidth, top: rowHeight + 2 * (1 - 1)));
    coursesList.add(Positioned(child: TextButton(onPressed: () => showCourseInfo(emptySubject), child: Text("PHYS102"), style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange.shade800))), width: colWidth, height: rowHeight,left: colWidth * 2, top: rowHeight * 3 + 2 * (3 - 1)));
    coursesList.add(Positioned(child: TextButton(onPressed: () => showCourseInfo(emptySubject), child: Text("CMPE134"), style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.pink.shade800))), width: colWidth, height: rowHeight,left: colWidth * 3, top: rowHeight * 6 + 2 * (6 - 1)));
    */

    Widget schedulePage = Stack(
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
        ]);

    Widget servicesPage = Container(
      padding: EdgeInsets.fromLTRB(0.02 * width, 0.05 * width, 0.02 * width, 0.05 * width),
      child: ListView(
      children: [
        ListTile(
          onTap: () {
            Navigator.pushNamed(context, "/home/editcourses");
          },
          title: Text(translateEng('Edit Courses')),
          subtitle: Text(translateEng('Add and edit the courses on the current schedule')),
          leading: Icon(Icons.edit),
        ),
        ListTile(
          onTap: () {
            Navigator.pushNamed(context, "/home/searchpage");
          },
          title: Text(translateEng('Search for Courses')),
          subtitle: Text(translateEng('Search for courses using its name, classroom number, teacher or department')),
          leading: Icon(Icons.search),
        ),
        ListTile(
          onTap: () {
            Navigator.pushNamed(context, "/home/favcourses");
          },
          title: Text(translateEng('Favourite Courses')),
          leading: Icon(Icons.star_border),
        ),
        ListTile(
          onTap: () {
            // TODO:
            ;
          },
          title: Text(translateEng('Scheduler')),
          subtitle: Text(translateEng('Choose the courses with the sections with specific options, then choose your appropriate schedule') + '\n'),
          leading: Icon(Icons.calendar_today),
        ),
        ListTile(
          onTap: () {
            // TODO:
            ;
          },
          title: Text(translateEng('Choose Made-up Plans')),
          subtitle: Text(translateEng('These plans are provided by the university')),
          leading: Icon(Icons.next_plan_outlined),
        ),
        ListTile(
          onTap: () {
            ;
          },
          title: Text(translateEng('Saved Schedules')),
          subtitle: Text(translateEng('You can save schedules and set them back again')),
          leading: Icon(Icons.edit_calendar),
        ),
      ],
    ));

    Widget settingsPage = ListView(
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
                  height: 0.08 * height,
                  child: FloatingActionButton(child: const Icon(Icons.remove),onPressed: () {
                    setState(() {
                      if (Main.hourUpdate == 12) return;
                      Main.hourUpdate--;
                      Main.saveSettings();
                    });
                  }),
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
                  height: 0.08 * height,
                  child: FloatingActionButton(child: const Icon(Icons.add), onPressed: () {
                    setState(() {
                      if (Main.hourUpdate == 24) return;
                      Main.hourUpdate++;
                      Main.saveSettings();
                    });
                  }),
                )
              ],
            )
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

    Widget aboutPage = ListView(
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

    Widget linksPage = ListView(
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

    List<Widget> pages = [
      schedulePage,
      servicesPage,
      settingsPage,
      linksPage,
      aboutPage,
    ];

    return Scaffold(
      body: SafeArea(
          child: pages[pageIndex]
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: const NavigationBarThemeData(
            indicatorColor: Colors.teal
        ),
        child: NavigationBar(
          backgroundColor: Colors.teal,
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
            NavigationDestination(icon: icon, selectedIcon: Icon(Icons.date_range), label: translateEng('Schedule')),
            NavigationDestination(icon: Image.asset("lib/icons/tools_outlines.png", width: IconTheme.of(context).size!), selectedIcon: Image.asset("lib/icons/tools_filled.png", width: IconTheme.of(context).size!), label: translateEng('Tools')),
            NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: translateEng('Settings')),
            NavigationDestination(icon: Icon(Icons.dataset_linked_outlined), selectedIcon: Icon(Icons.link), label: translateEng('Links')),
            NavigationDestination(icon: Icon(Icons.info_outlined), selectedIcon: Icon(Icons.info), label: translateEng('About')),
          ],
        ),
      ),
    );
  }

}