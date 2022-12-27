import "dart:io" show Platform;
import 'dart:ui';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:Atsched/language/dictionary.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Atsched/main.dart';
import 'package:oktoast/oktoast.dart';

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
      backgroundColor: Main.appTheme.scaffoldBackgroundColor,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight((MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * (Platform.isWindows ? 0.05 : 0.1)),
          child: AppBar(backgroundColor: Main.appTheme.headerBackgroundColor)
      ),
      body: SafeArea(
        child: Main.favCourses.isEmpty ? Center(child: Text(translateEng("Nothing to show"), style: TextStyle(color: Main.appTheme.titleTextColor), textAlign: TextAlign.center,))
            : ListView.builder(
              itemCount: Main.favCourses.length,
              itemBuilder: (context, count) {

                TextEditingController notesController = TextEditingController(text: Main.favCourses.elementAt(count).note);

              return ListTile(
                title: Text(Main.favCourses[count].subject.courseCode, style: TextStyle(color: Main.appTheme.titleTextColor)),
                trailing: IconButton(
                    tooltip: translateEng("Notes"),
                    icon: const Icon(CupertinoIcons.chat_bubble_text_fill, color: Colors.blue), onPressed: () {
                  showAdaptiveActionSheet(
                    bottomSheetColor: Main.appTheme.scaffoldBackgroundColor,
                    context: context,
                    title: Column(
                      children: [
                        SizedBox(
                          width: width * 0.7,
                          height: height * 0.3,
                          child: TextFormField(
                            style: TextStyle(color: Main.appTheme.titleTextColor),
                            cursorColor: Main.appTheme.titleTextColor,
                            controller: notesController,
                            minLines: null,
                            maxLines: null,
                            expands: true,
                            // scrollController: ScrollController(), // unnecessary
                            decoration: InputDecoration(
                              labelText: "Notes",
                              labelStyle: TextStyle(color: Main.appTheme.titleTextColor),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 0.3 * height,
                        ),
                      ],
                    ),
                    actions: [
                      BottomSheetAction(title: Text(translateEng("Save"),
                          style: const TextStyle(color: Colors.blue)), onPressed: () {
                        Main.favCourses.elementAt(count).note = notesController.text;
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
                    cancelAction: CancelAction(title: const Text('Cancel'), onPressed: () {
                      notesController.text = Main.favCourses.elementAt(count).note;
                      Navigator.pop(context);
                    }),
                  );
                }),
                onTap: () {
                  String name = Main.favCourses[count].subject.customName;

                  String classrooms, teachers, departments;
                  classrooms = Main.favCourses[count].subject.classrooms.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");
                  teachers = Main.favCourses[count].subject.getTranslatedTeachers();
                  departments = Main.favCourses[count].subject.departments.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");

                  List<String> list = classrooms.split(",").toList();
                  list = deleteRepitions(list);
                  classrooms = list.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");

                  list = teachers.split(",").toList();
                  list = deleteRepitions(list);
                  teachers = list.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");

                  teachers.trim();
                  classrooms.trim();
                  departments.trim();

                  showAdaptiveActionSheet(
                    bottomSheetColor: Main.appTheme.scaffoldBackgroundColor ,
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
                            Expanded(child: Container(padding: EdgeInsets.fromLTRB(width * 0.05, 0, 0, 0), child: Text(classrooms, style: TextStyle(color:Main.appTheme.titleTextColor)))),
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
                        SizedBox(height: height * 0.03),
                        Visibility(
                          visible: Main.favCourses[count].note.isNotEmpty,
                          child: Row(children: [
                            Main.favCourses[count].note.isNotEmpty ? Icon(CupertinoIcons.text_aligncenter, color: Main.appTheme.titleTextColor) : Container(width: 0),
                            Expanded(child: Container(padding: EdgeInsets.fromLTRB(width * 0.05, 0, 0, 0), child: Text(Main.favCourses[count].note, style: TextStyle(color: Main.appTheme.titleTextColor)))),
                          ]
                          ),
                        ),
                        SizedBox(height: height * 0.03),
                        (Main.favCourses[count].subject.days.isNotEmpty && Main.favCourses[count].subject.bgnPeriods.isNotEmpty && Main.favCourses[count].subject.hours.isNotEmpty) ?
                        SizedBox(
                            width: (MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * (Platform.isWindows ? 0.4 : 0.7),
                            height: (MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * (Platform.isWindows ? 0.4 : 0.7),
                            child: CustomPaint(painter:
                        TimetableCanvas(
                            beginningPeriods: Main.favCourses[count].subject.bgnPeriods, days: Main.favCourses[count].subject.days, hours: Main.favCourses[count].subject.hours, isForSchedule: false, isForClassrooms: false, wantedPeriod: PeriodData.EMPTY))
                        ) : Container(),
                      ],
                    ),

                    actions: [ // Text(translateEng("ADD TO SCHEDULE"))
                      BottomSheetAction(title: Text(translateEng("Add to Schedule"),
                          style: const TextStyle(color: Colors.blue)),
                          onPressed: () {
                            Navigator.pop(context);
                            Subject sub = Main.favCourses.elementAt(count).subject;
                            bool doesExist = false;
                            for (Course sub_ in Main.schedules[Main.currentScheduleIndex].scheduleCourses) {
                              if (sub_.subject.courseCode == sub.courseCode) {
                                doesExist = true;
                              }
                            }
                            if (!doesExist) {
                              Main.schedules[Main.currentScheduleIndex].scheduleCourses.add(Course(subject: sub, note: ""));
                            }
                            showToast(
                              translateEng(doesExist ? "The course is already in the schedule" : "Added to the current schedule"),
                              duration: const Duration(milliseconds: 1500),
                              position: ToastPosition.bottom,
                              backgroundColor: const Color.fromRGBO(80, 154, 167, 1.0),
                              radius: 100.0,
                              textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
                            );
                          }
                      ),
                      BottomSheetAction(title: Text(translateEng("Remove"),
                          style: const TextStyle(color: Colors.red)),
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              Main.favCourses.removeAt(count);
                            });
                          }
                      ),
                    ],
                    cancelAction: CancelAction(title: Text(translateEng("Close"))),
                  );

                },
              );
            },
          ),
        ),
      );

  }


}
