import 'dart:io' show Platform;
import 'dart:ui';

import 'package:Atsched/others/university.dart';
import 'package:Atsched/widgets/emptycontainer.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';

import '../language/dictionary.dart';
import '../main.dart';
import '../others/subject.dart';
import '../widgets/timetable_canvas.dart';

class EmptyCoursesPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return EmptyCoursesState();
  }

}

class EmptyCoursesState extends State<EmptyCoursesPage> {

  String query = "";
  List<Classroom> classrooms_ = []; // to be changed according to the terms of the search

  List<String> days = ["Any", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
  String day = "Any";

  String bgnHr = "Any", endHr = "Any";

  List<Classroom> classrooms = []; // not to be changed!


  @override
  void initState() {

    super.initState();

    bool isClassroomFound = false;
    bool isPeriodFound = false;

    for (int subI = 0 ; subI < Main.facultyData.subjects.length ; subI++) {

      for (int periodI = 0 ; periodI < Main.facultyData.subjects[subI].days.length ; periodI++) {

        for (int classroomI = 0 ; classroomI < Main.facultyData.subjects[subI].classrooms[periodI].length ; classroomI++) {

          // print("${Main.facultyData.subjects[subI].days[periodI].length} ${Main.facultyData.subjects[subI].classrooms[periodI].length}");

          isClassroomFound = false;
          isPeriodFound = false;
          int atI = -1;
          for (int searchI = 0 ; searchI < classrooms.length ; searchI++) {
            atI = searchI;
            if (Main.facultyData.subjects[subI].classrooms[periodI][classroomI] == classrooms[searchI].classroom) {
              isClassroomFound = true;
              bool isFound = false;
              for (int a_ = 0 ; a_ < classrooms[searchI].days[0].length ; a_++) {
                if (Main.facultyData.subjects[subI].days[periodI].length > classroomI && Main.facultyData.subjects[subI].bgnPeriods[periodI].length > classroomI && classrooms[searchI].bgnPeriods[0].length > a_ &&
                    classrooms[searchI].days[0][a_] == Main.facultyData.subjects[subI].days[periodI][classroomI] &&
                    classrooms[searchI].bgnPeriods[0][a_] == Main.facultyData.subjects[subI].bgnPeriods[periodI][classroomI]) {
                  isFound = true;
                  if (classrooms[searchI].hours.length > a_ && classrooms[searchI].hours[a_] < Main.facultyData.subjects[subI].hours[periodI]) {
                    classrooms[searchI].hours[a_] = Main.facultyData.subjects[subI].hours[periodI];
                  }
                }
              }
              if (isFound) {
                isPeriodFound = true;
                break;
              }
            }
            if (isClassroomFound) {
              break;
            }
          }

          if (!isClassroomFound) {
            classrooms.add(Classroom(
              classroom: Main.facultyData.subjects[subI].classrooms[periodI][classroomI],
              days: [Main.facultyData.subjects[subI].days[periodI]],
              bgnPeriods: [Main.facultyData.subjects[subI].bgnPeriods[periodI]],
              hours: [Main.facultyData.subjects[subI].hours[periodI]],
            ));
          }

          if (atI != -1) {
            if (!isPeriodFound) { // not the issue, the issue is that no periods are being added from the other courses

              classrooms[atI].days.add([]);
              classrooms[atI].bgnPeriods.add([]);
              for (int i = 0 ; i < Main.facultyData.subjects[subI].days[periodI].length ; i++) {
                classrooms[atI].days[classrooms[atI].days.length - 1].add(Main.facultyData.subjects[subI].days[periodI][i]);
              }
              for (int i = 0 ; i < Main.facultyData.subjects[subI].bgnPeriods[periodI].length ; i++) {
                classrooms[atI].bgnPeriods[classrooms[atI].days.length - 1].add(Main.facultyData.subjects[subI].bgnPeriods[periodI][i]);
              }
              classrooms[atI].hours.add(Main.facultyData.subjects[subI].hours[periodI]);

            }
          }

        }

      }

    }

    classrooms_ = [...classrooms];

  }

  static TextEditingController txtController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    double width = (window.physicalSize / window.devicePixelRatio).width, height = (window.physicalSize / window.devicePixelRatio).height;

    ScrollController scrollController = ScrollController();
    return Scaffold(
      backgroundColor: Main.appTheme.scaffoldBackgroundColor,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight((MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * (Platform.isWindows ? 0.05 : 0.1)),
          child: AppBar(backgroundColor: Main.appTheme.headerBackgroundColor)),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all((MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * 0.03),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: width * 0.25,
                    child: TextFormField(
                      controller: txtController,
                      style: TextStyle(color: Main.appTheme.titleTextColor),
                      cursorColor: Main.appTheme.titleTextColor,
                      decoration: InputDecoration(
                        icon: Icon(Icons.search, color: txtController.text.isNotEmpty ? Colors.blue : Main.appTheme.titleTextColor),
                        hintStyle: TextStyle(color: Main.appTheme.hintTextColor),
                        hintText: ("E.g B1029, L3032"),
                        labelStyle: TextStyle(color: Main.appTheme.titleTextColor),
                        labelText: translateEng("SEARCH"),
                      ),
                      onChanged: search,
                    ),
                  ),
                  Row(
                    children: [
                      Platform.isWindows ?
                      Row(children: [Text(translateEng("Classrooms Found:  ${classrooms_.length}"), style: TextStyle(color: Main.appTheme.titleTextColor)),
                        SizedBox(
                          width: width * 0.03,
                        ) ],) : EmptyContainer(),
                      Visibility(
                        visible: day == "Any",
                        child: const Icon(Icons.warning, color: Colors.red),
                      ),
                      day == "Any" ? SizedBox(
                        width: width * 0.01,
                      ) : EmptyContainer(),
                      DropdownButton<String>(
                        dropdownColor: Main.appTheme.scaffoldBackgroundColor,
                        value: day,
                        items: days.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem(
                              value: value, child: Text(translateEng(value),
                              style: value == day ? TextStyle(color: day == "Any" ? Colors.red : Main.appTheme.titleTextColor,
                                  fontWeight: day == "Any" ? FontWeight.bold : FontWeight.normal) :
                              TextStyle(color: Main.appTheme.titleTextColor),
                          ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            day = newValue!;
                            search(query);
                          });
                        },
                      ),
                      SizedBox(
                        width: width * 0.02,
                      ),
                      (bgnHr == "Any" || endHr == "Any") ? const Icon(Icons.warning, color: Colors.red) : EmptyContainer(),
                      (bgnHr == "Any" || endHr == "Any") ? SizedBox(
                        width: width * 0.005,
                      ) : EmptyContainer(),
                      TextButton(
                        child: Text(
                          (bgnHr == "Any" || endHr == "Any") ? translateEng("Choose Period") : (bgnHr + " - " + endHr),
                          style: TextStyle(color: (bgnHr == "Any" || endHr == "Any") ? Colors.red : Colors.blue)),
                        onPressed: () {
                          showTimePicker(
                            hourLabelText: translateEng("Start Hour"),
                            minuteLabelText: translateEng("End Hour"),
                            helpText: translateEng("Choose Period"),
                            context: context,
                            initialTime: (bgnHr == "Any" || endHr == "Any") ?
                            TimeOfDay(hour: TimeOfDay.now().hour, minute: TimeOfDay.now().hour + 1) :
                            TimeOfDay(hour: int.parse(bgnHr.substring(0, bgnHr.indexOf(":"))), minute: int.parse(endHr.substring(0, endHr.indexOf(":")))),
                            initialEntryMode: TimePickerEntryMode.input,
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.dark(),
                                child: MediaQuery(
                                  data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), // it is not working, idk why
                                  child: (child! as TimePickerDialog),
                                ),
                              );
                            },
                          ).then((value) {
                            setState(() {
                              bgnHr = value!.hour.toString() + ":" + University.getBgnMinutes().toString();
                              endHr = value.minute.toString() + ":" + University.getEndMinutes().toString();
                            });
                          });

                        },
                      ),
                    ],
                  ),
                ],
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
                      controller: scrollController,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: classrooms_.length,
                      itemBuilder: (context, index) {
                        return buildClassrooms(index);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

  ListTile buildClassrooms(int index) {

    double width = (window.physicalSize / window.devicePixelRatio).width, height = (window.physicalSize / window.devicePixelRatio).height;

    String classroom = classrooms_[index].classroom;

    PeriodData period;
    if (day == "Any" || bgnHr == "Any" || endHr == "Any") {
      period = PeriodData.EMPTY;
    } else {
      period = PeriodData(day: stringToDay(day), bgnPeriod: University.stringToBgnPeriod(bgnHr), hours: University.stringToBgnPeriod(endHr) - University.stringToBgnPeriod(bgnHr));
    }

    return ListTile(
      title: Text(classroom, style: TextStyle(color: Main.appTheme.titleTextColor)),
      onTap: () {
        FocusScope.of(context).unfocus(); // NOTE: This hides the keyboard for once and for all when we choose a course!

        showAdaptiveActionSheet(
          bottomSheetColor: Main.appTheme.scaffoldBackgroundColor,
          context: context,
          title: Column(
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                  child: Center(child: Text(
                      classroom,
                      style: TextStyle(color: Main.appTheme.titleTextColor, fontSize: 16, fontWeight: FontWeight.bold),
                  )),
                ),
              ]
              ),
              SizedBox(
                height: height * 0.03,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: (Platform.isWindows ? 0.01 : 0.04) * width,
                          height: (Platform.isWindows ? 0.01 : 0.04) * width,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green
                          ),
                        ),
                        SizedBox(
                          width: width * 0.01,
                        ),
                        Text(translateEng("Requested Time"), style: TextStyle(color: Main.appTheme.titleTextColor)),
                      ],
                    ),
                    SizedBox(
                      width: width * 0.03,
                    ),
                    Row(
                      children: [
                        Container(
                          width: (Platform.isWindows ? 0.01 : 0.04) * width,
                          height: (Platform.isWindows ? 0.01 : 0.04) * width,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue
                          ),
                        ),
                        SizedBox(
                          width: width * 0.01,
                        ),
                        Text(translateEng("Reserved"), style: TextStyle(color: Main.appTheme.titleTextColor)),
                      ],
                    ),
                ],
              ),
              SizedBox(
                height: height * 0.03,
              ),
              SizedBox(
                  width: (MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * (Platform.isWindows ? 0.4 : 0.7),
                  height: (MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * (Platform.isWindows ? 0.4 : 0.7),
                  child: CustomPaint(painter:
                  TimetableCanvas(beginningPeriods: classrooms_[index].bgnPeriods, days: classrooms_[index].days, hours: classrooms_[index].hours, isForSchedule: false, isForClassrooms: true,
                      wantedPeriod: period))
              ),
            ],
          ),
          actions: [],
          cancelAction: CancelAction(title: const Text('Close')),
        );

      },
    );

  }

  void search(String query) {

    query = query.toLowerCase();
    query = convertTurkishToEnglish(query);

    List<Classroom> classrooms_ = classrooms.where((classroom) {

      String name = classroom.classroom;

      name = name.toLowerCase();
      name = convertTurkishToEnglish(name);

      return name.contains(query);

    }).toList();

    classrooms_ = searchByTime(classrooms_);

    setState(() {
      this.query = query;
      this.classrooms_ = classrooms_;
    });

  }

  List<Classroom> searchByTime(List<Classroom> rooms) {

    if ((day == "Any" && bgnHr == "Any" && endHr == "Any") || (bgnHr == "Any" || endHr == "Any")) {

      return rooms;

    } else {

      int dayToSearch;
      if (day != "Any") {
        dayToSearch = stringToDay(day);
      } else {
        dayToSearch = -1;
      }

      int bgnHrToSearch, endHrToSearch;
      if (bgnHr != "Any") {
        bgnHrToSearch = University.stringToBgnPeriod(bgnHr);
      } else {
        bgnHrToSearch = -1;
      }
      if (endHr != "Any") {
        endHrToSearch = University.stringToBgnPeriod(endHr);
      } else {
        endHrToSearch = -1;
      }

      int hours1;
      int bgnHour1;
      int hours2;
      int bgnHour2;

      bool isEmpty = true; // by default, it is not empty, try to find if the period we need has one period that is empty at the same time
      List<Classroom> rooms_ = rooms.where((classroom) {
        isEmpty = true;

        List<int> daysUsed = [];

        for (int i = 0 ; i < classroom.days.length ; i++) {
          for (int j = 0 ; j < classroom.days[i].length ; j++) {
            if (!daysUsed.contains(classroom.days[i][j])) {
              daysUsed.add(classroom.days[i][j]);
            }
          }
        }

        if (dayToSearch == -1) {
          bool emptyDayFound = false;
          for (int d = 1 ; d < 8 ; d++) {
            if (!daysUsed.contains(d)) {
              emptyDayFound = true;
              break;
            }
          }
          if (emptyDayFound) {
            return true;
          }
        }

        for (int i = 0 ; i < classroom.days.length ; i++) {
          for (int j = 0 ; j < classroom.days[i].length ; j++) {
            if (dayToSearch != -1 && classroom.bgnPeriods[i].length > j) {
              hours1 = endHrToSearch - bgnHrToSearch;
              bgnHour1 = bgnHrToSearch;
              hours2 = classroom.hours[i];
              bgnHour2 = classroom.bgnPeriods[i][j];
              if (
                  (bgnHour1 >= bgnHour2 && bgnHour1 < (bgnHour2 + hours2)) ||
                  ((bgnHour1 + hours1) > bgnHour2 && (bgnHour1 + hours1) < (bgnHour2 + hours2))
                    || (bgnHour2 >= bgnHour1 && bgnHour2 < (bgnHour1 + hours1)) ||
                      ((bgnHour2 + hours2) > bgnHour1 && (bgnHour2 + hours2) < (bgnHour1 + hours1))
                ) {
                if (dayToSearch == classroom.days[i][j]) {
                  isEmpty = false;
                  break;

                }
              }
            }
          }
          if (!isEmpty) {
            break;
          }
        }

        return isEmpty;

      }).toList();

      return rooms_;
    }

  }

}
