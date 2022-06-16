
import 'dart:ui';

import 'package:ders_program_test/language/dictionary.dart';
import 'package:ders_program_test/others/appthemes.dart';
import 'package:ders_program_test/others/subject.dart';
import 'package:ders_program_test/widgets/textfieldwidget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../main.dart';
import '../widgets/timetable_canvas.dart';

class CustomCoursePage extends StatefulWidget {

  Subject subject = Subject(classCode: "", departments: <String>[], teacherCodes: <List<String>>[[]], hours: <int>[], bgnPeriods: <List<int>>[], days: <List<int>>[], classrooms: <List<String>>[[]]);
  List<bool> areTilesOpen = [true];
  List<bool> showTeacherField = [false], showClassroomField = [false]; // by Periods
  List<bool> editingTeacher = [], editingClassroom = []; // by teachers inside that period
  List<List<String>> periodData = [["", ""]]; // Each list inside will have 2 strings, teacher names and classrooms accordingly
  List<String> days = ["Monday"], bgnHour = ["9:30"];
  List<int> hours = [1];
  String dep = "";

  static const Map<String, int> bgnHrToMaxHr = {
    "9:30" : 10,
    "10:30" : 9,
    "11:30" : 8,
    "12:30" : 7,
    "13:30" : 6,
    "14:30" : 5,
    "15:30" : 4,
    "16:30" : 3,
    "17:30" : 2,
    "18:30" : 1,
  };

  @override
  State<StatefulWidget> createState() {
    return CustomCoursePageState();
  }

  int getMaxHr(String bgnHour) {

    return bgnHrToMaxHr[bgnHour] ?? 1;

  }

}

class CustomCoursePageState extends State<CustomCoursePage> {

