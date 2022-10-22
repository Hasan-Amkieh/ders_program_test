import 'dart:ui';
import "dart:io" show Platform;

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:Atsched/language/dictionary.dart';
import 'package:Atsched/others/subject.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';


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
  void initState() {

    super.initState();

    ;

  }

  @override
  Widget build(BuildContext context) {

    width = (window.physicalSize / window.devicePixelRatio).width; // Because if it is converted from portrait to landscape or the opposite, the width changes
    height = (window.physicalSize / window.devicePixelRatio).height;
    // if (MediaQuery.of(context).orientation == Orientation.landscape) { // (MediaQuery.of(context).orientation == Orientation.portrait ? width : height)
    //   double x = height;
    //   height = width;
    //   width = x;
    // }

    if (mode != lastMode) {
      lastMode = mode;
      String modeName = "";
      switch (mode) {
        case 0:
          modeName = "View";
          break;
        case 1:
          modeName = "Edit";
          break;
        case 2:
          modeName = "Delete";
          break;
      }
      showToast(
        translateEng("$modeName Mode"),
        duration: const Duration(milliseconds: 1500),
        position: ToastPosition.bottom,
        backgroundColor: const Color.fromRGBO(80, 154, 167, 1.0),
        radius: 100.0,
        textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
      );
    }

    return Scaffold(
      backgroundColor: Main.appTheme.scaffoldBackgroundColor,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight((MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * (Platform.isWindows ? 0.05 : 0.1)),
          child: AppBar(backgroundColor: Main.appTheme.headerBackgroundColor)),
      body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(width * 0.01),
            child: Column(
              children: [
                SizedBox(height: height * 0.01),
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
                        border: Border(bottom: BorderSide(color: mode == 0 ? Colors.grey.shade700 : Main.appTheme.scaffoldBackgroundColor, width: 2)),
                      ),
                      child: Container(
                        child: IconButton(
                          tooltip: translateEng("View Mode"),
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
                        border: Border(bottom: BorderSide(color: mode == 1 ? Colors.green.shade700 : Main.appTheme.scaffoldBackgroundColor, width: 2)),
                      ),
                      child: Container(
                        child: IconButton(
                          tooltip: translateEng("Edit Mode"),
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
                        border: Border(bottom: BorderSide(color: mode == 2 ? Colors.red.shade700 : Main.appTheme.scaffoldBackgroundColor, width: 2)),
                      ),
                      child: Container(
                        child: IconButton(
                          tooltip: translateEng("Delete Mode"),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0.02 * width))),
                          backgroundColor: MaterialStateProperty.all(Main.appTheme.navigationBarColor),
                          overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.2)),
                        ),
                        icon: Icon(Icons.add, color: Main.appTheme.navIconColor),
                        label: Text(translateEng("add courses"), style: TextStyle(color: Main.appTheme.titleTextColor, fontSize: 12)),
                        onPressed: () {
                          if (Main.isFacDataFilled) {
                            Navigator.pushNamed(context, "/home/editcourses/addcourses").then((value) {
                              if (Main.coursesToAdd.isNotEmpty) {
                                setState(() {
                                  List<Course> crses = [];
                                  Main.coursesToAdd.forEach((sub) {
                                    crses.add(Course(subject: sub, note: ""));
                                  });
                                  Main.schedules[Main.currentScheduleIndex].scheduleCourses.addAll(crses);
                                  Main.coursesToAdd.clear();
                                });
                              }
                            });
                          } else {
                            showToast(
                              translateEng("The courses could not be loaded!"),
                              duration: const Duration(milliseconds: 1500),
                              position: ToastPosition.bottom,
                              backgroundColor: Colors.red.withOpacity(0.8),
                              radius: 100.0,
                              textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
                            );
                          }
                        }
                    ),
                    SizedBox(width: width * 0.03),
                    TextButton.icon(
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.2)),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0.02 * width))),
                          backgroundColor: MaterialStateProperty.all(Main.appTheme.navigationBarColor),
                        ),
                        icon: Icon(CupertinoIcons.pencil, color: Main.appTheme.navIconColor),
                        label: Text(translateEng("new course"), style: TextStyle(color: Main.appTheme.titleTextColor, fontSize: 12)),
                        onPressed: () {
                          Navigator.pushNamed(context, "/home/editcourses/createcustomcourse").then((value) { setState(() {}); });
                        }
                    ),
                  ]
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

    if (Main.schedules[Main.currentScheduleIndex].scheduleCourses.isEmpty) {
      return Container(
        child: Column(
          children: [
            SizedBox(height: height * 0.05,),
            Icon(Icons.error, color: Colors.grey.shade700, size: (IconTheme.of(context).size ?? 64) * 2),
            SizedBox(height: height * 0.05),
            Text(translateEng("Nothing to show"), style: TextStyle(color: Main.appTheme.titleTextColor))
          ],
        ),
      );
    } else {
      return RawScrollbar(
        crossAxisMargin: 0.0,
        trackVisibility: true,
        thumbVisibility: true,
        thumbColor: Colors.blueGrey,
        // trackColor: Colors.redAccent.shade700,
        trackBorderColor: Colors.white,
        radius: const Radius.circular(20),
        child: ListView.builder(
            itemCount: Main.schedules[Main.currentScheduleIndex].scheduleCourses.length, itemBuilder: (context, index) {
              TextEditingController notesController = TextEditingController(text: Main.schedules[Main.currentScheduleIndex].scheduleCourses.elementAt(index).note);
              Subject subject = Main.schedules[Main.currentScheduleIndex].scheduleCourses.elementAt(index).subject;
              //print("Building the subject of teachers ${subject.teacherCodes}");
              return AnimatedContainer(
                margin: EdgeInsets.symmetric(vertical: (Platform.isWindows ? 0.005 : 0.01) * width),
                duration: duration,
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(width: 3.0, color: color), top: BorderSide(width: height * (Platform.isWindows ? 0.005 : 0.01), color: Colors.transparent)),
                ),
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: (Platform.isWindows ? 0.003 : 0.01) * width),
                  child: ListTile(
                    style: ListTileStyle.drawer,
                    contentPadding: EdgeInsets.fromLTRB(width * 0.02, 0, 0, 0),
                    title: Text(subject.classCode, style: TextStyle(color: Main.appTheme.titleTextColor)),
                    trailing: Container(
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.only(right: 10.0),
                      child: IconButton(
                        tooltip: translateEng("Notes"),
                        icon: const Icon(CupertinoIcons.chat_bubble_text_fill, color: Colors.blue), onPressed: () {
                        showAdaptiveActionSheet(
                          bottomSheetColor: Main.appTheme.headerBackgroundColor,
                          context: context,
                          title: Column(
                            children: [
                              SizedBox(
                                width: (MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * 0.7,
                                height: (MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * 0.3,
                                child: TextFormField(
                                  cursorColor: Main.appTheme.titleTextColor,
                                  controller: notesController,
                                  minLines: null,
                                  maxLines: null,
                                  expands: true,
                                  scrollController: ScrollController(),
                                  style: TextStyle(color: Main.appTheme.titleTextColor),
                                  decoration: InputDecoration(
                                    labelStyle: TextStyle(color: Main.appTheme.titleTextColor),
                                    labelText: translateEng("Notes"),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 0.2 * (MediaQuery.of(context).orientation == Orientation.portrait ? width : height),
                              ),
                            ],
                          ),
                          actions: [
                            BottomSheetAction(title: Text(translateEng("Save"),
                                style: const TextStyle(color: Colors.blue)), onPressed: () {
                                  Main.schedules[Main.currentScheduleIndex].scheduleCourses.elementAt(index).note = notesController.text;
                                  Navigator.pop(context);
                                  showToast(
                                    translateEng("Notes were saved"),
                                    duration: const Duration(milliseconds: 1500),
                                    position: ToastPosition.top,
                                    backgroundColor: const Color.fromRGBO(80, 154, 167, 1.0),
                                    radius: 100.0,
                                    textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
                                  );
                            }),
                          ],
                          cancelAction: CancelAction(title: Text(translateEng('Cancel')), onPressed: () {
                            notesController.text = Main.schedules[Main.currentScheduleIndex].scheduleCourses.elementAt(index).note;
                            Navigator.pop(context);
                          }),
                        );
                      }),
                    ),
                onTap: () {

                  if (mode == 0) { // view

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
                    list = list.where((element) => element.trim().isNotEmpty).toList();
                    list = deleteRepitions(list);
                    classrooms = list.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");

                    list = teachers.split(",").toList();
                    list = list.where((element) => element.trim().isNotEmpty).toList();
                    list = deleteRepitions(list);
                    teachers = list.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");

                    classrooms.trim();
                    teachers.trim();
                    departments.trim();

                    showAdaptiveActionSheet(
                      bottomSheetColor: Main.appTheme.headerBackgroundColor,
                      context: context,
                      title: Column(
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Expanded(
                              child: Center(child: Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Main.appTheme.titleTextColor))),
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
                              classrooms.isNotEmpty ?Icon(CupertinoIcons.placemark_fill, color: Main.appTheme.titleIconColor) : Container(width: 0),
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
                                  teachers.isNotEmpty ? Icon(CupertinoIcons.group_solid, color: Main.appTheme.titleIconColor) : Container(),
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
                                  departments.isNotEmpty ? Icon(CupertinoIcons.building_2_fill, color: Main.appTheme.titleIconColor) : Container(),
                                  Expanded(child: Container(padding: EdgeInsets.fromLTRB(width * 0.05, 0, 0, 0), child: Text(departments, style: TextStyle(color: Main.appTheme.titleTextColor)))),
                                ]
                            ),
                          ),
                          SizedBox(
                            height: height * 0.03,
                          ),
                          (subject.days.isNotEmpty && subject.bgnPeriods.isNotEmpty && subject.hours.isNotEmpty) ?
                          Container(color: Main.appTheme.scaffoldBackgroundColor,
                              width: (MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * (Platform.isWindows ? 0.5 : 0.7),
                              height: (MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * (Platform.isWindows ? 0.5 : 0.7),
                              child: CustomPaint(painter:
                            TimetableCanvas(beginningPeriods: subject.bgnPeriods, days: subject.days, hours: subject.hours, isForSchedule: false, isForClassrooms: false))
                          ) : Container(),
                        ],
                      ),
                      actions: [],
                      cancelAction: CancelAction(title: Text(translateEng('Close'))),
                    );

                  } else if (mode == 1) { // edit

                    Main.courseToEdit = subject;
                    Main.isEditingCourse = true;
                    Navigator.pushNamed(context, "/home/editcourses/editcourseinfo").then((value) {

                      setState(() {
                        Main.isEditingCourse = false;

                        // refinement process: remove the empty classrooms and departments:
                        List<List<String>> list = Main.courseToEdit!.classrooms;
                        // list.forEach((element) {print(element);});
                        for (int i = 0 ; i < list.length ; i++) {
                          if (list[i].isEmpty) {
                            list.removeAt(i);
                            i--;
                            continue;
                          }
                          for (int j = 0 ; j < list[i].length ; j++) {
                            if (list[i][j].trim().isEmpty) {
                              list[i].removeAt(j);
                              j--;
                            }
                          }
                        }
                        Main.courseToEdit!.classrooms = list;

                        List<String> list_ = Main.courseToEdit!.departments;
                        for (int i = 0 ; i < list_.length ; i++) {
                          if (list_[i].trim().isEmpty) {
                            list_.removeAt(i);
                            i--;
                          }
                        }
                        Main.courseToEdit!.departments = list_;
                        // refinement process;

                        Main.schedules[Main.currentScheduleIndex].scheduleCourses[index].subject = Main.courseToEdit!;
                        Main.schedules[Main.currentScheduleIndex].scheduleCourses[index].subject.translateTeachers();
                        // print("Finished editing, saving the course with teachers: ${Main.schedules[Main.currentScheduleIndex].scheduleCourses[index].subject.teacherCodes}");
                      });

                    });

                  } else { // remove
                    setState(() {
                      String str = Main.schedules[Main.currentScheduleIndex].scheduleCourses.elementAt(index).subject.classCode;
                      Main.schedules[Main.currentScheduleIndex].scheduleCourses.removeAt(index);
                      showToast(
                        "'$str' " + translateEng("was removed"),
                        duration: const Duration(milliseconds: 1500),
                        position: ToastPosition.top,
                        backgroundColor: Colors.blue.withOpacity(0.8),
                        radius: 100.0,
                        textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
                      );
                    });
                  }

                },
              ),
            ),
          );
        }),
      );
    }

  }

}
