import "dart:io" show Platform;
import 'dart:ui';

import 'package:Atsched/others/university.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

import '../language/dictionary.dart';
import '../main.dart';
import '../others/subject.dart';
import '../widgets/emptycontainer.dart';
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
  List<String> deps = University.getFacultyDeps(Main.faculty).keys.toList();

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
          if (s.getCourseCodeWithoutSectionNumber() == sub.getCourseCodeWithoutSectionNumber()) {
            isAdded = true;
            break;
          }
        }
        if (!isAdded) {
          subjectsWithoutSecs.add(Subject(courseCode: sub.getCourseCodeWithoutSectionNumber(), customName: sub.getNameWithoutSection(), departments: sub.departments, teacherCodes: sub.teacherCodes, hours: sub.hours, bgnPeriods: sub.bgnPeriods, days: sub.days, classrooms: sub.classrooms));
        }
      }
      subjectsOfDep = subjectsWithoutSecs;
      subjectsWithoutSecsOrigin = subjectsWithoutSecs;
    }

    deps.add(depToSearch);

    iconSize = Icon(Icons.info_outline, color: Colors.blue).size ?? ((window.physicalSize / window.devicePixelRatio).width) * 0.025;

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

    subCountAddedCrs = 0;
    subCountCrs = 0;

    var scrollController = ScrollController();
    
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
              isForScheduler ? Container() : (
                University.areDepsSupported() ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(translateEng("Show courses only for"), style: TextStyle(color: Main.appTheme.titleTextColor)),
                    DropdownButton<String>(
                      underline: EmptyContainer(),
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
                ) : EmptyContainer()
              ),

              SizedBox(
                height: (MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * (Platform.isWindows ? 0.1 : 0.18),
                  child: SearchWidget(text: query, onChanged: search, hintText: translateEng("course code or name"))
              ),

              Expanded(
                  child: RawScrollbar(
                    controller: scrollController,
                    crossAxisMargin: 0.0,
                    trackVisibility: true,
                    thumbVisibility: true,
                    thumbColor: Colors.blueGrey,
                    // trackColor: Colors.redAccent.shade700,
                    trackBorderColor: Colors.white,
                    radius: const Radius.circular(20),
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          controller: scrollController,
                          shrinkWrap: true,
                          itemCount: isForScheduler ? subjectsWithoutSecs.length : subjects.length, itemBuilder: (context, index) {
                        return buildTile(context, index);
                      }),
                    ),
                  )
              ),
            ],
          ),
        ),
      ),
    );

  }

  int subCountCrs = 0;
  int subCountAddedCrs = 0;

  ListTile buildTile(context, index) {

    Subject subject = isForScheduler ? subjectsWithoutSecs[index] : subjects[index];
    String name = subject.customName;
    bool isInside = false;
    int subIndexForCrs = -1;
    int subIndexForAddedCrs = -1;

    //print("current schedule is: ${Main.schedules[Main.currentScheduleIndex].scheduleCourses}");
    if (!isForScheduler) {
      for (Course crs in Main.schedules[Main.currentScheduleIndex].scheduleCourses) {
        if (crs.subject.courseCode == subject.courseCode) {
          subIndexForCrs = subCountCrs++;
          isInside = true;
          break;
        }
      }
    }
    if (!isInside) {
      for (Subject sub in Main.coursesToAdd) {
        if (sub.courseCode == subject.courseCode) {
          subIndexForAddedCrs = subCountAddedCrs++;
          isInside = true;
          break;
        }
      }
    }

    return ListTile(
      title: Text(subject.courseCode, style: TextStyle(color: Main.appTheme.titleTextColor)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              isForScheduler ? EmptyContainer() : Expanded(
                child: Text(
                  name,
                  style: TextStyle(color: Main.appTheme.titleTextColor),
                ),
              ),
              Visibility(
                visible: isInside,
                child: TextButton(
                  child: const Icon(Icons.highlight_remove_outlined, color: Colors.red),
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(Size(iconSize, iconSize)),
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                    overlayColor: MaterialStateProperty.all(Colors.red.withOpacity(0.15)),
                  ),
                  onPressed: () {
                    setState(() {
                      setState(() {
                        if (subIndexForCrs != -1) {
                          Main.schedules[Main.currentScheduleIndex].scheduleCourses.removeAt(subIndexForCrs);
                        } else {
                          Main.coursesToAdd.removeAt(subIndexForAddedCrs);
                        }
                      });
                    });
                  },
                ),
              ),
            ],
          ),
          (isInside || subject.days.isEmpty) ? SizedBox(height: height * 0.01) : EmptyContainer(),
          Row(
            children: [
              isInside ? const Icon(CupertinoIcons.add_circled_solid, color: Colors.blue) : EmptyContainer(),
              (subject.days.isEmpty && isInside) ? SizedBox(width: width * 0.02) : EmptyContainer(),
              subject.days.isEmpty ? const Icon(CupertinoIcons.time_solid, color: Colors.red) : EmptyContainer(),
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
            translateEng(isInside ? "${subject.courseCode} " + translateEng("is already in the schedule")
                : "${subject.courseCode} " + translateEng("was added to the schedule")),
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

  static double iconSize = 0.0;

  void search(String query) {

    final subjects = subjectsOfDep.where((subject) {

      String name = subject.getNameWithoutSection();

      query = query.toLowerCase();
      name = name.toLowerCase();

      return name.contains(query) || subject.courseCode.toLowerCase().contains(query);

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

