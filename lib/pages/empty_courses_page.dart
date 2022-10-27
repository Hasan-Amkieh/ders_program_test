import 'dart:io' show Platform;
import 'dart:ui';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

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

  List<String> bgnHrs = ["Any", "9:30", "10:30", "11:30", "12:30", "13:30", "14:30", "15:30", "16:30", "17:30", "18:30"];
  List<String> endHrs = ["Any", "9:20", "10:20", "11:20", "12:20", "13:20", "14:20", "15:20", "16:20", "17:20", "18:20"];
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
                  if (classrooms[searchI].hours[a_] < Main.facultyData.subjects[subI].hours[periodI]) {
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

  @override
  Widget build(BuildContext context) {

    double width = (window.physicalSize / window.devicePixelRatio).width, height = (window.physicalSize / window.devicePixelRatio).height;

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
                      style: TextStyle(color: Main.appTheme.titleTextColor),
                      cursorColor: Main.appTheme.titleTextColor,
                      decoration: InputDecoration(
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
                      DropdownButton<String>(
                        dropdownColor: Main.appTheme.scaffoldBackgroundColor,
                        value: day,
                        items: days.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem(value: value, child: Text(translateEng(value), style: TextStyle(color: Main.appTheme.titleTextColor))
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
                        width: width * 0.04,
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              Text(translateEng("From"), style: TextStyle(color: Main.appTheme.titleIconColor)),
                              SizedBox(
                                width: 0.01 * width,
                              ),
                              DropdownButton<String>(
                                dropdownColor: Main.appTheme.scaffoldBackgroundColor,
                                value: bgnHr,
                                items: bgnHrs.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem(value: value, child: Text(translateEng(value), style: TextStyle(color: Main.appTheme.titleTextColor))
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  String newBgnHr = newValue ?? "Any";
                                  if (newValue != "Any" && endHr != "Any") {
                                    if (int.parse(newBgnHr.substring(0, newBgnHr.indexOf(":"))) < int.parse(endHr.substring(0, endHr.indexOf(":")))) {
                                      setState(() {
                                        bgnHr = newValue!;
                                        search(query);
                                      });
                                    } else {
                                      showToast(
                                        translateEng("Beginning Hour cannot exceed " + endHr.toString()),
                                        duration: const Duration(milliseconds: 1500),
                                        position: ToastPosition.bottom,
                                        backgroundColor: Colors.blue.withOpacity(0.8),
                                        radius: 100.0,
                                        textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
                                      );
                                    }
                                  } else if (newValue == "Any" || endHr == "Any") {
                                    setState(() {
                                      bgnHr = newValue!;
                                      search(query);
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(translateEng("Until"), style: TextStyle(color: Main.appTheme.titleIconColor)),
                              SizedBox(
                                width: 0.01 * width,
                              ),
                              DropdownButton<String>(
                                dropdownColor: Main.appTheme.scaffoldBackgroundColor,
                                value: endHr,
                                items: endHrs.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem(value: value, child: Text(translateEng(value), style: TextStyle(color: Main.appTheme.titleTextColor))
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {

                                  String newBgnHr = newValue ?? "Any";
                                  if (newValue != "Any" && bgnHr != "Any") {
                                    if (int.parse(newBgnHr.substring(0, newBgnHr.indexOf(":"))) > int.parse(bgnHr.substring(0, bgnHr.indexOf(":")))) {
                                      setState(() {
                                        endHr = newValue!;
                                        search(query);
                                      });
                                    } else {
                                      showToast(
                                        translateEng("Ending Hour cannot precede " + bgnHr.toString()),
                                        duration: const Duration(milliseconds: 1500),
                                        position: ToastPosition.bottom,
                                        backgroundColor: Colors.blue.withOpacity(0.8),
                                        radius: 100.0,
                                        textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
                                      );
                                    }
                                  } else if (newValue == "Any" || bgnHr == "Any") {
                                    setState(() {
                                      endHr = newValue!;
                                      search(query);
                                    });
                                  }

                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: RawScrollbar(
                  crossAxisMargin: 0.0,
                  trackVisibility: true,
                  thumbVisibility: true,
                  thumbColor: Colors.blueGrey,
                  // trackColor: Colors.redAccent.shade700,
                  trackBorderColor: Colors.white,
                  radius: const Radius.circular(20),
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: classrooms_.length,
                    itemBuilder: (context, index) {
                      return buildClassrooms(index);
                    },
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
      period = PeriodData(day: stringToDay(day), bgnPeriod: stringToBgnPeriod(bgnHr), hours: stringToEndPeriod(endHr) - stringToBgnPeriod(bgnHr));
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
                          width: 0.01 * width,
                          height: 0.01 * width,
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
                          width: 0.01 * width,
                          height: 0.01 * width,
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
        bgnHrToSearch = stringToBgnPeriod(bgnHr);
      } else {
        bgnHrToSearch = -1;
      }
      if (endHr != "Any") {
        endHrToSearch = stringToEndPeriod(endHr);
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
            if (dayToSearch != -1) {
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
