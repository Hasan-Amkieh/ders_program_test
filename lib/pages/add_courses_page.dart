import "dart:io" show Platform;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

import '../language/dictionary.dart';
import '../main.dart';
import '../others/departments.dart';
import '../others/subject.dart';
import '../widgets/searchwidget.dart';

class AddCoursesPage extends StatefulWidget {

  @override // TODO: Implement this in EVERY PAGE WIDGET!
  Key key = Key("AddCoursesPage"); // This solved an error

  @override
  State<StatefulWidget> createState() {
    return AddCoursesPageState();
  }

}

class AddCoursesPageState extends State<AddCoursesPage> {

  late double width, height;
  static const Duration duration = Duration(milliseconds: 300);
  String depToSearch = translateEng("All");
  String lastDep = translateEng("All");
  List<String> deps = faculties[Main.faculty]!.keys.toList();

  static bool isForScheduler = false;

  List<Subject> subjectsWithoutSecs = []; // subjects without their sections, only used for the scheduler

  String query = "";

  List<Subject> subjects = Main.facultyData.subjects;
  List<Subject> subjectsOfDep = Main.facultyData.subjects;

  late List<Subject> subjectsWithoutSecsOrigin;

  @override
  void initState() {

    super.initState();

    if (!isForScheduler) {
      Main.coursesToAdd.clear();
    } else {
      bool isAdded = false;

      for (Subject sub in subjects) {
        isAdded = false;
        for (Subject s in subjectsWithoutSecs) {
          if (s.getClassCodeWithoutSectionNumber() == sub.getClassCodeWithoutSectionNumber()) {
            isAdded = true;
            break;
          }
        }
        if (!isAdded) {
          subjectsWithoutSecs.add(Subject(classCode: sub.getClassCodeWithoutSectionNumber(), customName: sub.getNameWithoutSection(), departments: sub.departments, teacherCodes: sub.teacherCodes, hours: sub.hours, bgnPeriods: sub.bgnPeriods, days: sub.days, classrooms: sub.classrooms));
        }
      }
      subjectsOfDep = subjectsWithoutSecs;
      subjectsWithoutSecsOrigin = subjectsWithoutSecs;
    }

    deps.add(depToSearch);

  }

  @override
  Widget build(BuildContext context) {

    width = (window.physicalSize / window.devicePixelRatio).width;
    height = (window.physicalSize / window.devicePixelRatio).height;

    if (depToSearch != translateEng("All") && lastDep != depToSearch) {
      lastDep = depToSearch;
      subjectsOfDep = Main.facultyData.subjects.where((element) {

        return element.departments.toString().contains(depToSearch);

      }).toList();
      search(query); // Because the subjects list are now reset
    }
    else if (depToSearch == translateEng("All") && lastDep != depToSearch) {
      lastDep = depToSearch;
      subjectsOfDep = Main.facultyData.subjects;
      search(query); // Because the subjects list are now reset
    }

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight((MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * (Platform.isWindows ? 0.05 : 0.1)),
          child: AppBar(backgroundColor: Main.appTheme.headerBackgroundColor)
      ),
      backgroundColor: Main.appTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: height * 0.02, horizontal: width * 0.05),
          child: Column(
            children: [
              isForScheduler ? Container() : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(translateEng("Show courses only for"), style: TextStyle(color: Main.appTheme.titleTextColor)),
                  DropdownButton<String>(
                    dropdownColor: Main.appTheme.scaffoldBackgroundColor,
                    value: depToSearch,
                    items: deps.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem(value: value, child: Text(value, style: TextStyle(color: Main.appTheme.titleTextColor))
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        depToSearch = newValue!;
                      });
                    },
                  )
                ],
              ),

              SizedBox(
                height: (MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * (Platform.isWindows ? 0.1 : 0.18),
                  child: SearchWidget(text: query, onChanged: search, hintText: translateEng("course code or name"))
              ),

              Expanded(
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: isForScheduler ? subjectsWithoutSecs.length : subjects.length, itemBuilder: (context, index) {
                    return buildTile(context, index);
                  })
              ),
            ],
          ),
        ),
      ),
    );

  }

  ListTile buildTile(context, index) {

    Subject subject = isForScheduler ? subjectsWithoutSecs[index] : subjects[index];
    String name = subject.customName;
    bool isInside = false;

    //print("current schedule is: ${Main.schedules[Main.currentScheduleIndex].scheduleCourses}");
    if (!isForScheduler) {
      for (Course crs in Main.schedules[Main.currentScheduleIndex].scheduleCourses) {
        if (crs.subject.classCode == subject.classCode) {
          isInside = true;
          break;
        }
      }
    }
    if (!isInside) {
      for (Subject sub in Main.coursesToAdd) {
        if (sub.classCode == subject.classCode) {
          isInside = true;
          break;
        }
      }
    }

    return ListTile(
      title: Text(subject.classCode, style: TextStyle(color: Main.appTheme.titleTextColor)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isForScheduler ? Container() : Text(
            name,
            style: TextStyle(color: Main.appTheme.titleTextColor),
          ),
          (isInside || subject.days.isEmpty) ? SizedBox(height: height * 0.01) : Container(),
          Row(
            children: [
              isInside ? const Icon(CupertinoIcons.add_circled_solid, color: Colors.blue) : Container(),
              (subject.days.isEmpty && isInside) ? SizedBox(width: width * 0.02) : Container(),
              subject.days.isEmpty ? const Icon(CupertinoIcons.time_solid, color: Colors.red) : Container(),
            ],
          ),
        ],
      ),
      onTap: () {
        if (subject.days.isNotEmpty || !isForScheduler) {
          if (!isInside) {
            setState(() {
              Main.coursesToAdd.add(subject);
            });
          }
          showToast(
            translateEng(isInside ? "${subject.classCode} " + translateEng("is already in the schedule")
                : "${subject.classCode} " + translateEng("was added to the schedule")),
            duration: const Duration(milliseconds: 1500),
            position: ToastPosition.bottom,
            backgroundColor: Colors.blue.withOpacity(0.8),
            radius: 100.0,
            textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
          );
        } else {
          showToast(
            translateEng("The course has no time data"),
            duration: const Duration(milliseconds: 1500),
            position: ToastPosition.bottom,
            backgroundColor: Colors.red.withOpacity(0.8),
            radius: 100.0,
            textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
          );
        }
      },
    );

  }

  void search(String query) {

    final subjects = subjectsOfDep.where((subject) {

      String name = subject.getNameWithoutSection();

      query = query.toLowerCase();
      name = name.toLowerCase();

      return name.contains(query);

    }).toList();

    setState(() {
      this.query = query;
      if (isForScheduler) {
        subjectsWithoutSecs = subjects;
      } else {
        this.subjects = subjects;
      }
    });

  }

}

