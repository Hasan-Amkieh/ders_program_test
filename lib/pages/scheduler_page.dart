import 'dart:ui';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:ders_program_test/language/dictionary.dart';
import 'package:ders_program_test/others/subject.dart';
import 'package:ders_program_test/pages/add_courses_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:getwidget/components/checkbox/gf_checkbox.dart';

import '../main.dart';

class SchedulerPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {

    return SchedulerPageState();

  }

}

class SchedulerPageState extends State<SchedulerPage> {

  List<Subject> subjects = [], subjectsToAdd = [];
  List<bool> subjectsShown = [];

  @override
  void initState() {

    super.initState();

    ;

  }

  @override
  Widget build(BuildContext context) {

    // if (AddCoursesPageState.isForScheduler) { // then it means that currently this is not the current page!
    //   return Container(); // because when calling setState in add courses page this func is also called!
    //   // TODO: SOLVE THIS USING THE KEY PROPERTY
    // }

    double width = (window.physicalSize / window.devicePixelRatio).width;
    double height = (window.physicalSize / window.devicePixelRatio).height;

    if (subjectsToAdd.isNotEmpty) {
      subjects.addAll(subjectsToAdd);
      subjectsToAdd.clear();
      subjectsShown.clear();
      subjects.forEach((element) {subjectsShown.add(false);});
    }

    return Scaffold(
      backgroundColor: Main.appTheme.scaffoldBackgroundColor,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight((MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * 0.1),
          child: AppBar(backgroundColor: Main.appTheme.headerBackgroundColor)
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: width * 0.02, vertical: width * 0.02),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder( // GFCheckbox
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: subjects.length,
                  itemBuilder: (context, index) => buildSubject(index, width, height),
                ),
              ),
              Container(
                color: Main.appTheme.scaffoldBackgroundColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Visibility(
                      visible: subjects.length < 2,
                        child: Column(
                          children: [
                            Icon(Icons.error, color: Colors.grey.shade700, size: (IconTheme.of(context).size ?? 64) * 2),
                            SizedBox(height: height * 0.05),
                            Text(translateEng("There has to be two courses at least!"),textAlign: TextAlign.center, style: TextStyle(color: Main.appTheme.titleTextColor, fontSize: 18)),
                            SizedBox(height: height * 0.4),
                          ],
                        ),
                    ),
                    TextButton.icon(
                      icon: Icon(Icons.add),
                      label: Text(translateEng("Add course")),
                      onPressed: () {
                        Main.coursesToAdd = subjects;
                        AddCoursesPageState.isForScheduler = true;
                        Navigator.pushNamed(context, "/home/editcourses/addcourses").then((value) {
                          if (Main.coursesToAdd.isNotEmpty) {
                            setState(() { // check for redundancy:
                              subjectsToAdd.addAll(Main.coursesToAdd);
                              Main.coursesToAdd.clear();
                            });
                          }
                          AddCoursesPageState.isForScheduler = false;
                        });
                      },
                    ),
                    Visibility(
                      visible: subjects.length >= 2,
                      child: TextButton.icon(
                        icon: const Icon(Icons.search),
                        label: Text(translateEng("Find all possible schedules")),
                        onPressed: () {
                          ;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

  ListTile buildSubject(int index, double width, double height) {

    bool areThereSecs = false;
    for (Subject sub in Main.facultyData.subjects) {

      // if the course is the same
      if (sub.getClassCodeWithoutSectionNumber() == subjects[index].classCode && sub.getClassCodeWithoutSectionNumber() != sub.classCode) {
        areThereSecs = true;
        break;
      }

    }

    return ListTile(
      contentPadding: EdgeInsets.fromLTRB(width * 0.03, height * 0.01, width * 0.03, height * 0.01),
      shape: Border(
        bottom: BorderSide(
          color: Colors.grey.shade700,
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subjects[index].classCode, style: TextStyle(color: Main.appTheme.titleTextColor)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              areThereSecs ? TextButton(
                child: Text(translateEng("Sections"), style: TextStyle(color: Colors.blue, fontSize: 14)),
                onPressed: () {
                  showAdaptiveActionSheet(
                    bottomSheetColor: Main.appTheme.scaffoldBackgroundColor,
                    context: context,
                    title: buildSectionList(index, width, height),
                    actions: [],
                    cancelAction: CancelAction(title: Text(translateEng("Close"))),
                  );
                },
              ) : Container(),
              TextButton(
                style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
                onPressed: () {
                  setState(() {
                    subjectsShown[index] = !subjectsShown[index];
                  });
                },
                child: Row(
                  children: [
                    Text(translateEng(subjectsShown[index] ? "Permit Conflicts" : "Forbid Conflicts"), style: TextStyle(color: subjectsShown[index] ? Colors.red : Colors.blue, fontSize: 14)),
                    GFCheckbox(
                      size: ((IconTheme.of(context).size) ?? 16) + 4.0,
                      activeBgColor: Main.appTheme.scaffoldBackgroundColor,
                      inactiveBgColor: Main.appTheme.scaffoldBackgroundColor,
                      activeIcon: const Icon(Icons.call_merge_rounded, color: Colors.red),
                      inactiveIcon: const Icon(Icons.arrow_upward, color: Colors.blue),
                      activeBorderColor: Main.appTheme.scaffoldBackgroundColor,
                      inactiveBorderColor: Main.appTheme.scaffoldBackgroundColor,
                      value: subjectsShown[index],
                      onChanged: (newValue) {
                        setState(() => subjectsShown[index] = newValue);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

    );

  }

  Column buildSectionList(int index, double width, double height) {

    List<Widget> actions = [];

    int maxSection = 1;

    Map<int, Subject> secToSubject = {};

    for (Subject sub in Main.facultyData.subjects) {
      if (sub.getClassCodeWithoutSectionNumber() == subjects[index].classCode && sub.getClassCodeWithoutSectionNumber() != sub.classCode) {
        if (sub.getSection() > maxSection) {
          maxSection = sub.getSection();
        }
        secToSubject.addEntries([MapEntry(sub.getSection(), sub)]);
      }
    }

    for (int sec = 1 ; sec <= maxSection ; sec++) {

      String deps = secToSubject[sec]!.departments.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");
      List<String> temp = deps.split(",");
      for (int i = 0 ; i < temp.length ; i++) {
        temp[i] = temp[i].trim().split(" ")[0];
      }
      deps = temp.toString().replaceAll(RegExp("[\\[.*?\\]]"), "").replaceAll(",", " ,");
      // TODO: Make the current department highlighted!

      actions.add(
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, height * 0.03),
          child: ElevatedButton(
            onPressed: null,
            style: const ButtonStyle(splashFactory: NoSplash.splashFactory),
            child: ListTile(
              enabled: false,
              onTap: null,
              onLongPress: null,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(translateEng("Section") + " " + sec.toString(), style: TextStyle(color: Main.appTheme.titleTextColor)),
                  Checkbox(
                    value: true,
                    onChanged: (value) {
                      ;
                    },
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mon. 19:30 - 20:20",
                    style: TextStyle(color: Main.appTheme.titleTextColor),
                  ),
                  SizedBox(height: height * 0.02),
                  secToSubject[sec]!.departments.toString().replaceAll(RegExp("[\\[.*?\\]]"), "").trim().isNotEmpty ? Column(children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translateEng("Only for "),
                          style: TextStyle(color: Main.appTheme.titleTextColor),
                        ),
                        SizedBox(
                          width: width * 0.02,
                        ),
                        Expanded(
                          child: Text(
                            deps,
                            style: TextStyle(color: Main.appTheme.titleTextColor),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.02),
                  ]) : Container(),
                  SizedBox(height: height * 0.02),
                ],
              ),
            ),
          ),
        ),
      );

    }

    return Column(children: actions);

  }

}
