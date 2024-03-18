import "dart:io" show Platform;
import 'dart:ui';

import 'package:Atsched/language/dictionary.dart';
import 'package:Atsched/others/subject.dart';
import 'package:Atsched/widgets/textfieldwidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';


import '../main.dart';
import '../others/university.dart';
import '../widgets/timetable_canvas.dart';

class CustomCoursePage extends StatefulWidget {

  Subject subject = Subject(customName: "",
      courseCode: "",
      departments: <String>[],
      teacherCodes: <List<String>>[[]],
      hours: <int>[],
      bgnPeriods: <List<int>>[],
      days: <List<int>>[],
      classrooms: <List<String>>[[]]);

  List<bool> showTeacherField = [false], showClassroomField = [false]; // by Periods, a bool for each period
  bool showDepField = false;
  List<List<bool>> editingTeacher = [[]], editingClassroom = [[]]; // by teachers inside each period, a list for each period
  List<bool> editingDep = [];
  List<List<String>> periodData = [["", ""]]; // Each list inside will have 2 strings, teacher names and classrooms accordingly
  String depData = "";
  List<String> days = ["Monday"];
  List<int> hours = [1], bgnHour = [9];
  String dep = "";

  @override
  State<StatefulWidget> createState() {
    return CustomCoursePageState();
  }

}

class CustomCoursePageState extends State<CustomCoursePage> {

  bool isPeriodAdded = false;
  DateTime lastColWarningShown = DateTime.now();

  @override
  void initState() {

    if (Main.isEditingCourse) {

      List<String> teachersList = [];
      List<String> classroomsList = [];

      widget.showTeacherField.clear();
      widget.showClassroomField.clear();

      widget.editingTeacher.clear();
      widget.editingClassroom.clear();
      widget.editingDep.clear();

      widget.periodData.clear();

      widget.days.clear();
      widget.bgnHour.clear();
      widget.hours.clear();

      widget.subject.departments.forEach((element) { widget.editingDep.add(false); });

      int periodIndex = 0;// looping each period

      for (int i = 0 ; i < widget.subject.days.length; i++) {
        for (int j = 0 ; j < widget.subject.days[i].length ; j++) {

          widget.showTeacherField.add(false);
          widget.showClassroomField.add(false);

          widget.editingTeacher.add([]);
          widget.editingClassroom.add([]);

          widget.periodData.add(["", ""]);

          if (periodIndex < widget.subject.teacherCodes.length) {

            teachersList = widget.subject.teacherCodes[periodIndex].toString().replaceAll(RegExp("[\\[.*?\\]]"), "").split(',');
            for (int i_ = 0 ; i_ < teachersList.length ; i_++) {
              widget.editingTeacher[periodIndex].add(false);
            }

          }

          if (periodIndex < widget.subject.classrooms.length) {

            classroomsList = widget.subject.classrooms[periodIndex].toString().replaceAll(RegExp("[\\[.*?\\]]"), "").split(',');
            for (int i_ = 0 ; i_ < classroomsList.length ; i_++) {
              widget.editingClassroom[periodIndex].add(false);
            }

          }

          // print("teachers: $teachersList / classrooms $classroomsList");

          widget.days.add(dayToString(widget.subject.days[i][j]));
          widget.bgnHour.add(widget.subject.bgnPeriods[i][j]);
          widget.hours.add(widget.subject.hours[i]);

          periodIndex++;
        }
      }

      for (int index = 0 ; widget.subject.teacherCodes.length != periodIndex + 1 ; index++) {
        widget.subject.teacherCodes.add([]);
      }
      for (int index = 0 ; widget.subject.classrooms.length != periodIndex + 1 ; index++) {
        widget.subject.classrooms.add([]);
      }

    }

  }

