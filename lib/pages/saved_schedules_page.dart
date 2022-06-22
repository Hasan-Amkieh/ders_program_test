
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:ders_program_test/language/dictionary.dart';
import 'package:ders_program_test/others/subject.dart';
import 'package:ders_program_test/pages/home_page.dart';
import 'package:ders_program_test/widgets/textfieldwidget.dart';
import 'package:ders_program_test/widgets/timetable_canvas.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../main.dart';

class SavedSchedulePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {

    return SavedSchedulePageState();

  }

}

class SavedSchedulePageState extends State<SavedSchedulePage> {

  final controller = ScreenshotController();

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

        days.addAll(schedule.scheduleCourses[i].subject.days);
        beginningPeriods.addAll(schedule.scheduleCourses[i].subject.bgnPeriods);
        hours.addAll(schedule.scheduleCourses[i].subject.hours);

        //print("Hours: ${schedule.scheduleCourses[i].subject.hours}");
        for (int j = 0 ; j < schedule.scheduleCourses[i].subject.hours.length ; j++) {
          totalHours += schedule.scheduleCourses[i].subject.hours[j] * schedule.scheduleCourses[i].subject.days[j].length;
        }

      }
      courses = schedule.scheduleCourses.isNotEmpty ? courses.substring(2) : "";

      scheduleTiles.add(ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Main.currentScheduleIndex == scheduleIndex ? const Icon(CupertinoIcons.checkmark_seal_fill) : Container(),
                SizedBox(width: 0.03 * width),
                Text(schedule.scheduleName),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                  ),
                  child: const Icon(CupertinoIcons.pencil_ellipsis_rectangle),
                  onPressed: () {
                    setState(() {
                      showDialog(context: context, builder: (context) {

                        String scheduleName = "";

                        return AlertDialog(
                          title: Text(translateEng("Change Schedule Name")),
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
                                              child: TextFieldWidget(
                                                  text: Main.schedules[scheduleIndex].scheduleName,
                                                  onChanged: (str) {scheduleName = str;},
                                                  hintText: "e.g. 2019 Summer")
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }
                          ),
                          actions: [
                            TextButton(
                              child: Text(translateEng("CHANGE")),
                              onPressed: () {
                                setState(() {
                                  Main.schedules[scheduleIndex].scheduleName = scheduleName;
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
                ),
                Visibility(
                  visible: Main.schedules[scheduleIndex].scheduleCourses.isNotEmpty,
                  child: TextButton(
                    child: const Icon(Icons.share),
                    onPressed: () {
                      setState(() {
                        showDialog(context: context, builder: (context) {

                          return AlertDialog(
                            title: Text(translateEng("Share Schedule")),
                            content: Builder(
                                builder: (context) {
                                  return Container(
                                    width: width * 1,
                                    height: height * 0.35,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.screenshot),
                                            SizedBox(width: width * 0.03),
                                            Text(translateEng("Screenshot the Schedule")),
                                          ],
                                        ),
                                        SizedBox(height: width * 0.03),
                                        TextButton.icon(
                                            icon: const Icon(Icons.save_alt_outlined),
                                            label: Text(translateEng("Save to Gallery")),
                                            onPressed: () async {
                                              final image = await controller.captureFromWidget(HomeState.currentState!.buildSchedulePage());
                                              saveScreenshot(image).then((value) { // TODO: Confirm this by testing the app on Android and IOS:
                                                if (value.toString().contains("isSuccess: true")) {
                                                  Fluttertoast.showToast(
                                                      msg: translateEng("Image was saved to gallery"),
                                                      toastLength: Toast.LENGTH_SHORT,
                                                      gravity: ToastGravity.BOTTOM,
                                                      timeInSecForIosWeb: 1,
                                                      backgroundColor: Colors.blue,
                                                      textColor: Colors.white,
                                                      fontSize: 12.0
                                                  );
                                                } else {
                                                  Fluttertoast.showToast(
                                                      msg: translateEng("Image was NOT saved!"),
                                                      toastLength: Toast.LENGTH_SHORT,
                                                      gravity: ToastGravity.BOTTOM,
                                                      timeInSecForIosWeb: 1,
                                                      backgroundColor: Colors.red,
                                                      textColor: Colors.white,
                                                      fontSize: 12.0
                                                  );
                                                }
                                              });
                                              Navigator.pop(context);
                                            },
                                        ),
                                        TextButton.icon(
                                          icon: const Icon(Icons.link),
                                          label: Text(translateEng("Share Screenshot")),
                                          onPressed: () async {
                                            final image = await controller.captureFromWidget(HomeState.currentState!.buildSchedulePage());
                                            shareScreenshot(image);

                                            Navigator.pop(context);
                                          },
                                        ),
                                        SizedBox(height: width * 0.03),
                                        const Divider(height: 2.0, thickness: 2.0,),
                                        TextButton.icon(
                                          icon: const Icon(CupertinoIcons.link),
                                          label: Text(translateEng("Share by Link")),
                                          onPressed: () {
                                            ;

                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }
                            ),
                            actions: [
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
                  ),
                ),
              ],
            ),
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
                        label: Text(translateEng("Search")),
                        onPressed: () {
                          setState(() {
                            Main.currentScheduleIndex = scheduleIndex;
                            // Just refresh the page
                            Navigator.pushNamed(context, "/home/searchcourses").then((value) => setState(() {}));
                          });
                        },
                      ),
                      const Text(" or "),
                      TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: Text(translateEng("Add Course")),
                        onPressed: () {
                          setState(() {
                            Main.currentScheduleIndex = scheduleIndex;
                          });
                          // Just refresh the page
                          Navigator.pushNamed(context, "/home/editcourses/addcourses").then((value) => setState(() {
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
                          }));
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
                SizedBox(height: width * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: Main.currentScheduleIndex != scheduleIndex,
                        child: TextButton.icon(
                          icon: const Icon(CupertinoIcons.checkmark_seal, color: Colors.white),
                          label: Text(translateEng("Set active"), style: const TextStyle(color: Colors.white, fontSize: 14)),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.blue),
                            overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.2)),
                          ),
                          onPressed: () {
                            setState(() {
                              //print("Setting current index as $scheduleIndex");
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
                          //padding: MaterialStateProperty.all(EdgeInsets.zero),
                        ),
                        icon: const Icon(Icons.highlight_remove, color: Colors.white),
                        label: Text(translateEng("Remove schedule"), style: const TextStyle(color: Colors.white, fontSize: 14)),
                        onPressed: () {
                          setState(() {
                            Main.schedules.removeAt(scheduleIndex);
                            if (scheduleIndex == Main.currentScheduleIndex) {
                              Main.currentScheduleIndex = Main.schedules.length - 1;
                            }
                          });
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

  Future saveScreenshot(Uint8List bytes) async {

    await [Permission.storage].request().then((value_) {print("Permission response: $value_");});

    final time = DateTime.now().toIso8601String().replaceAll('.', '-').replaceAll(':', '-');
    final name = 'screenshot_of_${Main.schedules[Main.currentScheduleIndex].scheduleName}_$time';
    final result = await ImageGallerySaver.saveImage(bytes, name: name);

    return result;

  }

  void shareScreenshot(Uint8List bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final image = File('${dir.path}/flutter.png');
    image.writeAsBytesSync(bytes);

    await Share.shareFiles([image.path]);

  }

}
