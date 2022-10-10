
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:Atsched/language/dictionary.dart';
import 'package:Atsched/others/subject.dart';
import 'package:Atsched/pages/home_page.dart';
import 'package:Atsched/widgets/timetable_canvas.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
// import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
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
  void initState() {

    super.initState();

  }

  @override
  Widget build(BuildContext context) {

    double width = (window.physicalSize / window.devicePixelRatio).width;
    double height = (window.physicalSize / window.devicePixelRatio).height;

    return Scaffold(
      backgroundColor: Main.appTheme.scaffoldBackgroundColor,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight((MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * (Platform.isWindows ? 0.05 : 0.1)),
          child: AppBar(backgroundColor: Main.appTheme.headerBackgroundColor)),
      body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: buildSchedulesList(),
          ),
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
      // print("Doing schedule ${schedule.scheduleName}");

      int totalHours = 0;
      List<List<int>> beginningPeriods = [], days = [];
      List<int> hours = [];

      String courses = "";
      for (int i = 0 ; i < schedule.scheduleCourses.length ; i++) { // looping for each course
        courses = courses + "  |  " + schedule.scheduleCourses[i].subject.classCode;

        days.addAll(schedule.scheduleCourses[i].subject.days);
        beginningPeriods.addAll(schedule.scheduleCourses[i].subject.bgnPeriods);
        hours.addAll(schedule.scheduleCourses[i].subject.hours);

        //print("Hours: ${schedule.scheduleCourses[i].subject.hours}");
        for (int j = 0 ; j < schedule.scheduleCourses[i].subject.days.length ; j++) {
          totalHours += schedule.scheduleCourses[i].subject.hours[j] * schedule.scheduleCourses[i].subject.days[j].length;
        }

      }
      courses = schedule.scheduleCourses.isNotEmpty ? courses.substring(5) : "";

      scheduleTiles.add(ExpansionTile(
        backgroundColor: Main.appTheme.scaffoldBackgroundColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Main.currentScheduleIndex == scheduleIndex ? const Icon(CupertinoIcons.checkmark_seal_fill, color: Colors.blue) : Container(),
                SizedBox(width: (Platform.isWindows ? 0.01 : 0.03) * width),
                Text(schedule.scheduleName, style: const TextStyle(color: Colors.blue)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(CupertinoIcons.ellipsis_vertical, color: Colors.blue),
                  onPressed: () {
                    showAdaptiveActionSheet(
                      bottomSheetColor: Main.appTheme.scaffoldBackgroundColor,
                      context: context,
                      title: Text(Main.schedules[scheduleIndex].scheduleName, style: TextStyle(fontWeight: FontWeight.bold, color: Main.appTheme.titleTextColor)),
                      androidBorderRadius: 30,
                      actions: buildBottomSheetActions(scheduleIndex),
                      cancelAction: CancelAction(title: Text(translateEng('Close'))),// onPressed parameter is optional by default will dismiss the ActionSheet
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        initiallyExpanded: true,
        children: [
          Container(
            padding: EdgeInsets.all(width * (Platform.isWindows ? 0.03 : 0.05)),
            margin: EdgeInsets.all(width * (Platform.isWindows ? 0.01 : 0.05)),
            decoration: BoxDecoration(
              color: Main.appTheme.scheduleBackgroundColor.withOpacity(0.6),
              borderRadius: BorderRadius.all(Radius.circular(0.05 * width)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Visibility(
                  visible: schedule.scheduleCourses.isEmpty,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(translateEng("No courses to show"), style: TextStyle(color: Main.appTheme.titleTextColor)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.search),
                            label: Text(translateEng("Search")),
                            onPressed: () {
                              setState(() {
                                Main.currentScheduleIndex = scheduleIndex;
                                if (Main.isFacDataFilled) {
                                  Navigator.pushNamed(context, "/home/searchcourses").then((value) => setState(() {}));
                                } else {
                                  showToast(
                                    translateEng("The courses could not be loaded!"),
                                    duration: const Duration(milliseconds: 1500),
                                    position: ToastPosition.bottom,
                                    backgroundColor: Colors.blue.withOpacity(0.8),
                                    radius: 100.0,
                                    textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
                                  );
                                }
                              });
                            },
                          ),
                          Text(translateEng(" or "), style: TextStyle(color: Main.appTheme.titleTextColor)),
                          TextButton.icon(
                            icon: const Icon(Icons.add),
                            label: Text(translateEng("Add Course")),
                            onPressed: () {
                              setState(() {
                                Main.currentScheduleIndex = scheduleIndex;
                              });
                              if (Main.isFacDataFilled) {
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
                              } else {
                                showToast(
                                  translateEng("The courses could not be loaded!"),
                                  duration: const Duration(milliseconds: 1500),
                                  position: ToastPosition.bottom,
                                  backgroundColor: Colors.blue.withOpacity(0.8),
                                  radius: 100.0,
                                  textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: schedule.scheduleCourses.isNotEmpty,
                  child: Platform.isWindows ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Icon(CupertinoIcons.book_fill, color: Main.appTheme.titleTextColor),
                                SizedBox(width: width * 0.03),
                                Expanded(child: Text(courses, style: TextStyle(color: Main.appTheme.titleTextColor))),
                              ],
                            ),
                            SizedBox(height: width * 0.03),
                            Row(
                              children: [
                                Icon(CupertinoIcons.clock_fill, color: Main.appTheme.titleTextColor),
                                SizedBox(width: width * 0.03),
                                Expanded(child: Text(totalHours.toString() + " hours", style: TextStyle(color: Main.appTheme.titleTextColor))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: width * (Platform.isWindows ? 0 : 0.03)),
                      SizedBox(
                        width: (MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * (Platform.isWindows ? 0.6 : 0.7),
                        height: (MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * (Platform.isWindows ? 0.6 : 0.7),
                        child: CustomPaint(painter:
                        TimetableCanvas(beginningPeriods: beginningPeriods, days: days, hours: hours, isForSchedule: true)
                        ),
                      ),
                    ],
                  ) : Column(
                    children: [
                      Row(
                        children: [
                          Icon(CupertinoIcons.book_fill, color: Main.appTheme.titleTextColor),
                          SizedBox(width: width * 0.03),
                          Expanded(child: Text(courses, style: TextStyle(color: Main.appTheme.titleTextColor))),
                        ],
                      ),
                      SizedBox(height: width * 0.03),
                      Row(
                        children: [
                          Icon(CupertinoIcons.clock_fill, color: Main.appTheme.titleTextColor),
                          SizedBox(width: width * 0.03),
                          Expanded(child: Text(totalHours.toString() + " hours", style: TextStyle(color: Main.appTheme.titleTextColor))),
                        ],
                      ),
                      SizedBox(height: width * (Platform.isWindows ? 0 : 0.03)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: (MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * (Platform.isWindows ? 0.6 : 0.7),
                            height: (MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * (Platform.isWindows ? 0.6 : 0.7),
                            child: CustomPaint(painter:
                            TimetableCanvas(beginningPeriods: beginningPeriods, days: days, hours: hours, isForSchedule: true)
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ));

    }

    tiles.add(Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: RawScrollbar(
          crossAxisMargin: 0.0,
          trackVisibility: true,
          thumbVisibility: true,
          thumbColor: Colors.blueGrey,
          // trackColor: Colors.redAccent.shade700,
          trackBorderColor: Colors.white,
          radius: const Radius.circular(20),
          child: SingleChildScrollView(
            child: Column(
              children: scheduleTiles,
            ),
          ),
        ),
      ),
    ));

    tiles.add(
      TextButton.icon(
        icon: const Icon(Icons.add),
        label: Text(translateEng("create schedule")),
        onPressed: () {
          setState(() {
            showDialog(context: context, builder: (context) {

              TextEditingController nameController = TextEditingController();

              return AlertDialog(
                backgroundColor: Main.appTheme.scaffoldBackgroundColor,
                title: Text(translateEng("Creating Schedule"), style: TextStyle(color: Main.appTheme.titleTextColor)),
                content: Builder(
                  builder: (context) {
                    return SizedBox(
                      width: width * 1,
                      height: height * 0.25,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(translateEng("Name"), style: TextStyle(color: Main.appTheme.titleTextColor)),
                              SizedBox(width: width * 0.4,
                                  child: TextFormField(controller: nameController, cursorColor: Main.appTheme.titleTextColor, style: TextStyle(color: Main.appTheme.titleTextColor), decoration: InputDecoration(hintStyle: TextStyle(color: Main.appTheme.hintTextColor), hintText: translateEng("e.g. Summer Semester"))))
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                ),
                actions: [
                  TextButton(
                    child: Text(translateEng("CREATE")),
                    onPressed: () {
                      if (nameController.text.trim().isNotEmpty) {
                        setState(() {
                          Main.schedules.add(Schedule(scheduleName: nameController.text, scheduleCourses: []));
                          Main.currentScheduleIndex = Main.schedules.length - 1;
                        });
                        Navigator.pop(context);
                      } else {
                        showToast(
                          translateEng("The name cannot be empty"),
                          duration: const Duration(milliseconds: 1500),
                          position: ToastPosition.bottom,
                          backgroundColor: Colors.red.withOpacity(0.8),
                          radius: 100.0,
                          textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
                        );
                      }
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

    //await [Permission.storage].request().then((value_) {print("Permission response: $value_");});
    // no need to ask for permission since we already asked for it when the app started!

    final time = DateTime.now().toIso8601String().replaceAll('.', '-').replaceAll(':', '-');
    final name = 'screenshot_of_${Main.schedules[Main.currentScheduleIndex].scheduleName}_$time';

    String result = "isSuccess: false";

    if (Platform.isWindows) {
      try {
        File imgFile = await File('${Main.appDocDir.replaceAll("Documents", "Desktop")}\\$name.png').create();
        await imgFile.writeAsBytes(bytes);
        result = "isSuccess: true";
      } catch (e) {
        print(e);
      }
    } else {
      result = (await ImageGallerySaver.saveImage(bytes, name: name)).toString();
      // print("The result of the phone version is : $result");
    }

    return result;

  }

  void shareScreenshot(Uint8List bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final image = File('${dir.path}/flutter.png');
    image.writeAsBytesSync(bytes);

    await Share.shareFiles([image.path]);

  }

  List<BottomSheetAction> buildBottomSheetActions(int scheduleIndex) {

    List<BottomSheetAction> actions = [];
    double width = (window.physicalSize / window.devicePixelRatio).width;
    double height = (window.physicalSize / window.devicePixelRatio).height;

    actions.add(BottomSheetAction(
        title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(CupertinoIcons.pencil_ellipsis_rectangle, color: Colors.blue),
          SizedBox(width: width * (Platform.isWindows ? 0.005 : 0.03)),
          Text(translateEng("Rename Schedule"), style: const TextStyle(color: Colors.blue))]),
        onPressed: () {
          showDialog(context: context, builder: (context) {
            TextEditingController nameController = TextEditingController(); // Main.schedules[scheduleIndex].scheduleName

            return AlertDialog(
              backgroundColor: Main.appTheme.scaffoldBackgroundColor,
              title: Text(translateEng("Change Schedule Name"), style: TextStyle(color: Main.appTheme.titleTextColor)),
              content: Builder(
                  builder: (context) {
                    return SizedBox(
                      width: width * 1,
                      height: height * 0.25,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: width * 0.6,
                                child: TextFormField(controller: nameController,
                                    cursorColor: Main.appTheme.titleTextColor,
                                    style: TextStyle(color: Main.appTheme.titleTextColor),
                                    decoration: InputDecoration(
                                        hintText: translateEng("e.g. Summer Semester"),
                                        hintStyle: TextStyle(color: Main.appTheme.hintTextColor),
                                        labelText: "Schedule Name",
                                        labelStyle: TextStyle(color: Main.appTheme.titleTextColor),
                                    ),
                                ),
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
                      Main.schedules[scheduleIndex].scheduleName = nameController.text;
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
          }).then((value) {
            Navigator.pop(context);
            showToast(
              translateEng("The name was changed"),
              duration: const Duration(milliseconds: 1500),
              position: ToastPosition.bottom,
              backgroundColor: Colors.blue.withOpacity(0.8),
              radius: 100.0,
              textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
            );
          });
        }));

    if (Main.schedules[scheduleIndex].scheduleCourses.isNotEmpty) {
      actions.add(BottomSheetAction(
          title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.share, color: Colors.blue),
            SizedBox(width: width * (Platform.isWindows ? 0.005 : 0.03)),
            Text(translateEng("Share"), style: const TextStyle(color: Colors.blue))]
          ),
          onPressed: () {
            showAdaptiveActionSheet(
              bottomSheetColor: Main.appTheme.scaffoldBackgroundColor,
              context: context,
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.share, color: Main.appTheme.titleTextColor),
                      SizedBox(width: width * (Platform.isWindows ? 0.01 : 0.03)),
                      Text(translateEng("By Screenshot of the Schedule"), style: TextStyle(color: Main.appTheme.titleTextColor)),
                    ],
                  ),
                  SizedBox(height: width * 0.03),
                  TextButton.icon(
                    icon: const Icon(Icons.save_alt_outlined),
                    label: Text(translateEng(Platform.isWindows ? "Save Screenshot" : "Save Screenshot to Gallery")),
                    onPressed: () async {
                      int oldScheduleIndex = Main.currentScheduleIndex;
                      Main.currentScheduleIndex = scheduleIndex;
                      final image;
                      if (Platform.isWindows) { // Windows
                        image = await controller.captureFromWidget(
                            MaterialApp(
                                home: Scaffold(
                                  body: HomeState.currentState!.buildSchedulePage(),
                                ),
                        ));
                      } else { // Phone
                        image = await controller.captureFromWidget(HomeState.currentState!.buildSchedulePage());
                      }
                      Main.currentScheduleIndex = oldScheduleIndex;
                      saveScreenshot(image).then((value) {
                        if (value.toString().contains("isSuccess: true")) {
                          showToast(
                            translateEng(Platform.isWindows ? "Image was saved to the Desktop" : "Image was saved to gallery"),
                            duration: const Duration(milliseconds: 1500),
                            position: ToastPosition.bottom,
                            backgroundColor: Colors.blue.withOpacity(0.8),
                            radius: 100.0,
                            textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
                          );
                        } else {
                          showToast(
                            translateEng("Image was NOT saved"),
                            duration: const Duration(milliseconds: 1500),
                            position: ToastPosition.bottom,
                            backgroundColor: Colors.red.withOpacity(0.8),
                            radius: 100.0,
                            textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
                          );
                        }
                      });
                      Navigator.pop(context);
                    },
                  ),
                  Platform.isWindows ? Container() : TextButton.icon(
                    icon: const Icon(Icons.link),
                    label: Text(translateEng("Share Screenshot")),
                    onPressed: () async {
                      int oldScheduleIndex = Main.currentScheduleIndex;
                      Main.currentScheduleIndex = scheduleIndex;
                      final image = await controller.captureFromWidget(HomeState.currentState!.buildSchedulePage());
                      Main.currentScheduleIndex = oldScheduleIndex;
                      shareScreenshot(image);

                      Navigator.pop(context);
                    },
                  ),
                  Platform.isWindows ? Container() : SizedBox(height: width * 0.03),
                  Platform.isWindows ? Container() : const Divider(height: 2.0, thickness: 2.0),
                  Platform.isWindows ? Container() : TextButton.icon(
                    icon: const Icon(CupertinoIcons.link),
                    label: Text(translateEng("Share Schedule by Link")),
                    onPressed: () async {
                      FlutterBranchSdk.disableTracking(true);
                      HomeState.currentState!.initDeepLinkData(scheduleIndex);
                      BranchResponse? response = await HomeState.currentState!.generateLink();

                      var time = DateTime.now().add(const Duration(days: 30));
                      await Share.share("${response?.result}\nThis shared link expires on ${time.year}-${time.month}-${time.day}");

                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              actions: [],
              cancelAction: CancelAction(title: const Text('Close')),
            );
          })
      );
    }

    if (Main.schedules.length > 1) {
      if (scheduleIndex != Main.currentScheduleIndex) {
        actions.add(BottomSheetAction(
            title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(CupertinoIcons.checkmark_seal, color: Colors.blue),
              SizedBox(width: width * (Platform.isWindows ? 0.005 : 0.03)),
              Text(translateEng("Set Active"), style: const TextStyle(color: Colors.blue))]),
            onPressed: () {
              setState(() {
                Main.currentScheduleIndex = scheduleIndex;
                Navigator.pop(context);
                showToast(
                  translateEng("${Main.schedules[scheduleIndex].scheduleName} " + translateEng("is active")),
                  duration: const Duration(milliseconds: 1500),
                  position: ToastPosition.bottom,
                  backgroundColor: Colors.blue.withOpacity(0.8),
                  radius: 100.0,
                  textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
                );
              });
            })
        );
      }
      actions.add(BottomSheetAction(
          title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(CupertinoIcons.xmark_circle, color: Colors.red),
            SizedBox(width: width * (Platform.isWindows ? 0.005 : 0.03)),
            Text(translateEng("Delete"), style: const TextStyle(color: Colors.red))]),
          onPressed: () {
            setState(() {
              Main.schedules.removeAt(scheduleIndex);
              if (scheduleIndex <= Main.currentScheduleIndex) { // otherwise, if it is greater than the current schedule, then do nothing
                Main.currentScheduleIndex = Main.schedules.length - 1;
              }
              Navigator.pop(context);
            });
          })
      );

    }

    return actions;

  }

}