  @override
  Widget build(BuildContext context) {

    double width = (window.physicalSize / window.devicePixelRatio).width;
    double height = (window.physicalSize / window.devicePixelRatio).height;

    String name = widget.subject.customName;

    return Scaffold(
      backgroundColor: Main.appTheme.scaffoldBackgroundColor,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight((MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * (Platform.isWindows ? 0.05 : 0.1)),
          child: AppBar(
            backgroundColor: Main.appTheme.headerBackgroundColor,
            iconTheme: IconThemeData(color: Colors.white),
          )),
      floatingActionButton: Visibility(
        visible: checkIfReadyToConfirm(),
        child: FloatingActionButton(
          child: const Icon(Icons.check, color: Colors.white),
          onPressed: () {

            var v = convertDaysNHrs();
            List<List<int>> listDays = v[0], listBgnHrs = v[1];

            widget.subject.days = listDays;
            widget.subject.bgnPeriods = listBgnHrs;
            widget.subject.hours.addAll(widget.hours);

            // Check if the course code is already used or not:

            if (!Main.isEditingCourse) {
              // print("Checking the course code!");
              bool isUsed = false;
              String str = widget.subject.courseCode.toLowerCase();
              Main.schedules[Main.currentScheduleIndex].scheduleCourses.forEach((sub) {
                if (str == sub.subject.courseCode.toLowerCase()) {
                  isUsed = true;
                  return ;
                }
              });
              if (isUsed) {
                showToast(
                  translateEng("The course code ") + "${widget.subject.courseCode} " + translateEng("is already used"),
                  duration: const Duration(milliseconds: 1500),
                  position: ToastPosition.bottom,
                  backgroundColor: Colors.blue.withOpacity(0.8),
                  radius: 100.0,
                  textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
                );
                return;
              }
            }

            // For test:
            print("days: ${widget.subject.days} / bgnHours: ${widget.subject.bgnPeriods} / hours: ${widget.subject.hours}");

            // Refinement process:  loop through each list and if it is empty remove it!
            // for (int i = 0 ; i < widget.subject.classrooms.length ; i++) {
            //   if (widget.subject.classrooms[i].isEmpty) {
            //     widget.subject.classrooms.removeAt(i);
            //     i--;
            //   }
            // }
            // for (int i = 0 ; i < widget.subject.teacherCodes.length ; i++) {
            //   if (widget.subject.teacherCodes[i].isEmpty) {
            //     widget.subject.teacherCodes.removeAt(i);
            //     i--;
            //   }
            // }

            if (Main.isEditingCourse) {
              print("Teachers: ${widget.subject.teacherCodes}");
              widget.subject.hours.clear();
              widget.subject.hours.addAll(widget.hours);
              Main.courseToEdit = widget.subject;
            } else {
              Main.schedules[Main.currentScheduleIndex].scheduleCourses.add(
                  Course(
                      note: "", subject: widget.subject));
            }
            Navigator.pop(context);

          },
        ),
      ),
      body: SafeArea(
        child: RawScrollbar(
          trackVisibility: true,
          thumbColor: Colors.blueGrey,
          radius: const Radius.circular(20),
          thickness: 5,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  //height: height * 1 + MediaQuery.of(context).viewInsets.bottom, // the keyboard height, if removed it will cause an overflow error!
                  padding: EdgeInsets.all(width * 0.05),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(translateEng("Course Name"), style: TextStyle(color: Main.appTheme.titleIconColor)),
                          SizedBox(
                              width: width * 0.6,
                              child: Main.isEditingCourse ? Text(name, style: TextStyle(color: Main.appTheme.titleIconColor)) : TextFieldWidget(
                                  text: "",
                                  onChanged: (str) { setState(() {
                                    if (str.replaceAll(RegExp('[^A-Za-z0-9\\s]'), '') == str) {
                                      widget.subject.customName = str;
                                    } else {
                                      showToast(
                                        translateEng("The name can only have characters and numbers"),
                                        duration: const Duration(milliseconds: 2500),
                                        position: ToastPosition.bottom,
                                        backgroundColor: Colors.red.withOpacity(0.8),
                                        radius: 100.0,
                                        textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
                                      );
                                    }
                                  }); },
                                  hintText: translateEng("e.g.   Basic English II")
                              )
                          ),
                        ],
                      ),
                      SizedBox(height: Main.isEditingCourse ? height * 0.02 : 0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(translateEng("Course Code"), style: TextStyle(color: Main.appTheme.titleIconColor)),
                          SizedBox(
                              width: width * 0.6,
                              child: Main.isEditingCourse ? Text(widget.subject.courseCode, style: TextStyle(color: Main.appTheme.titleIconColor)) :
                              TextFieldWidget(text: "", onChanged: (str) { setState(() {widget.subject.courseCode = str;}); }, hintText: "e.g.   ENG102")
                          ),
                        ],
                      ),
                      SizedBox(height: Main.isEditingCourse ? height * 0.02 : 0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(CupertinoIcons.building_2_fill, color: Main.appTheme.titleIconColor),
                          Expanded(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: buildDepList(widget.subject.departments.toString().replaceAll(RegExp("[\\[.*?\\]]"), ""), width),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 0.02 * width, vertical: 0.05 * height),
                        height: height * 0.55,
                        child: buildPeriods(width, height),
                      ),
                      // Column(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   crossAxisAlignment: CrossAxisAlignment.stretch,
                      //   children: [
                      //
                      //   ],
                      // ),
                    ],
                  ),
                ),
                TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(translateEng("Add a period")),
                    onPressed: () {
                      setState(() {
                        isPeriodAdded = true;

                        widget.periodData.add(["", ""]);
                        widget.subject.teacherCodes.add([]);
                        widget.subject.classrooms.add([]);
                        widget.days.add("Monday");
                        widget.bgnHour.add(9);
                        widget.hours.add(1);

                        widget.showTeacherField.add(false);
                        widget.showClassroomField.add(false);
                        widget.editingTeacher.add([]);
                        widget.editingClassroom.add([]);

                      });
                    })
              ],
            ),
          ),
        ),
      ),
    );

  }

  List<List<List<int>>> convertDaysNHrs() {

    List<List<int>> listDays = [], listBgnHrs = [];

    for (int i = 0 ; i < widget.days.length; i++) {

      if (widget.days[i] == ("Monday")) {
        listDays.add([1]);
      } else if (widget.days[i] == ("Tuesday")) {
        listDays.add([2]);
      } else if (widget.days[i] == ("Wednesday")) {
        listDays.add([3]);
      } else if (widget.days[i] == ("Thursday")) {
        listDays.add([4]);
      } else if (widget.days[i] == ("Friday")) {
        listDays.add([5]);
      } else if (widget.days[i] == ("Saturday")) {
        listDays.add([6]);
      } else if (widget.days[i] == ("Sunday")) {
        listDays.add([7]);
      }

      listBgnHrs.add([widget.bgnHour[i]]);

    }

    return <List<List<int>>>[listDays, listBgnHrs];

  }

  bool checkIfReadyToConfirm() {

    // Check if the name is valid:
    if (widget.subject.customName.replaceAll(RegExp('[^A-Za-z0-9\\s\\-üÜğĞöÖçÇşŞ\\(\\)]'), '') != widget.subject.customName) {
      // print("Invalid name!");
      return false;
    }

    if (isThereCol()) { // if there is a collision within the course, then you are not allowed to save the course!

      if (!isPeriodAdded && DateTime.now().difference(lastColWarningShown).inSeconds >= 10) {
        lastColWarningShown = DateTime.now();
        showToast(
          translateEng("Please fix the collisions before saving"),
          duration: const Duration(milliseconds: 1500),
          position: ToastPosition.bottom,
          backgroundColor: Colors.red.withOpacity(0.8),
          radius: 100.0,
          textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
        );
      }

      return false;
    }

    isPeriodAdded = false;

    // if we are editing a course, we have no restrictions, bcs the course code and the name are both unchangeable
    if (Main.isEditingCourse) {
      return true;
    }

    bool isReady = true;

    if (widget.subject.customName.isEmpty) {
      return false;
    }
    if (widget.subject.courseCode.isEmpty) {
      return false;
    }

    // for (int i = 0 ; i < widget.periodData.length ; i++) {
    //   if (widget.subject.teacherCodes[i].isEmpty || widget.subject.classrooms[i].isEmpty) {
    //     isReady = false;
    //     break;
    //   }
    // }

    return isReady;

  }

  Widget buildPeriods(double width, double height) {

    List<Widget> tiles = [];
    String dayShort = "";
    String endHour = "";

    for (int i = 0 ; i < widget.days.length ; i++) { // loop through each period

      switch (widget.days[i]) {
        case "Monday":
          dayShort = "Mon";
          break;
        case "Tuesday":
          dayShort = "Tue";
          break;
        case "Wednesday":
          dayShort = "Wed";
          break;
        case "Thursday":
          dayShort = "Thur";
          break;
        case "Friday":
          dayShort = "Fri";
          break;
        case "Saturday":
          dayShort = "Sat";
          break;
        case "Sunday":
          dayShort = "Sun";
          break;
      }

      endHour = (widget.hours[i]+widget.bgnHour[i]).toString();

      var hoursController = TextEditingController(text: widget.hours[i].toString());
      hoursController.addListener(() {
        if (!Main.isNumeric(hoursController.text) || widget.hours[i] < 13) {
          setState(() {
            hoursController.text = widget.hours[i].toString();
            showToast(
              translateEng("Only numbers are allowed and max. 12"),
              duration: const Duration(milliseconds: 1500),
              position: ToastPosition.bottom,
              backgroundColor: Colors.red.withOpacity(0.8),
              radius: 100.0,
              textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
            );
          });
        } else {
          widget.hours[i] = int.parse(hoursController.text);
        }
      });

      tiles.add(ExpansionTile(
        backgroundColor: Main.appTheme.periodBackgroundColor,
        initiallyExpanded: true, // It is not making any difference
        title: Text("$dayShort. ${widget.bgnHour[i]} - $endHour:20", style: TextStyle(color: Main.appTheme.normalTextColor)),
        children: [
          Container(
            padding: EdgeInsets.all(width * 0.05),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(40)),
              color: Main.appTheme.scaffoldBackgroundColor,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(CupertinoIcons.group_solid, color: Main.appTheme.titleIconColor),
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: buildList(widget.subject.teacherCodes[i].toString().replaceAll(RegExp("[\\[.*?\\]]"), ""), i, width, 0),
                ),

                // Classrooms:
                Row(
                  children: [
                    Icon(CupertinoIcons.location_solid, color: Main.appTheme.titleIconColor),
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: buildList(widget.subject.classrooms[i].toString().replaceAll(RegExp("[\\[.*?\\]]"), ""), i, width, 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(translateEng("Day"), style: Main.appTheme.headerStyle),
                    DropdownButton<String>(
                      dropdownColor: Main.appTheme.scaffoldBackgroundColor,
                        value: widget.days[i],
                        onChanged: (newValue) {
                          setState(() {
                            widget.days[i] = newValue!;
                          });
                        },
                        items: [
                          DropdownMenuItem<String>(value: "Monday", child: Text(translateEng("Monday"), style: Main.appTheme.headerStyle)),
                          DropdownMenuItem<String>(value: "Tuesday", child: Text(translateEng("Tuesday"), style: Main.appTheme.headerStyle)),
                          DropdownMenuItem<String>(value: "Wednesday", child: Text(translateEng("Wednesday"), style: Main.appTheme.headerStyle)),
                          DropdownMenuItem<String>(value: "Thursday", child: Text(translateEng("Thursday"), style: Main.appTheme.headerStyle)),
                          DropdownMenuItem<String>(value: "Friday", child: Text(translateEng("Friday"), style: Main.appTheme.headerStyle)),
                          DropdownMenuItem<String>(value: "Saturday", child: Text(translateEng("Saturday"), style: Main.appTheme.headerStyle)),
                          DropdownMenuItem<String>(value: "Sunday", child: Text(translateEng("Sunday"), style: Main.appTheme.headerStyle)),
                        ]),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(translateEng("Beginning Hour"), style: Main.appTheme.headerStyle),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton(
                          child: Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (widget.bgnHour[i] != 1) {
                                widget.bgnHour[i] = widget.bgnHour[i] - 1;
                              }
                            });
                          },
                        ),
                        Text(
                            widget.bgnHour[i].toString() + " : " + University.getBgnMinutes().toString(),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Main.appTheme.titleTextColor)
                        ),
                        TextButton(
                          child: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              if (widget.bgnHour[i] != 23) {
                                widget.bgnHour[i] = widget.bgnHour[i] + 1;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(translateEng("Class Length (hours)"), style: Main.appTheme.headerStyle),
                    SizedBox(
                      width: width * 0.25,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              child: Icon(Icons.remove), // negative
                            onPressed: () {
                              setState(() {
                                if (widget.hours[i] != 1) {
                                  widget.hours[i] = widget.hours[i] - 1;
                                }
                              });
                            },
                          ),
                          SizedBox(
                            width: width * 0.025,
                            height: width * 0.025,
                            child: TextField(
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(width * 0.005),
                                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(width * 0.005))),
                              ),
                              style: TextStyle(color: Main.appTheme.titleTextColor),
                              controller: hoursController,
                            ),
                          ),
                          TextButton(
                            child: Icon(Icons.add), // plus
                            onPressed: () {
                              setState(() {
                                if (widget.hours[i] != 12) {
                                  widget.hours[i] = widget.hours[i] + 1;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      /*Slider(
                        value: widget.hours[i].toDouble(),
                        onChanged: (newValue) {
                          setState(() {
                            // print("New value: " + newValue.toString());
                            widget.hours[i] = newValue.toInt();
                          });
                        },
                        min: 1,
                        max: 12,
                        divisions: 12,
                        label: "${(widget.hours[i].toInt())} hours",
                      )*/
                    ),
                  ],
                ),
                Visibility(
                  visible: widget.subject.teacherCodes.length > 1,
                  child: TextButton.icon(
                      style: ButtonStyle(overlayColor: MaterialStateProperty.all(Color.fromRGBO(Colors.red.red, Colors.red.green, Colors.red.green, 0.2))),
                      icon: const Icon(Icons.highlight_remove,color: Colors.red),
                      label: Text(translateEng("Remove Period"),
                          style: const TextStyle(color: Colors.red)),
                      onPressed: () {
                        setState(() {
                          widget.periodData.removeAt(i);
                          widget.subject.teacherCodes.removeAt(i);
                          widget.subject.classrooms.removeAt(i);
                          widget.hours.removeAt(i);
                          widget.days.removeAt(i);
                          widget.bgnHour.removeAt(i);
                          widget.editingTeacher.removeAt(i);
                          widget.editingClassroom.removeAt(i);
                        });
                      }),
                ),
              ],
            ),
          )
        ],
        ),
      );
    }

    var v = convertDaysNHrs();
    List<List<int>> bgnPeriods = v[1], days = v[0];

    tiles.add(
      SizedBox(
        height: (MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * 0.1,
      )
    );
    tiles.add(
        ListTile(
          onTap: null,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: (MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * (Platform.isWindows ? 0.35 : 0.5),
                  height: (MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * (Platform.isWindows ? 0.35 : 0.5),
                  child: CustomPaint(painter:
                  TimetableCanvas(beginningPeriods: bgnPeriods, days: days, hours: widget.hours, isForSchedule: false, isForClassrooms: false, wantedPeriod: PeriodData.EMPTY)
                  )
              )
            ],
          ),
        )
    );
    var scrollController = ScrollController();

    return RawScrollbar(
      controller: scrollController,
      crossAxisMargin: 0.0,
      trackVisibility: true,
      thumbVisibility: true,
      thumbColor: Colors.blueGrey,
      trackBorderColor: Colors.white,
      radius: const Radius.circular(20),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: tiles,
          ),
        ),
      ),
    );

  }

  List<Widget> buildList(String teachers, int periodIndex, double width, int fieldNumber) { // 0 for teachers, 1 for classrooms

    List<Widget> bts = [];
    List<String> teachersList = teachers.split(',');
    teachersList = teachersList.where((element)  {
      return element.isNotEmpty;
    }).toList();

    String teacher;
    for (int teacherIndex = 0 ; teacherIndex < teachersList.length ; teacherIndex++) {
      teacher = teachersList[teacherIndex];

      // print("Index is $teacherIndex");
      bts.add(Visibility(
        visible: fieldNumber == 0 ? !widget.editingTeacher[periodIndex][teacherIndex] : !widget.editingClassroom[periodIndex][teacherIndex],
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 0.01 * width, vertical: 0.005 * width),
          child: TextButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 0.01 * width, horizontal: 0.02 * width)),
                backgroundColor: MaterialStateProperty.all(Colors.blue.shade400),
                overlayColor: MaterialStateProperty.all(const Color.fromRGBO(255, 255, 255, 0.2)),
              ),
              child: Text(teacher, style: const TextStyle(color: Colors.black)),
              onPressed: () {
                if (fieldNumber == 0 ? widget.showTeacherField[periodIndex] : widget.showClassroomField[periodIndex]) {
                  return;
                }
                setState(() {
                  if (fieldNumber == 0) {
                    widget.editingTeacher[periodIndex][teacherIndex] = true;
                    widget.showTeacherField[periodIndex] = true;
                  } else {
                    widget.editingClassroom[periodIndex][teacherIndex] = true;
                    widget.showClassroomField[periodIndex] = true;
                  }
                  widget.periodData[periodIndex][fieldNumber == 0 ? 0 : 1] = teacher;
                });
              }),
        ),
      ));
    }

    // Determine if it is adding or editing:
    int teacherInd;
    bool isEditing = false;
    teacherInd = 0;
    for (teacherInd = 0 ; teacherInd < (fieldNumber == 0 ? widget.editingTeacher[periodIndex].length : widget.editingClassroom[periodIndex].length) ; teacherInd++) {
      if (fieldNumber == 0 ? widget.editingTeacher[periodIndex][teacherInd] : widget.editingClassroom[periodIndex][teacherInd]) {
        isEditing = true;
        break;
      }
    }
    print("Editing mode $isEditing with index $teacherInd");

    bts.addAll([
      Visibility(
        visible: fieldNumber == 0 ? widget.showTeacherField[periodIndex] : widget.showClassroomField[periodIndex],
        child: SizedBox(
          width: width * 0.4,
          child: TextFieldWidget(
              text: isEditing ? (fieldNumber == 0 ? widget.subject.teacherCodes[periodIndex][teacherInd] : widget.subject.classrooms[periodIndex][teacherInd])
                  : widget.periodData[periodIndex][fieldNumber == 0 ? 0 : 1],
              onChanged: (str) { widget.periodData[periodIndex][fieldNumber == 0 ? 0 : 1] = str; }
              , hintText: fieldNumber == 0 ? "teacher name" : "classroom"),
        ),
      ),
      TextButton.icon(icon: Icon((fieldNumber == 0 ? widget.showTeacherField[periodIndex] : widget.showClassroomField[periodIndex]) ?
        Icons.check : Icons.add), label: const Text(""), onPressed: () {
        setState(() {
          if (isEditing) { // Editing:

            if (fieldNumber == 0) {
              widget.editingTeacher[periodIndex][teacherInd] = false;
              widget.showTeacherField[periodIndex] = false;
            } else {
              widget.editingClassroom[periodIndex][teacherInd] = false;
              widget.showClassroomField[periodIndex] = false;
            }

            if (widget.periodData[periodIndex][fieldNumber == 0 ? 0 : 1].isNotEmpty) { // 0 for teachers and 1 for classrooms
              if (fieldNumber == 0) {
                widget.subject.teacherCodes[periodIndex][teacherInd] = widget.periodData[periodIndex][fieldNumber == 0 ? 0 : 1];
              } else {
                widget.subject.classrooms[periodIndex][teacherInd] = widget.periodData[periodIndex][fieldNumber == 0 ? 0 : 1];
              }
              widget.periodData[periodIndex][fieldNumber == 0 ? 0 : 1] = "";
            } else {
              if (fieldNumber == 0) {
                widget.subject.teacherCodes[periodIndex].removeAt(teacherInd);
                widget.editingTeacher[periodIndex].removeAt(teacherInd);
              } else {
                widget.subject.classrooms[periodIndex].removeAt(teacherInd);
                widget.editingClassroom[periodIndex].removeAt(teacherInd);
              }
            }

          } else { // Adding:

            if (fieldNumber == 0 ? widget.showTeacherField[periodIndex] : widget.showClassroomField[periodIndex]) { // confirm
              if (widget.periodData[periodIndex][fieldNumber == 0 ? 0 : 1].isNotEmpty) {
                fieldNumber == 0 ?
                  (widget.subject.teacherCodes[periodIndex].add(widget.periodData[periodIndex][fieldNumber == 0 ? 0 : 1]))
                    :
                  (widget.subject.classrooms[periodIndex].add(widget.periodData[periodIndex][fieldNumber == 0 ? 0 : 1])); // 0 for teachers
                widget.periodData[periodIndex][fieldNumber == 0 ? 0 : 1] = "";
                fieldNumber == 0 ?
                  widget.editingTeacher[periodIndex].add(false)
                    :
                  widget.editingClassroom[periodIndex].add(false);
              }
            }
            fieldNumber == 0 ?  widget.showTeacherField[periodIndex] = !widget.showTeacherField[periodIndex]
                : widget.showClassroomField[periodIndex] = !widget.showClassroomField[periodIndex];
          }
        });
      }),
    ]);

    return bts;

  }

  List<Widget> buildDepList(String deps, double width) {

    List<Widget> bts = [];
    List<String> depList = deps.split(',');
    depList = depList.where((element)  {
      return element.isNotEmpty;
    }).toList();

    String teacher;
    for (int depIndex = 0 ; depIndex < depList.length ; depIndex++) {
      teacher = depList[depIndex];

      // print("Index is $depIndex");
      bts.add(Visibility(
        visible: !widget.editingDep[depIndex],
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 0.01 * width, vertical: 0.005 * width),
          child: TextButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 0.01 * width, horizontal: 0.02 * width)),
                backgroundColor: MaterialStateProperty.all(Colors.blue.shade400),
                overlayColor: MaterialStateProperty.all(const Color.fromRGBO(255, 255, 255, 0.2)),
              ),
              child: Text(teacher, style: const TextStyle(color: Colors.black)),
              onPressed: () {
                if (widget.showDepField) {
                  return;
                }
                setState(() {
                  widget.editingDep[depIndex] = true;
                  widget.showDepField = true;
                  //widget.periodData[periodIndex][fieldNumber == 0 ? 0 : 1] = teacher;
                });
              }),
        ),
      ));
    }

    // Determine if it is adding or editing:
    bool isEditing = false;
    int depInd;
    for (depInd = 0 ; depInd < widget.editingDep.length ; depInd++) {
      if (widget.editingDep[depInd]) {
        isEditing = true;
        break;
      }
    }
    print("Editing mode $isEditing with index $depInd");

    // print("PUTTING ${isEditing ? widget.subject.departments[depInd]
    //     : widget.depData} of bool $isEditing");

    if (isEditing) {
      widget.depData = widget.subject.departments[depInd];
    }

    bts.addAll([
      Visibility(
        visible: widget.showDepField,
        child: SizedBox(
          width: width * 0.4,
          child: TextFieldWidget(
              text: isEditing ? widget.subject.departments[depInd]
                  : widget.depData,
              onChanged: (str) { widget.depData = str; /*print("CHANGED INTO $str");*/ },
              hintText: translateEng("Department/Tag")),
        ),
      ),
      TextButton.icon(icon: Icon(widget.showDepField ?
      Icons.check : Icons.add), label: const Text(""), onPressed: () {
        setState(() {
          if (isEditing) { // Editing:

            widget.editingDep[depInd] = false;
            widget.showDepField = false;

            if (widget.depData.isNotEmpty) {
              widget.subject.departments[depInd] = widget.depData;
              widget.depData = "";
            } else {
              widget.subject.departments.removeAt(depInd);
              widget.editingDep.removeAt(depInd);
            }

          } else { // Adding:

            if (widget.showDepField) { // confirm
              if (widget.depData.isNotEmpty) {
                (widget.subject.departments.add(widget.depData)); // 0 for teachers
                widget.depData = "";
                widget.editingDep.add(false);
              }
            }
            widget.showDepField = !widget.showDepField;
          }
        });
      }),
    ]);

    return bts;

  }

  bool isThereCol() {

    var v = convertDaysNHrs();
    List<List<int>> listDays = v[0], listBgnHrs = v[1];

    List<List<int>> reservedPeriods = [];

    for (int i = 0 ; i < listDays.length ; i++) {
      for (int j = 0 ; j < listDays[i].length ; j++) {
        for (int l = 0 ; l < widget.hours[i] ; l++) { // I just had a mental break down writing this part of code
          for (int k = 0 ; k < reservedPeriods.length ; k++) {
            if (reservedPeriods[k][0] == listDays[i][j] && reservedPeriods[k][1] == (listBgnHrs[i][j] + l)) {
              return true;
            }
          }
          reservedPeriods.add([listDays[i][j], listBgnHrs[i][j] + l]);
        }
      }
    }

    return false;

  }

}
