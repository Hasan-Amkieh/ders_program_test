import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:Atsched/others/university.dart';
import 'package:Atsched/widgets/emptycontainer.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:Atsched/language/dictionary.dart';
import 'package:Atsched/language/teacherdictionary.dart';
import 'package:Atsched/others/subject.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';

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
    deps.addAll(University.getFacultyDeps(Main.faculty).keys);
    deps.add(depToSearch);
  }

  static TextEditingController txtController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    double width = (window.physicalSize / window.devicePixelRatio).width, height = (window.physicalSize / window.devicePixelRatio).height;
    // print("Putting ${subjects.length} subjects into the page");

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
      backgroundColor: Main.appTheme.scaffoldBackgroundColor,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight((MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * (Platform.isWindows ? 0.05 : 0.1)),
          child: AppBar(backgroundColor: Main.appTheme.headerBackgroundColor)),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all((MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * 0.03),
          child: Column(
            children: [
              University.areDepsSupported() ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(translateEng("Only search courses for this department"), style: TextStyle(color: Main.appTheme.titleTextColor)),
                  DropdownButton<String>(
                    dropdownColor: Main.appTheme.scaffoldBackgroundColor,
                    value: depToSearch,
                    items: deps.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem(value: value, child: Text(value, style: TextStyle(color: Main.appTheme.titleTextColor))
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        depToSearch = newValue!;
                      });
                    },
                  )
                ],
              ) : EmptyContainer(),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(translateEng("Search for  "), style: TextStyle(fontSize: 12, color: Main.appTheme.titleTextColor)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(translateEng("course name/code"), style: TextStyle(fontSize: 10, color: Main.appTheme.titleTextColor)),
                        Checkbox(value: searchByCourseName, onChanged: (newVal) {
                          setState(() {
                            if (!searchByClassroom && !searchByTeacher) {
                              return;
                            }
                            if (query.isNotEmpty) { // redo the query if it was not empty:
                              searchByCourseName = newVal!;
                              search(query);
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
                        Text(translateEng("teacher"), style: TextStyle(fontSize: 10, color: Main.appTheme.titleTextColor)),
                        Checkbox(value: searchByTeacher, onChanged: (newVal) {
                          setState(() {
                            if (!searchByClassroom && !searchByCourseName) {
                              return;
                            }
                            if (query.isNotEmpty) { // redo the query if it was not empty:
                              searchByTeacher = newVal!;
                              search(query);
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
                        Text(translateEng("classroom"), style: TextStyle(fontSize: 10, color: Main.appTheme.titleTextColor)),
                        Checkbox(value: searchByClassroom, onChanged: (newVal) {
                          setState(() {
                            if (!searchByCourseName && !searchByTeacher) {
                              return;
                            }
                            if (query.isNotEmpty) { // redo the query if it was not empty:
                              searchByClassroom = newVal!;
                              search(query);
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
                controller: txtController,
                style: TextStyle(color: Main.appTheme.titleTextColor),
                cursorColor: Main.appTheme.titleTextColor,
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: txtController.text.isNotEmpty ? Colors.blue : Main.appTheme.titleTextColor),
                  hintStyle: TextStyle(color: Main.appTheme.hintTextColor),
                  hintText: (searchByCourseName ? (translateEng("Course Code") + ", ") : "") + (searchByTeacher ? (translateEng("Teacher Name") + translateEng(" or ")) : "") + (searchByClassroom ? translateEng("classroom") : ""),
                  labelStyle: TextStyle(color: Main.appTheme.titleTextColor),
                  labelText: translateEng("SEARCH"),
                ),
                onChanged: search,
              ),
              SizedBox(height: height * 0.03),
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
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      return buildSubject(subjects[index]);
                    },
                  ),
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

    List<String> classroomsList = classrooms.split(", ");
    // Refine the classrooms if they do have any collisions delete them:
    for (int i = 0 ; i < classroomsList.length ; i++) {
      for (int j = 0 ; j < classroomsList.length ; j++) {
        if (i != j && classroomsList[i] == classroomsList[j]) {
          classroomsList.removeAt(j);
          if (j >= classroomsList.length) {
            j--;
          }
          if (i >= classroomsList.length) {
            i--;
            if (i < 0) {
              break;
            }
          }
        }
      }
    }

    classrooms = classroomsList.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");

    return ListTile(
      title: Text(sub.courseCode, style: TextStyle(color: Main.appTheme.titleTextColor)),
      subtitle:
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text((searchByCourseName ? name : "") +
                (searchByTeacher ? (sub.getTranslatedTeachers().isEmpty ? "" : ("\n" + sub.getTranslatedTeachers())) : "" ) +
                (searchByClassroom ? (classrooms.isEmpty ? "" : ("\n" + classrooms)) : "" ), style: TextStyle(color: Main.appTheme.titleTextColor)),
          ),
          Row(
            children: [
              sub.hours.isEmpty ? const Icon(CupertinoIcons.time_solid, color: Colors.red) : Container(),
              (sub.courseCode.contains("lab") || sub.courseCode.contains("Lab") || sub.courseCode.contains("LAB") || sub.courseCode.contains("/")) ?
              Container() : TextButton(child: const Icon(Icons.info_outline, color: Colors.blue), onPressed: () async {

                String url = "";

                var request = await HttpClient().getUrl(Uri.parse('https://www.atilim.edu.tr/get-lesson-ects/' + sub.getCourseCodeWithoutSectionNumber().replaceAll(" ", "")));
                var response = await request.close();
                await for (var contents in response.transform(const Utf8Decoder())) {
                  url = contents;
                }

                // print("Launching : ${url}");
                if (await canLaunchUrl(Uri.parse(url))) {
                  launchUrl(Uri.parse(url));
                } else {
                  showToast(
                    translateEng("The syllabus could not be found"),
                    duration: const Duration(milliseconds: 1500),
                    position: ToastPosition.bottom,
                    backgroundColor: Colors.red.withOpacity(0.8),
                    radius: 100.0,
                    textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
                  );
                }
              }, onLongPress: () {

                showToast(
                  sub.getCourseCodeWithoutSectionNumber() + " " + translateEng("Syllabus"),
                  duration: const Duration(milliseconds: 1000),
                  position: ToastPosition.bottom,
                  backgroundColor: Colors.blue.withOpacity(0.8),
                  radius: 100.0,
                  textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
                );

              },
              ),
            ],
          ),
        ],
      ),
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

        List<String> deps = departments.split(",");
        List<TextSpan> depsText = [];
        deps.forEach((dep) {
          depsText.add(TextSpan(
            text: dep + "  ",
            style: TextStyle(
                color: (dep.contains(Main.department) ? Colors.green.shade800 : Main.appTheme.titleTextColor),
                fontWeight: (dep.contains(Main.department) ? FontWeight.bold : FontWeight.normal)
            ),
          ));
        });

        String cName = name; // for now it is only for Bilkent
        switch (Main.uni) {
          case "Bilkent": // An exception
            cName = sub.courseCode + " " + name;
            break;
        }

        showAdaptiveActionSheet(
          bottomSheetColor: Main.appTheme.scaffoldBackgroundColor,
          context: context,
          title: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                  child: Center(child: Text(cName, style: TextStyle(color: Main.appTheme.titleTextColor, fontSize: 16, fontWeight: FontWeight.bold))),
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
                      Expanded(child: Container(padding: EdgeInsets.fromLTRB(width * 0.05, 0, 0, 0), child: RichText(text: TextSpan(children: depsText)))),
                    ]
                ),
              ),
              SizedBox(
                height: height * 0.03,
              ),
              (sub.days.isNotEmpty && sub.bgnPeriods.isNotEmpty && sub.hours.isNotEmpty) ?
              SizedBox(
                  width: (MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * (Platform.isWindows ? 0.4 : 0.7),
                  height: (MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * (Platform.isWindows ? 0.4 : 0.7),
                  child: CustomPaint(painter:
              TimetableCanvas(beginningPeriods: sub.bgnPeriods, days: sub.days, hours: sub.hours, isForSchedule: false, isForClassrooms: false, wantedPeriod: PeriodData.EMPTY))
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
                  showToast(
                    sub.courseCode + " " + translateEng("was added to the schedule"),
                    duration: const Duration(milliseconds: 1500),
                    position: ToastPosition.bottom,
                    backgroundColor: Colors.blue.withOpacity(0.8),
                    radius: 100.0,
                    textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
                  );
                } else {
                  showToast(
                    sub.courseCode + " " + translateEng("is already in the schedule"),
                    duration: const Duration(milliseconds: 1500),
                    position: ToastPosition.bottom,
                    backgroundColor: Colors.blue.withOpacity(0.8),
                    radius: 100.0,
                    textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
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
                  showToast(
                    sub.courseCode + " " + translateEng("was added to favourites"),
                    duration: const Duration(milliseconds: 1500),
                    position: ToastPosition.bottom,
                    backgroundColor: Colors.blue.withOpacity(0.8),
                    radius: 100.0,
                    textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
                  );
                } else {
                  showToast(
                    sub.courseCode + " " + translateEng("is already a favourite"),
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

        name = subject.courseCode;

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
            if (convertTurkishToEnglish(translateTeacher(teacherCode: teacherCode, subject: subject).toLowerCase()).contains(query)) {
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
