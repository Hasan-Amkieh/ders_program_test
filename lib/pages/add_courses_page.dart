import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../language/dictionary.dart';
import '../main.dart';
import '../others/departments.dart';
import '../others/subject.dart';
import '../widgets/searchwidget.dart';

class AddCoursesPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return AddCoursesPageState();
  }

}

class AddCoursesPageState extends State<AddCoursesPage> {

  late double width, height;
  static const Duration duration = Duration(milliseconds: 300);
  String depToSearch = translateEng("All");
  String lastDep = translateEng("All");
  List<String> deps = faculties[Main.faculty]!.keys.toList();

  String query = "";

  List<Subject> subjects = Main.facultyData.subjects;
  List<Subject> subjectsOfDep = Main.facultyData.subjects;

  @override
  void initState() {

    deps.add(depToSearch);

  }

  @override
  Widget build(BuildContext context) {

    width = (window.physicalSize / window.devicePixelRatio).width;
    height = (window.physicalSize / window.devicePixelRatio).height;

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

    return Scaffold(
      appBar: AppBar(backgroundColor: Main.appTheme.headerBackgroundColor),
      backgroundColor: Main.appTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: height * 0.02, horizontal: width * 0.05),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(translateEng("Show courses only in "), style: TextStyle(color: Main.appTheme.titleTextColor)),
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
              ),

              SearchWidget(text: query, onChanged: search, hintText: translateEng("course code or name")),

              Expanded(
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: subjects.length, itemBuilder: (context, index) {
                    return buildTile(context, index);
                  })
              ),
            ],
          ),
        ),
      ),
    );

  }

  ListTile buildTile(context, index) {

    Subject subject = subjects[index];
    String name = subject.customName;
    bool isInside = false;

    //print("current schedule is: ${Main.schedules[Main.currentScheduleIndex].scheduleCourses}");
    for (Course crs in Main.schedules[Main.currentScheduleIndex].scheduleCourses) {
      if (crs.subject.classCode == subject.classCode) {
        isInside = true;
        break;
      }
    }
    if (!isInside) {
      for (Subject sub in Main.coursesToAdd) {
        if (sub.classCode == subject.classCode) {
          isInside = true;
          break;
        }
      }
    }

    return ListTile(
      title: Text(subject.classCode, style: TextStyle(color: Main.appTheme.titleTextColor)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              name,
              style: TextStyle(color: Main.appTheme.titleTextColor),
          ),
          isInside ? const Icon(CupertinoIcons.add_circled_solid, color: Colors.red) : Container(),
        ],
      ),
      onTap: () {
        setState(() {Main.coursesToAdd.add(subject);});
        Fluttertoast.showToast(
            msg: translateEng(isInside ? "${subject.classCode} " + translateEng("is already in the schedule") : "${subject.classCode} " + translateEng("was added to the schedule")),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blue,
            textColor: Colors.white,
            fontSize: 12.0
        );
      },
    );

  }

  void search(String query) {

    final subjects = subjectsOfDep.where((subject) {

      String name = subject.customName;

      query = query.toLowerCase();
      name = name.toLowerCase();

      return name.contains(query);

    }).toList();

    setState(() {
      this.query = query;
      this.subjects = subjects;
    });

  }

}

