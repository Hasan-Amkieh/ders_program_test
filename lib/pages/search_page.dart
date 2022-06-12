import 'dart:ui';

import 'package:ders_program_test/language/dictionary.dart';
import 'package:ders_program_test/language/teacherdictionary.dart';
import 'package:ders_program_test/others/departments.dart';
import 'package:ders_program_test/others/subject.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/searchwidget.dart';
import 'package:fluttertoast/fluttertoast.dart';


class SearchPage extends StatefulWidget {

  const SearchPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SearchPageState();
  }

}

class SearchPageState extends State<SearchPage> {

  String query = "";
  List<Subject> subjects = Main.semesters[0].subjects;
  List<Subject> subjectsOfDep = Main.semesters[0].subjects;
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
      subjectsOfDep = Main.semesters[0].subjects.where((element) {

        return element.departments.toString().contains(depToSearch);

      }).toList();
      search(query); // Because the subjects list are now reset
    }
    else if (depToSearch == translateEng("All") && lastDep != depToSearch) {
      lastDep = depToSearch;
      subjectsOfDep = Main.semesters[0].subjects;
      search(query); // Because the subjects list are now reset
    }
    print("The query: $query");

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
              SearchWidget(
                text: query,
                hintText: translateEng("Course code, teacher name or classroom"),
                onChanged: search,
              ),
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

    String? name;
    if (sub.classCode.contains("(")) {
      name = Main.classcodes[sub.classCode.substring(0, sub.classCode.indexOf("("))];
    } else {
      name = Main.classcodes[sub.classCode];
    }
    String classrooms = "", teachers = "", departments = "";
    classrooms = sub.classrooms.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");
    departments = sub.departments.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");

    return ListTile(
      title: Text(sub.classCode),
      subtitle:
      Text((searchByCourseName ? (name ?? "") : "") +
          (searchByTeacher ? (sub.teachersTranslated.isEmpty ? "" : ("\n" + sub.teachersTranslated)) : "" ) +
          (searchByClassroom ? (classrooms.isEmpty ? "" : ("\n" + classrooms)) : "" )),
      onTap: () {
        teachers = sub.teachersTranslated;

        // TODO: Add a small table at the bottom to express the time and date of the course
        showDialog(context: context,
            builder: (context) => AlertDialog(
              title: Text(sub.classCode),
              content: Builder(
                builder: (context) {
                  return Container(
                      height: height * 0.4,
                      child: Scrollbar( // Just to make the scrollbar viewable
                        thumbVisibility: true,
                        child: ListView(
                          children: [
                            ListTile(
                              title: Row(children: [Expanded(child: Text(translateEng("Name: ") + name!))]),
                              onTap: null,
                            ),
                            ListTile(
                              title: Row(children: [Expanded(child: Text(translateEng("Classrooms: ") + classrooms))]),
                              onTap: null,
                            ),
                            ListTile(
                              title: Row(children: [Expanded(child: Text(translateEng("Teachers: ") + teachers))]),
                              onTap: null,
                            ),
                            ListTile(
                              title: Row(children: [Expanded(child: Text(translateEng("Departments: ") + departments))]),
                              onTap: null,
                           ),
                          ],
                        ),
                      )
                  );
                }
              ),
              actions: [
                TextButton(onPressed: () {
                  Navigator.pop(context);
                }, child: Text(translateEng("OK"))),
                TextButton(onPressed: () {
                  bool doesExist = false;
                  for (Subject sub_ in Main.scheduleCourses) {
                    if (sub_.classCode == sub.classCode) {
                      doesExist = true;
                    }
                  }

                  if (!doesExist) {
                    Main.scheduleCourses.add(sub);
                  }

                  Fluttertoast.showToast(
                      msg: translateEng(doesExist ? "The course is already in the schedule" : "Added to the current schedule"),
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.blue,
                      textColor: Colors.white,
                      fontSize: 12.0
                  );

                }, child: Text(translateEng("ADD TO SCHEDULE"))),

                TextButton(onPressed: () {
                  bool doesExist = false;
                  for (Subject sub_ in Main.favCourses) {
                    if (sub_.classCode == sub.classCode) {
                      doesExist = true;
                    }
                  }

                  if (!doesExist) {
                    Main.favCourses.add(sub);
                  }

                  Fluttertoast.showToast(
                      msg: translateEng(doesExist ? "The course is already a favourite" : "Added to favourite courses"),
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.blue,
                      textColor: Colors.white,
                      fontSize: 12.0
                  );

                }, child: Text(translateEng("ADD TO FAVOURITES")))
            ],
          ),
          );
        },
    );

  }

  void search(String query) {

    query = query.toLowerCase();
    query = convertTurkishToEnglish(query);

    final subjects = subjectsOfDep.where((subject) {

      if (searchByCourseName) {
        String? name;
        if (subject.classCode.contains("(")) {
          name = Main.classcodes[subject.classCode.substring(0, subject.classCode.indexOf("("))];
        } else {
          name = Main.classcodes[subject.classCode];
        }

        name = name!.toLowerCase();
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
