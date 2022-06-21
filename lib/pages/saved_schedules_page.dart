
import 'dart:ui';

import 'package:ders_program_test/language/dictionary.dart';
import 'package:ders_program_test/others/subject.dart';
import 'package:ders_program_test/widgets/textfieldwidget.dart';
import 'package:ders_program_test/widgets/timetable_canvas.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class SavedSchedulePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {

    return SavedSchedulePageState();

  }

}

class SavedSchedulePageState extends State<SavedSchedulePage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        //child: Expanded( // This was causing an error, so keep it like this!
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: buildSchedulesList(),
          ),
        //),
      ),
    );

  }

  List<Widget> buildSchedulesList() {

    double width = (window.physicalSize / window.devicePixelRatio).width;
    double height = (window.physicalSize / window.devicePixelRatio).height;

    List<Widget> tiles = [];
    List<Widget> scheduleTiles = [];

    Schedule schedule;
    for (int scheduleIndex = 0 ; scheduleIndex < Main.schedules.length ; scheduleIndex++) { // looping for each schedule
      schedule = Main.schedules[scheduleIndex];
      int totalHours = 0;
      List<List<int>> beginningPeriods = [], days = [];
      List<int> hours = [];

      String courses = "";
      for (int i = 0 ; i < schedule.scheduleCourses.length ; i++) { // looping for each course
        courses = courses + ", " + schedule.scheduleCourses[i].subject.classCode;

        //print("Hours: ${schedule.scheduleCourses[i].subject.hours}");
        for (int j = 0 ; j < schedule.scheduleCourses[i].subject.hours.length ; j++) {
          totalHours += schedule.scheduleCourses[i].subject.hours[j] * schedule.scheduleCourses[i].subject.days[j].length;
        }

      }
      courses = schedule.scheduleCourses.isNotEmpty ? courses.substring(2) : "";

      scheduleTiles.add(ExpansionTile(
        title: Row(
          children: [
            Main.currentScheduleIndex == scheduleIndex ? const Icon(CupertinoIcons.checkmark_seal_fill) : Container(),
            SizedBox(width: 0.03 * width),
            Text(schedule.scheduleName),
          ],
        ),
        initiallyExpanded: true,
        children: [
          Container(
            padding: EdgeInsets.all(width * 0.05),
            margin: EdgeInsets.all(width * 0.05),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.all(Radius.circular(0.05 * width)),
            ),
            child: Column(
              children: [
                Visibility(
                  visible: schedule.scheduleCourses.isEmpty,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text("There are no courses inside this schedule, you can add from "),
                      TextButton.icon(
                        icon: const Icon(Icons.search),
                        label: Text("Search"),
                        onPressed: () { // TODO:

                        },
                      ),
                      const Text(" or "),
                      TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: Text("Add Course"),
                        onPressed: () { // TODO:

                        },
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: schedule.scheduleCourses.isNotEmpty,
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.book_fill),
                      SizedBox(width: width * 0.03),
                      Expanded(child: Text(courses)),
                    ],
                  ),
                ),
                SizedBox(height: width * 0.03),
                Visibility(
                  visible: schedule.scheduleCourses.isNotEmpty,
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.clock_fill),
                      SizedBox(width: width * 0.03),
                      Expanded(child: Text(totalHours.toString() + " hours")),
                    ],
                  ),
                ),
                SizedBox(height: width * 0.03),
                Visibility(
                  visible: schedule.scheduleCourses.isNotEmpty,
                  child: ListTile(
                    onTap: null,
                    title: Container(
                        width: width * 0.7, height: width * 0.7,
                        child: CustomPaint(painter:
                          TimetableCanvas(beginningPeriods: beginningPeriods, days: days, hours: hours, isForSchedule: true)
                        ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: Main.currentScheduleIndex != scheduleIndex,
                        child: TextButton.icon(
                          icon: const Icon(CupertinoIcons.checkmark_seal, color: Colors.white),
                          label: Text(translateEng("Set active"), style: const TextStyle(color: Colors.white)),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.blue),
                            overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.2)),
                          ),
                          onPressed: () { // TODO:
                            setState(() {
                              print("Setting current index as $scheduleIndex");
                              Main.currentScheduleIndex = scheduleIndex;
                            });
                          },
                        ),
                    ),
                    SizedBox(width: width * 0.03),
                    Visibility(
                      visible: Main.schedules.length > 1,
                      child: TextButton.icon(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.red),
                          overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.2)),
                          padding: MaterialStateProperty.all(EdgeInsets.zero),
                        ),
                        icon: const Icon(Icons.highlight_remove, color: Colors.white),
                        label: Text(translateEng("Remove schedule"), style: const TextStyle(color: Colors.white)),
                        onPressed: () {
                          ;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ));

    }

    tiles.add(Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: scheduleTiles,
        ),
      ),
    ));

    tiles.add(
      TextButton.icon(
        icon: const Icon(Icons.add),
        label: const Text("create empty schedule"),
        onPressed: () {
          setState(() {
            showDialog(context: context, builder: (context) {

              String scheduleName = "";

              return AlertDialog(
                title: Text(translateEng("Creating Schedule")),
                content: Builder(
                  builder: (context) {
                    return Container(
                      width: width * 1,
                      height: height * 0.25,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(translateEng("Name")),
                              SizedBox(width: width * 0.4,
                                  child: TextFieldWidget(text: "", onChanged: (str) {scheduleName = str;}, hintText: "e.g. 2019 Summer")),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                ),
                actions: [
                  TextButton(
                    child: Text(translateEng("SAVE")),
                    onPressed: () {
                      setState(() {
                        Main.schedules.add(Schedule(scheduleName: scheduleName, changes: [], scheduleCourses: []));
                      });
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: Text(translateEng("CANCEL")),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );

            });
          });
        },
      )
    );

    return tiles;

  }

}