  @override
  Widget build(BuildContext context) {

    double width = (window.physicalSize / window.devicePixelRatio).width;
    double height = (window.physicalSize / window.devicePixelRatio).height;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(width * 0.05),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(translateEng("Course Name")),
                    SizedBox(
                        width: width * 0.6,
                        child: TextFieldWidget(text: "", onChanged: (str) { setState(() {widget.subject.customName = str;}); }, hintText: translateEng("e.g.   Basic English II"))
                    ),
                  ],
                ),
                //SizedBox(height: height * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Text(translateEng("Course Code")),
                  SizedBox(
                      width: width * 0.6,
                      child: TextFieldWidget(text: "", onChanged: (str) { setState(() {widget.subject.classCode = str;}); }, hintText: translateEng("e.g.   ENG102"))
                  ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(translateEng("Department/Tag")),
                    SizedBox(
                        width: width * 0.6,
                        child: TextFieldWidget(text: "", onChanged: (str) { setState(() {widget.dep = str;}); }, hintText: translateEng("e.g.   CMPE"))
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
                    child: buildPeriods(width),
                )
            ),
          ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text(translateEng("Add a period")),
                    onPressed: () {
                      setState(() {
                        for (int i = 0 ; i < widget.areTilesOpen.length ; i++) {
                        widget.areTilesOpen[i] = false;
                      }
                      widget.areTilesOpen.add(true);
                      widget.periodData.add(["", ""]);
                      widget.subject.teacherCodes.add([]);
                      widget.subject.classrooms.add([]);
                      widget.days.add("Monday");
                      widget.bgnHour.add("9:30");
                      widget.hours.add(1);

                      //widget.subject.teacherCodes.add([]);
                      /*widget.showTeacherField[i] = false;
                      widget.showClassroomField[i] = false;*/

                      widget.showTeacherField.add(false);
                      widget.showClassroomField.add(false);

                      });
                    })
                ],
                ),
                  Visibility(
                    child: Visibility(
                      visible: checkIfReadyToConfirm(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextButton.icon(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.blue),
                              overlayColor: MaterialStateProperty.all(const Color.fromRGBO(255, 255, 255, 0.2)),
                            ),
                              icon: const Icon(Icons.check, color: Colors.white),
                              label: const Text(""),
                              onPressed: () {
                              print("Executed!");

                                dynamic v = convertDaysNHrs();
                                List<List<int>> listDays = v[0], listBgnHrs = v[1];

                                widget.subject.days = listDays;
                                widget.subject.bgnPeriods = listBgnHrs;
                                widget.subject.hours.addAll(widget.hours);
                                widget.subject.departments.add(widget.dep);
                                // Check if the course code is already used or not:
                                bool isUsed = false;
                                String str = widget.subject.classCode.toLowerCase();
                                Main.currentSchedule.scheduleCourses.forEach((sub) {
                                  if (str == sub.subject.classCode.toLowerCase()) {
                                    isUsed = true;
                                    return ;
                                  }
                                });
                                if (isUsed) {
                                  Fluttertoast.showToast(
                                      msg: translateEng("The course code ") + "${widget.subject.classCode} " + translateEng("is already used"),
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.blue,
                                      textColor: Colors.white,
                                      fontSize: 12.0
                                  );
                                  return;
                                }

                                // For test:
                                //print("days: ${widget.subject.days} / bgnHours: ${widget.subject.bgnPeriods} / hours: ${widget.subject.hours}");

                                Main.currentSchedule.scheduleCourses.add(Course(note: "", subject: widget.subject));
                                Navigator.pop(context);
                              }
                          ),
                        ]),
                  ),
                )
        ],
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
      }

      switch(widget.bgnHour[i]) {
        case "9:30":
          listBgnHrs.add([1]);
          break;
        case "10:30":
          listBgnHrs.add([2]);
          break;
        case "11:30":
          listBgnHrs.add([3]);
          break;
        case "12:30":
          listBgnHrs.add([4]);
          break;
        case "13:30":
          listBgnHrs.add([5]);
          break;
        case "14:30":
          listBgnHrs.add([6]);
          break;
        case "15:30":
          listBgnHrs.add([7]);
          break;
        case "16:30":
          listBgnHrs.add([8]);
          break;
        case "17:30":
          listBgnHrs.add([9]);
          break;
        case "18:30":
          listBgnHrs.add([10]);
          break;
      }
    }

    return <List<List<int>>>[listDays, listBgnHrs];

  }

  bool checkIfReadyToConfirm() {

    bool isReady = true;

    if (widget.subject.customName.isEmpty) {
      return false;
    }
    if (widget.subject.classCode.isEmpty) {
      return false;
    }

    for (int i = 0 ; i < widget.periodData.length ; i++) {
      if (widget.subject.teacherCodes[i].isEmpty || widget.subject.classrooms[i].isEmpty) { // TODO: Check for the time and date variables
        isReady = false;
        break;
      }
    }

    return isReady;

  }


  Widget buildPeriods(double width) {

    List<Widget> tiles = [];

    for (int i = 0 ; i < widget.subject.teacherCodes.length ; i++) {
      tiles.add(ExpansionTile(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        //initiallyExpanded: widget.areTilesOpen[i], // It is not making any difference
        title: Text(translateEng("Period") + " ${i + 1}"),
        children: [
          Row(
            children: [
              Text(translateEng("Teachers"), style: AppThemes.headerStyle),
            ],
          ),
          Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: buildList(widget.subject.teacherCodes[i].toString().replaceAll(RegExp("[\\[.*?\\]]"), ""), i, width, true),
          ),

          // Classtooms:
          Row(
            children: [
              Text(translateEng("Classrooms"), style: AppThemes.headerStyle),
            ],
          ),
          Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: buildList(widget.subject.classrooms[i].toString().replaceAll(RegExp("[\\[.*?\\]]"), ""), i, width, false),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(translateEng("Day"), style: AppThemes.headerStyle),
              DropdownButton<String>(
                value: widget.days[i],
                onChanged: (newValue) {
                  setState(() {
                    widget.days[i] = newValue!;
                  });
                },
                items: [
                    DropdownMenuItem<String>(value: "Monday", child: Text(translateEng("Monday"))),
                    DropdownMenuItem<String>(value: "Tuesday", child: Text(translateEng("Tuesday"))),
                    DropdownMenuItem<String>(value: "Wednesday", child: Text(translateEng("Wednesday"))),
                    DropdownMenuItem<String>(value: "Thursday", child: Text(translateEng("Thursday"))),
                    DropdownMenuItem<String>(value: "Friday", child: Text(translateEng("Friday"))),
                    DropdownMenuItem<String>(value: "Saturday", child: Text(translateEng("Saturday"))),
                  ]),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(translateEng("Beginning Hour"), style: AppThemes.headerStyle),
              DropdownButton<String>(
                  value: widget.bgnHour[i],
                  onChanged: (newValue) {
                    setState(() {
                      if (widget.getMaxHr(newValue!) < widget.hours[i]) {
                        widget.hours[i] = widget.getMaxHr(newValue);
                      }
                      widget.bgnHour[i] = newValue;
                    });
                  },
                  items: const [
                    DropdownMenuItem<String>(value: "9:30", child: Text("9:30")),
                    DropdownMenuItem<String>(value: "10:30", child: Text("10:30")),
                    DropdownMenuItem<String>(value: "11:30", child: Text("11:30")),
                    DropdownMenuItem<String>(value: "12:30", child: Text("12:30")),
                    DropdownMenuItem<String>(value: "13:30", child: Text("13:30")),
                    DropdownMenuItem<String>(value: "14:30", child: Text("14:30")),
                    DropdownMenuItem<String>(value: "15:30", child: Text("15:30")),
                    DropdownMenuItem<String>(value: "16:30", child: Text("16:30")),
                    DropdownMenuItem<String>(value: "17:30", child: Text("17:30")),
                    DropdownMenuItem<String>(value: "18:30", child: Text("18:30")),
                  ]),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(translateEng("Class Length (hours)"), style: AppThemes.headerStyle),
              Row(
                children: [
                  SizedBox(
                    width: 0.08 * width,
                    height: 0.08 * width,
                    child: Container( // This container was put because we are not allowed to put two FABs inside the same subtree..
                      child: FloatingActionButton(child: const Icon(Icons.remove), onPressed: () {
                        setState(() {
                          if (widget.hours[i] == 1) return;
                          widget.hours[i] = widget.hours[i] - 1;
                          Main.saveSettings();
                        });
                      }),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.03,
                    height: width * 0.03,
                  ),
                  Text("${widget.hours[i]}"),
                  SizedBox(
                    width: width * 0.03,
                    height: width * 0.03,
                  ),
                  SizedBox(
                    width: 0.08 * width,
                    height: 0.08 * width,
                    child: FloatingActionButton(child: const Icon(Icons.add), onPressed: () {
                      setState(() {
                        if (widget.hours[i] == (widget.getMaxHr(widget.bgnHour[i]))) return;
                        widget.hours[i] = widget.hours[i] + 1;
                        Main.saveSettings();
                      });
                    }),
                  )
                ],
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
                  });
                }),
          ),
        ],
        ),
      );
    }

    dynamic v = convertDaysNHrs();
    List<List<int>> bgnPeriods = v[1], days = v[0];

    tiles.add(
      SizedBox(
        height: width * 0.1,
      )
    );
    tiles.add(
        ListTile(
          onTap: null,
          title: Container(width: width * 0.5, height: width * 0.5, child: CustomPaint(painter:
          TimetableCanvas(beginningPeriods: bgnPeriods, days: days, hours: widget.hours))),

        )
    );

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: tiles,
      ),
    );

  }

  List<Widget> buildList(String teachers, int periodIndex, double width, bool isForTeacher) {

    List<Widget> bts = [];
    List<String> teachersList = teachers.split(',');
    teachersList = teachersList.where((element)  {
      return element.isNotEmpty;
    }).toList();

    String teacher;
    for (int teacherIndex = 0 ; teacherIndex < teachersList.length ; teacherIndex++) {
      teacher = teachersList[teacherIndex];

      //print("Index is $teacherIndex");
      bts.add(Visibility(
        visible: isForTeacher ? !widget.editingTeacher[teacherIndex] : !widget.editingClassroom[teacherIndex],
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 0.01 * width),
          child: TextButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 0.01 * width, horizontal: 0.02 * width)),
                backgroundColor: MaterialStateProperty.all(Colors.blue.shade400),
                overlayColor: MaterialStateProperty.all(const Color.fromRGBO(255, 255, 255, 0.2)),
              ),
              child: Text(teacher, style: const TextStyle(color: Colors.black)),
              onPressed: () {
                if (isForTeacher ? widget.showTeacherField[periodIndex] : widget.showClassroomField[periodIndex]) {
                  return;
                }
                setState(() {
                  if (isForTeacher) {
                    widget.editingTeacher[teacherIndex] = true;
                    widget.showTeacherField[periodIndex] = true;
                  } else {
                    widget.editingClassroom[teacherIndex] = true;
                    widget.showClassroomField[periodIndex] = true;
                  }
                  widget.periodData[periodIndex][isForTeacher ? 0 : 1] = teacher;
                });
              }),
        ),
      ));
    }

    // Determine if it is adding or editing:
    int teacherInd;
    bool isEditing = false;
    teacherInd = 0;
    for (teacherInd = 0 ; teacherInd < (isForTeacher ? widget.editingTeacher.length : widget.editingClassroom.length) ; teacherInd++) {
      if (isForTeacher ? widget.editingTeacher[teacherInd] : widget.editingClassroom[teacherInd]) {
        isEditing = true;
        break;
      }
    }
    //print("Editing mode $isEditing with index $teacherInd");

    bts.addAll([
      Visibility(
        visible: isForTeacher ? widget.showTeacherField[periodIndex] : widget.showClassroomField[periodIndex],
        child: SizedBox(
          width: width * 0.4,
          child: TextFieldWidget(
              text: isEditing ? (isForTeacher ? widget.subject.teacherCodes[periodIndex][teacherInd] : widget.subject.classrooms[periodIndex][teacherInd])
                  : widget.periodData[periodIndex][isForTeacher ? 0 : 1],
              onChanged: (str) { widget.periodData[periodIndex][isForTeacher ? 0 : 1] = str; }
              , hintText: ""),
        ),
      ),
      TextButton.icon(icon: Icon((isForTeacher ? widget.showTeacherField[periodIndex] : widget.showClassroomField[periodIndex]) ?
        Icons.check : Icons.add), label: const Text(""), onPressed: () {
        setState(() {
          if (isEditing) { // Editing:

            if (isForTeacher) {
              widget.editingTeacher[teacherInd] = false;
              widget.showTeacherField[periodIndex] = false;
            } else {
              widget.editingClassroom[teacherInd] = false;
              widget.showClassroomField[periodIndex] = false;
            }

            if (widget.periodData[periodIndex][isForTeacher ? 0 : 1].isNotEmpty) { // 0 for teachers and 1 for classrooms
              if (isForTeacher) {
                widget.subject.teacherCodes[periodIndex][teacherInd] = widget.periodData[periodIndex][isForTeacher ? 0 : 1];
              } else {
                widget.subject.classrooms[periodIndex][teacherInd] = widget.periodData[periodIndex][isForTeacher ? 0 : 1];
              }
              widget.periodData[periodIndex][isForTeacher ? 0 : 1] = "";
            } else {
              if (isForTeacher) {
                widget.subject.teacherCodes[periodIndex].removeAt(teacherInd);
                widget.editingTeacher.removeAt(teacherInd);
              } else {
                widget.subject.classrooms[periodIndex].removeAt(teacherInd);
                widget.editingClassroom.removeAt(teacherInd);
              }
            }

          } else { // Adding:

            if (isForTeacher ? widget.showTeacherField[periodIndex] : widget.showClassroomField[periodIndex]) { // confirm
              if (widget.periodData[periodIndex][isForTeacher ? 0 : 1].isNotEmpty) {
                isForTeacher ?
                  (widget.subject.teacherCodes[periodIndex].add(widget.periodData[periodIndex][isForTeacher ? 0 : 1]))
                    :
                  (widget.subject.classrooms[periodIndex].add(widget.periodData[periodIndex][isForTeacher ? 0 : 1])); // 0 for teachers
                widget.periodData[periodIndex][isForTeacher ? 0 : 1] = "";
                isForTeacher ?
                  widget.editingTeacher.add(false)
                    :
                  widget.editingClassroom.add(false);
              }
            }
            isForTeacher ?  widget.showTeacherField[periodIndex] = !widget.showTeacherField[periodIndex]
                : widget.showClassroomField[periodIndex] = !widget.showClassroomField[periodIndex];
          }
        });
      }),
    ]);

    return bts;

  }

}
