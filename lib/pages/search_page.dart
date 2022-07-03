import 'dart:ui';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:ders_program_test/language/dictionary.dart';
import 'package:ders_program_test/language/teacherdictionary.dart';
import 'package:ders_program_test/others/departments.dart';
import 'package:ders_program_test/others/subject.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/searchwidget.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../widgets/timetable_canvas.dart';


class SearchPage extends StatefulWidget {

  const SearchPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SearchPageState();
  }

}

class SearchPageState extends State<SearchPage> {

  String query = "";
  List<Subject> subjects = Main.facultyData.subjects;
  List<Subject> subjectsOfDep = Main.facultyData.subjects;
  List<String> deps = [];
  String depToSearch = translateEng("All");
  String lastDep = translateEng("All");
  bool searchByCourseName = true, searchByTeacher = false, searchByClassroom = false;

  @protected
  @mustCallSuper
  void initState() {
    deps.addAll(faculties[Main.faculty]!.keys);
    deps.add(depToSearch);
  }

  @override
  Widget build(BuildContext context) {

    double width = (window.physicalSize / window.devicePixelRatio).width, height = (window.physicalSize / window.devicePixelRatio).height;
    print("Putting ${subjects.length} subjects into the page");

    if (depToSearch != translateEng("All") && lastDep != depToSearch) {
      lastDep = depToSearch;
      subjectsOfDep = Main.facultyData.subjects.where((element) {

        return element.departments.toString().contains(depToSearch);

      }).toList();
      search(query); // Because the subjects list are now reset
    }
    else if (depToSearch == translateEng("All") && lastDep != depToSearch) {
      lastDep = depToSearch;
      subjectsOfDep = Main.facultyData.subjects;
      search(query); // Because the subjects list are now reset
    }
    //print("The query: $query");

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(width * 0.03),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(translateEng("Only search courses for this department")),
                  DropdownButton<String>(
                    value: depToSearch,
                    items: deps.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem(value: value, child: Text(value)
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        depToSearch = newValue!;
                      });
                    },
                  )
                ],
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(translateEng("Search for  "), style: const TextStyle(fontSize: 12)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(translateEng("course name"), style: const TextStyle(fontSize: 10)),
                        Checkbox(value: searchByCourseName, onChanged: (newVal) {
                          setState(() {
                            if (!searchByClassroom && !searchByTeacher) {
                              return;
                            }
                            searchByCourseName = newVal!;
                          });
                        }),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(translateEng("teacher"), style: const TextStyle(fontSize: 10)),
                        Checkbox(value: searchByTeacher, onChanged: (newVal) {
                          setState(() {
                            if (!searchByClassroom && !searchByCourseName) {
                              return;
                            }
                            searchByTeacher = newVal!;
                          });
                        }),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(translateEng("classroom"), style: const TextStyle(fontSize: 10)),
                        Checkbox(value: searchByClassroom, onChanged: (newVal) {
                          setState(() {
                            if (!searchByCourseName && !searchByTeacher) {
                              return;
                            }
                            searchByClassroom = newVal!;
                          });
                        })
                      ],
                    ),
                  ],
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: (searchByCourseName ? (translateEng("Course Code") + ", ") : "") + (searchByTeacher ? (translateEng("Teacher Name") + ", ") : "") + (searchByClassroom ? translateEng("classroom") : ""),
                  labelText: translateEng("SEARCH"),
                ),
                onChanged: search,
              ),
              SizedBox(height: height * 0.03),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    return buildSubject(subjects[index]);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );

  }

  ListTile buildSubject(Subject sub) {

    double width = (window.physicalSize / window.devicePixelRatio).width, height = (window.physicalSize / window.devicePixelRatio).height;

    String name = sub.customName;
    String classrooms = "", teachers = "", departments = "";
    classrooms = sub.classrooms.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");
    departments = sub.departments.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");

    return ListTile(
      title: Text(sub.classCode),
      subtitle:
      Text((searchByCourseName ? name : "") +
          (searchByTeacher ? (sub.getTranslatedTeachers().isEmpty ? "" : ("\n" + sub.getTranslatedTeachers())) : "" ) +
          (searchByClassroom ? (classrooms.isEmpty ? "" : ("\n" + classrooms)) : "" )),
      onTap: () {
        FocusScope.of(context).unfocus(); // NOTE: This hides the keyboard for once and for all when we choose a course!

        teachers = sub.getTranslatedTeachers();

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
          context: context,
          title: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                  child: Center(child: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
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
                  classrooms.isNotEmpty ? const Icon(CupertinoIcons.placemark_fill) : Container(width: 0),
                  Expanded(child: Container(padding: EdgeInsets.fromLTRB(width * 0.05, 0, 0, 0), child: Text(classrooms))),
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
                      teachers.isNotEmpty ? const Icon(CupertinoIcons.group_solid) : Container(),
                      Expanded(child: Container(padding: EdgeInsets.fromLTRB(width * 0.05, 0, 0, 0), child: Text(teachers))),
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
                      departments.isNotEmpty ? const Icon(CupertinoIcons.building_2_fill) : Container(),
                      Expanded(child: Container(padding: EdgeInsets.fromLTRB(width * 0.05, 0, 0, 0), child: Text(departments))),
                    ]
                ),
              ),
              SizedBox(
                height: height * 0.03,
              ),
              (sub.days.isNotEmpty && sub.bgnPeriods.isNotEmpty && sub.hours.isNotEmpty) ?
              Container(width: width * 0.7, height: width * 0.7, child: CustomPaint(painter:
              TimetableCanvas(beginningPeriods: sub.bgnPeriods, days: sub.days, hours: sub.hours, isForSchedule: false))
              ) : Container(),
            ],
          ),
          actions: [
            BottomSheetAction(
              title: Text(translateEng("ADD TO SCHEDULE"), style: const TextStyle(color: Colors.blue, fontSize: 16)),
              onPressed: () {
                bool isFound = false;
                for (int i = 0 ; i < Main.schedules[Main.currentScheduleIndex].scheduleCourses.length ; i++) {
                  if (Main.schedules[Main.currentScheduleIndex].scheduleCourses[i].subject.isEqual(sub)) {
                    isFound = true;
                  }
                }
                if (!isFound) {
                  Main.schedules[Main.currentScheduleIndex].scheduleCourses.add(Course(note: "", subject: sub));
                  Fluttertoast.showToast(
                      msg: sub.classCode + " " + translateEng("was added to the schedule"),
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.blue,
                      textColor: Colors.white,
                      fontSize: 12.0
                  );
                } else {
                  Fluttertoast.showToast(
                      msg: sub.classCode + " " + translateEng("is already in the schedule"),
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.blue,
                      textColor: Colors.white,
                      fontSize: 12.0
                  );
                }
              },
            ),
            BottomSheetAction(
              title: Text(translateEng("ADD TO FAVOURITES"), style: const TextStyle(color: Colors.blue, fontSize: 16)),
              onPressed: () {
                bool isFound = false;
                for (int i = 0 ; i < Main.favCourses.length ; i++) {
                  if (Main.favCourses[i].subject.isEqual(sub)) {
                    isFound = true;
                  }
                }
                if (!isFound) {
                  Main.favCourses.add(Course(note: "", subject: sub));
                  Fluttertoast.showToast(
                      msg: sub.classCode + " " + translateEng("was added to favourites"),
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.blue,
                      textColor: Colors.white,
                      fontSize: 12.0
                  );
                } else {
                  Fluttertoast.showToast(
                      msg: sub.classCode + " " + translateEng("is already a favourite"),
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.blue,
                      textColor: Colors.white,
                      fontSize: 12.0
                  );
                }
              },
            ),
          ],
          cancelAction: CancelAction(title: const Text('Close')),
        );

        },
    );

  }

  void search(String query) {

    query = query.toLowerCase();
    query = convertTurkishToEnglish(query);

    final subjects = subjectsOfDep.where((subject) {

      if (searchByCourseName) {
        String name = subject.customName;

        name = name.toLowerCase();
        name = convertTurkishToEnglish(name);
        if (name.contains(query)) {
          return true;
        }
      }

      bool isFound = false;
      if (searchByTeacher) {
        subject.teacherCodes.forEach((list) {
          list.forEach((teacherCode) {
            if (isFound) {
              return ;
            }
            if (convertTurkishToEnglish(translateTeacher(teacherCode).toLowerCase()).contains(query)) {
              isFound = true;
              return ;
            }
          });
        });
        if (isFound) {
          return true;
        }
      }

      if (searchByClassroom) {
        subject.classrooms.forEach((list) {
          list.forEach((classroom) {
            if (isFound) {
              return ;
            }
            if (convertTurkishToEnglish(classroom.toLowerCase()).contains(query)) {
              isFound = true;
              return ;
            }
          });
        });
        if (isFound) {
          return true;
        }
      }

      return false;

    }).toList();

    setState(() {
      this.query = query;
      this.subjects = subjects;
    });

  }

}
