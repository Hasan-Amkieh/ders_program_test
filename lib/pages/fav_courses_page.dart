

import 'dart:ui';

import 'package:ders_program_test/language/dictionary.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ders_program_test/main.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../others/subject.dart';
import '../widgets/timetable_canvas.dart';

class FavCourses extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return FavCoursesState();
  }

}

class FavCoursesState extends State<FavCourses> {

  @override
  Widget build(BuildContext context) {

    double width = (window.physicalSize / window.devicePixelRatio).width, height = (window.physicalSize / window.devicePixelRatio).height;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Main.favCourses.isEmpty ? Center(child: Text(translateEng("You have no favourite courses, please add them from Search for Courses page"), textAlign: TextAlign.center,))
            : ListView.builder(
              itemCount: Main.favCourses.length,
              itemBuilder: (context, count) {
              return ListTile(
                title: Text(Main.favCourses[count].classCode),
                onTap: () {
                  String? name;
                  if (Main.favCourses[count].classCode.contains("(")) {
                    name = Main.classcodes[Main.favCourses[count].classCode.substring(0, Main.favCourses[count].classCode.indexOf("("))];
                  } else {
                    name = Main.classcodes[Main.favCourses[count].classCode];
                  }
                  String classrooms, teachers, departments;
                  classrooms = Main.favCourses[count].classrooms.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");
                  teachers = Main.favCourses[count].getTranslatedTeachers();
                  departments = Main.favCourses[count].departments.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");

                  List<String> list = classrooms.split(",").toList();
                  list = deleteRepitions(list);
                  classrooms = list.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");

                  list = teachers.split(",").toList();
                  list = deleteRepitions(list);
                  teachers = list.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");

                  teachers.trim();
                  classrooms.trim();
                  departments.trim();

                  showDialog(context: context, builder: (context) => AlertDialog(
                    title: Text(Main.favCourses[count].classCode),
                    content: Builder(
                        builder: (context) {
                          return SizedBox(
                            height: 0.4 * height,
                            child: Scrollbar(
                              thumbVisibility: true,
                              child: ListView(
                                children: [
                                  ListTile(
                                    title: Row(children: [Expanded(child: Text(name!))]),
                                    onTap: null,
                                  ),
                                  ListTile(
                                    title: Row(
                                        children: [
                                          classrooms.isNotEmpty ? const Icon(CupertinoIcons.placemark_fill) : Container(),
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
                                    title: Row(children: [
                                      departments.isNotEmpty ? const Icon(CupertinoIcons.building_2_fill) : Container(),
                                      Expanded(child: Container(padding: EdgeInsets.fromLTRB(width * 0.05, 0, 0, 0), child: Text(departments))),
                                    ]),
                                    onTap: null,
                                  ),
                                  (Main.favCourses[count].days.isNotEmpty && Main.favCourses[count].bgnPeriods.isNotEmpty && Main.favCourses[count].hours.isNotEmpty) ? ListTile(
                                    onTap: null,
                                    title: SizedBox(width: width * 0.5, height: width * 0.5, child: CustomPaint(painter:
                                    TimetableCanvas(beginningPeriods: Main.favCourses[count].bgnPeriods, days: Main.favCourses[count].days, hours: Main.favCourses[count].hours, isForSchedule: false))),

                                  ) : Container(),
                                ],
                              ),
                            ),
                          );
                        }
                        ,
                    ),
                    actions: [
                      TextButton(onPressed: () {
                        Navigator.pop(context);
                      }, child: Text(translateEng("OK"))),

                      TextButton(onPressed: () {
                        Subject sub = Main.favCourses.elementAt(count);
                        bool doesExist = false;
                        for (Course sub_ in Main.schedules[Main.currentScheduleIndex].scheduleCourses) {
                          if (sub_.subject.classCode == sub.classCode) {
                            doesExist = true;
                          }
                        }

                        if (!doesExist) {
                          Main.schedules[Main.currentScheduleIndex].scheduleCourses.add(Course(subject: sub, note: ""));
                        }

                        Fluttertoast.showToast(
                            msg: translateEng(doesExist ? "The course is already in the schedule" : "Added to the current schedule"),
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.blue,
                            textColor: Colors.white,
                            fontSize: 12.0
                        );

                      }, child: Text(translateEng("ADD TO SCHEDULE"))),

                      TextButton(onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          Main.favCourses.removeAt(count);
                        });
                      }, child: Text(translateEng("REMOVE"))),
                    ],
                  )
                  );
                },
              );
            },
          ),
        ),
      );

  }


}
