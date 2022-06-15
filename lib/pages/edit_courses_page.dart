import 'dart:math';
import 'dart:ui';

import 'package:ders_program_test/language/dictionary.dart';
import 'package:ders_program_test/others/subject.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../main.dart';
import '../widgets/timetable_canvas.dart';

class EditCoursePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return EditCoursePageState();
  }

}

class EditCoursePageState extends State<EditCoursePage> {

  static int mode = 0; // 0 - view / 1 - edit / 2 - remove
  static int lastMode = -1;
  late double width, height;
  static const Duration duration = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {

    width = (window.physicalSize / window.devicePixelRatio).width; // Because if it is converted from portrait to landscape or the opposite, the width changes
    height = (window.physicalSize / window.devicePixelRatio).height;

    if (mode != lastMode) {
      lastMode = mode;
      String modeName = "";
      switch (mode) {
        case 0:
          modeName = "view";
          break;
        case 1:
          modeName = "edit";
          break;
        case 2:
          modeName = "delete";
          break;
      }
      Fluttertoast.showToast(
          msg: translateEng("$modeName mode"),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 12.0
      );
    }

    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(child: const Icon(Icons.add), tooltip: translateEng("Add a course") ,onPressed: () {

        Navigator.pushNamed(context, "/home/editcourses/addcourses").then((value) {
          if (Main.coursesToAdd.isNotEmpty) {
            setState(() {
              List<Course> crses = [];
              Main.coursesToAdd.forEach((sub) {
                crses.add(Course(subject: sub, note: ""));
              });
              Main.currentSchedule.scheduleCourses.addAll(crses);
              Main.coursesToAdd.clear();
            });
          }
        });

      }),
      body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(width * 0.05),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.fromLTRB(0, height * 0.02, 0, 0),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.blue, width: 2.0)),
                      ),
                      child: TextButton.icon(icon: Icon(Icons.create_outlined), label: Text(translateEng("custom course")), onPressed: () {
                        Navigator.pushNamed(context, "/home/editcourses/createcustomcourse").then((value) { setState(() {}); });
                      }),
                    )
                  ],
                ),
                SizedBox(height: height * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 0.05 * width,
                    ),
                    AnimatedContainer(
                      duration: duration,
                      curve: Curves.easeIn,
                      decoration: BoxDecoration(
                        // TODO: Change it into the theme background color
                        //color: mode == 2 ? Colors.blue : Colors.white,
                        //borderRadius: BorderRadius.circular(100.0),
                        border: Border(bottom: BorderSide(color: mode == 0 ? Colors.grey.shade700 : Theme.of(context).scaffoldBackgroundColor, width: 2)),
                      ),
                      child: Container(
                        child: IconButton(
                          tooltip: translateEng("view mode"),
                          splashColor: Colors.transparent,
                          icon: Icon(Icons.remove_red_eye_outlined, color: mode == 0 ? Colors.grey.shade700 : Colors.blue),
                          onPressed: () {
                            setState(() {
                              if (mode != 0) {
                                mode = 0;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: duration,
                      curve: Curves.easeIn,
                      decoration: BoxDecoration(
                        // TODO: Change it into the theme background color
                        //color: mode == 2 ? Colors.blue : Colors.white,
                        //borderRadius: BorderRadius.circular(100.0),
                        border: Border(bottom: BorderSide(color: mode == 1 ? Colors.green.shade700 : Theme.of(context).scaffoldBackgroundColor, width: 2)),
                      ),
                      child: Container(
                        child: IconButton(
                          tooltip: translateEng("edit mode"),
                          splashColor: Colors.transparent,
                          icon: Icon(Icons.edit_note, color: mode == 1 ? Colors.green.shade700 : Colors.blue),
                          onPressed: () {
                            setState(() {
                              if (mode != 1) {
                                mode = 1;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: duration,
                      curve: Curves.easeIn,
                      decoration: BoxDecoration(
                        // TODO: Change it into the theme background color
                        //color: mode == 2 ? Colors.blue : Colors.white,
                        //borderRadius: BorderRadius.circular(100.0),
                        border: Border(bottom: BorderSide(color: mode == 2 ? Colors.red.shade700 : Theme.of(context).scaffoldBackgroundColor, width: 2)),
                      ),
                      child: Container(
                        child: IconButton(
                          tooltip: translateEng("delete mode"),
                          splashColor: Colors.transparent,
                          icon: Icon(Icons.delete, color: mode == 2 ? Colors.red.shade700 : Colors.blue),
                          onPressed: () {
                            setState(() {
                              if (mode != 2) {
                                mode = 2;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 0.05 * width,
                    ),
                  ],
                ),
                Expanded(
                  child: Container(padding: EdgeInsets.symmetric(horizontal: 0.02 * width, vertical: 0.05 * height),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                            // splashColor: Colors.transparent,
                            // highlightColor: Colors.transparent,
                            // hoverColor: Colors.transparent
                        ),
                        child: buildList()
                      )
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  Widget buildList() {

    Color color = Colors.blue;
    switch (mode) {
      case 0:
        color = Colors.grey.shade700;
        break;
      case 1:
        color = Colors.green.shade700;
        break;
      case 2:
        color = Colors.red.shade700;
        break;
    }

    if (Main.currentSchedule.scheduleCourses.isEmpty) {
      return Text(translateEng("You have no courses in the current schedule"));
    } else {
      return ListView.builder(itemCount: Main.currentSchedule.scheduleCourses.length, itemBuilder: (context, index) {
        Subject subject = Main.currentSchedule.scheduleCourses.elementAt(index).subject;
        return AnimatedContainer(
          margin: EdgeInsets.symmetric(vertical: 0.01 * width),
          duration: duration,
          decoration: BoxDecoration(
            border: Border(left: BorderSide(width: 3.0, color: color), top: BorderSide(width: height * 0.01, color: Colors.transparent)),
          ),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 0.01 * width),
            child: ListTile(
              style: ListTileStyle.drawer,
              contentPadding: EdgeInsets.fromLTRB(width * 0.02, 0, 0, 0),
              title: Text(subject.classCode),
              onTap: () {

                if (mode == 0) { // view

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
                  name = name ?? "";
                  String classrooms = "", teachers = "", departments = "";

                  List<List<String>> classroomsList = subject.classrooms;//, teachersList = ;

                  /*List<Point<int>> toRemove = [];
                  for(int i = 0 ; i < classroomsList.length ; i++) {
                    for (int j = 0 ; j < classroomsList[i].length ; j++) {
                      // Search for classroomsList[i][j] /
                      for (int k = 0 ; k < classroomsList.length ; k++) {
                        for (int l = 0 ; l < classroomsList[k].length ; l++) {
                          if (classroomsList[i][j] == classroomsList[k][l]) {
                            toRemove.add(Point(i, j));
                          }
                        }
                      }

                    }
                  }

                  ;*/

                  classrooms = classroomsList.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");
                  departments = subject.departments.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");
                  if (subject.teachersTranslated.isEmpty) {
                    teachers = subject.teacherCodes.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");
                  } else {
                    teachers = subject.teachersTranslated;
                  }

                  List<String> list = classrooms.split(",").toList();
                  list = deleteRepitions(list);
                  classrooms = list.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");

                  list = teachers.split(",").toList();
                  list = deleteRepitions(list);
                  teachers = list.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");


                  showDialog(context: context, builder: (context) {

                    return AlertDialog(
                      title: Text(subject.classCode),
                      actions: [
                        TextButton(child: Text(translateEng("OK")), onPressed: () {Navigator.pop(context);},)
                      ],
                      content: Container(
                        child: Builder(
                            builder: (context) {
                              return Container(
                                  height: height * 0.4,
                                  child: Scrollbar( // Just to make the scrollbar viewable
                                    thumbVisibility: true,
                                    child: ListView(
                                      children: [
                                        ListTile(
                                          title: Row(children: [Expanded(child: Text(translateEng("Name: ") + name!))]),
                                          onTap: null,
                                        ),
                                        ListTile(
                                          title: Row(children: [Expanded(child: Text(translateEng("Classrooms: ") + classrooms))]),
                                          onTap: null,
                                        ),
                                        ListTile(
                                          title: Row(children: [Expanded(child: Text(translateEng("Teachers: ") + teachers))]),
                                          onTap: null,
                                        ),
                                        ListTile(
                                          title: Row(children: [Expanded(child: Text(translateEng("Departments: ") + departments))]),
                                          onTap: null,
                                        ),
                                        (subject.days.isNotEmpty && subject.bgnPeriods.isNotEmpty && subject.hours.isNotEmpty) ? ListTile(
                                          onTap: null,
                                          title: Container(width: width * 0.5, height: width * 0.5, child: CustomPaint(painter:
                                          TimetableCanvas(beginningPeriods: subject.bgnPeriods, days: subject.days, hours: subject.hours))),

                                        ) : Container(),
                                      ],
                                    ),
                                  )
                              );
                            }
                        ),
                      ),
                    );

                  });

                } else if (mode == 1) { // edit

                } else { // remove
                  setState(() {
                    String str = Main.currentSchedule.scheduleCourses.elementAt(index).subject.classCode;
                    Main.currentSchedule.scheduleCourses.removeAt(index);
                    Fluttertoast.showToast(
                        msg: "$str " + translateEng("was removed"),
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        fontSize: 12.0
                    );
                  });
                }

              },
            ),
          ),
        );
      });
    }

  }

}
