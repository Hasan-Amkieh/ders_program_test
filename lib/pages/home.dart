import 'package:ders_program_test/language/dictionary.dart';
import 'package:ders_program_test/subject.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'package:ders_program_test/others/departments.dart';
import 'package:get_storage/get_storage.dart';

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

  @override
  Widget build(BuildContext context) {

    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    width = (window.physicalSize / window.devicePixelRatio).width;
    height = (window.physicalSize / window.devicePixelRatio).height;

    double colWidth = (width) / 7; // 6 days and a col for the clock
    double rowHeight = (height * 1) / 11; // 10 for the lock and one for the empty box // 91 percent because of the horizontal borders

    Color headerColor = Colors.blue.shade700;
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
                Container(child: Center(child: Text('Mon', style: headerTxtStyle)), height: rowHeight, width: colWidth,),
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
                Container(child: Center(child: Text('Tue', style: headerTxtStyle,)), height: rowHeight, width: colWidth),
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
                Container(child: Center(child: Text('Wed', style: headerTxtStyle,)), height: rowHeight, width: colWidth),
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
                Container(child: Center(child: Text('Thur', style: headerTxtStyle,)), height: rowHeight, width: colWidth),
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
                Container(child: Center(child: Text('Fri', style: headerTxtStyle,)), height: rowHeight, width: colWidth),
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
                Container(child: Center(child: Text('Sat', style: headerTxtStyle,)), height: rowHeight, width: colWidth),
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
                        title: Row(children: [Expanded(child: Text("Name: MATH151(1) - Calculus 1"))]),
                        onTap: null,
                      ),
                      ListTile(
                        title: Row(children: [Expanded(child: Text("Classroom: B1029"))]),
                        onTap: null,
                      ),
                      ListTile(
                        title: Row(children: [Expanded(child: Text("Teachers: Shihan Bin Zahrawi"))]),
                        onTap: null,
                      ),
                      ListTile(
                        title: Row(children: [Expanded(child: Text("Departments: CMPE 1 Reg."))]),
                        onTap: null,
                      ),
                    ],
                  ),
                ));
            }
          ),
        actions: [
          TextButton(onPressed: () => print("To do this part in future"), child: Text("EDIT"))
        ],
      ),
    );

    Subject emptySubject = Subject(classCode: "classCode", departments: ["departments"], teacherCodes: [["teacherCodes"]], hours: [1, 2, 3], bgnPeriods: [1,2, 3], days: [1,2 ,3], classrooms: [[]]);

    // NOTE: This is how I add courses:
    coursesList.add(Positioned(child: TextButton(onPressed: () => showCourseInfo(emptySubject), child: Text("MATH152"), style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red.shade800))), width: colWidth, height: rowHeight * 2, left: colWidth, top: rowHeight + 2 * (1 - 1)));
    coursesList.add(Positioned(child: TextButton(onPressed: () => showCourseInfo(emptySubject), child: Text("PHYS102"), style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange.shade800))), width: colWidth, height: rowHeight,left: colWidth * 2, top: rowHeight * 3 + 2 * (3 - 1)));
    coursesList.add(Positioned(child: TextButton(onPressed: () => showCourseInfo(emptySubject), child: Text("CMPE134"), style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.pink.shade800))), width: colWidth, height: rowHeight,left: colWidth * 3, top: rowHeight * 6 + 2 * (6 - 1)));

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

    // NOTE: This is how you add courses to the schedule:
    ;

    Widget servicesPage = ListView(
      children: [
        ListTile(
          onTap: () {
            ;
          },
          title: Text('Add/Delete Courses'),
          subtitle: Text('Edit the courses on the current schedule'),
          leading: Icon(Icons.edit),
        ),
        ListTile(
          onTap: () {
            // TODO:
            ;
          },
          title: Text('Scheduler'),
          subtitle: Text('Choose the courses with the sections with specific options, then choose your appropriate schedule'),
          leading: Icon(Icons.calendar_today),
        ),
        ListTile(
          onTap: () {
            // TODO:
            ;
          },
          title: Text('Choose Made-up Plans'),
          subtitle: Text('These plans are provided by the university'),
          leading: Icon(Icons.next_plan_outlined),
        ),
        ListTile(
          onTap: () {
            ;
          },
          title: Text('Search for Courses'),
          subtitle: Text('Search for courses using its name, classroom number, teacher or department'),
          leading: Icon(Icons.search),
        ),
        ListTile(
          onTap: () {
            ;
          },
          title: Text('Saved Schedules'),
          subtitle: Text('You can save schedules and set them back again'),
          leading: Icon(Icons.edit_calendar),
        ),
      ],
    );

    /*
    * ropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
        });
      },
      items: <String>['One', 'Two', 'Free', 'Four']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );*/

    Widget settingsPage = ListView(
      padding: EdgeInsets.all(width * 0.02),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Language"),
            SizedBox(width: width * 0.1,),
            DropdownButton<String>(
              value: Main.language,
              items: langs.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem(value: value, child:
                  TextButton.icon(onPressed: null, icon: Image.asset("lib/icons/" + value + ".png"), label: Text(value))
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  Main.language = newValue!;
                  // TODO: Restart the whole app! It is mandatory, restart without asking
                  ;
                });
              },
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Faculty"),
            SizedBox(width: width * 0.1,),
            DropdownButton<String>(
              value: Main.faculty,
              items: faculties.keys.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem(value: value, child: Text(value),);
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  Main.faculty = newValue!;
                  Main.department = faculties[Main.faculty]?.keys.elementAt(0) as String;
                });
                },
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Department"),
            SizedBox(width: width * 0.1,),
            DropdownButton<String>(
              value: Main.department,
              items: faculties[Main.faculty]?.keys.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem(value: value, child: Row(children: [
                  Text(value + "  "), Text(faculties[Main.faculty]![value] as String, style: TextStyle(fontSize: 10))
                ],),);
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  Main.department = newValue!;
                });
              },
            )
          ],
        )
      ],
    );

    Widget aboutPage = ListView(
      children: [
        ListTile(
          title: Text('Donate me'),
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
          title: Text("School's Schedules"),
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
            NavigationDestination(icon: Icon(Icons.date_range_outlined), selectedIcon: Icon(Icons.date_range), label: 'Schedule'),
            NavigationDestination(icon: Icon(Icons.add_box_outlined), selectedIcon: Icon(Icons.add_box), label: 'Tools'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
            NavigationDestination(icon: Icon(Icons.dataset_linked_outlined), selectedIcon: Icon(Icons.link), label: 'Links'),
            NavigationDestination(icon: Icon(Icons.info_outlined), selectedIcon: Icon(Icons.info), label: 'About'),
          ],
        ),
      ),
    );
  }

}