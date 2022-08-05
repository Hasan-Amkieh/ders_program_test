import 'dart:ui';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:ders_program_test/language/dictionary.dart';
import 'package:ders_program_test/others/subject.dart';
import 'package:ders_program_test/pages/add_courses_page.dart';
import 'package:ders_program_test/pages/scheduler_result_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:getwidget/components/checkbox/gf_checkbox.dart';

import '../main.dart';

class SchedulerPage extends StatefulWidget {

  @override
  Key key = const Key("SchedulerPage");

  @override
  State<StatefulWidget> createState() {

    return SchedulerPageState();

  }

}

class SchedulerPageState extends State<SchedulerPage> {

  List<Subject> subjects = [], subjectsToAdd = [];
  List<MapEntry<String, List<MapEntry<int, Subject>>>> subjectsSections = []; // sample: [{"CMPE114" : [{1:subjectOfSec1}, {2:subjectOfSec2}]}] and so on...
  List<MapEntry<String, Map<int, bool>>> areSectionsShown = [];
  List<bool> subjectsShown = [];

  @override
  void initState() {

    super.initState();

    ;

  }

  @override
  Widget build(BuildContext context) {

    double width = (window.physicalSize / window.devicePixelRatio).width;
    double height = (window.physicalSize / window.devicePixelRatio).height;

    if (subjectsToAdd.isNotEmpty) {
      //subjects.addAll(subjectsToAdd);
      for (Subject element in subjectsToAdd) {
        bool isDone = false;
        for (Subject sub_ in subjects) {
          if (sub_.getClassCodeWithoutSectionNumber() == element.getClassCodeWithoutSectionNumber()) {
            isDone = true;
            break;
          }
        }
        if (isDone) {
          continue;
        }

        int maxSection = 0;
        //Map<int, Subject> secToSubject = {};
        for (Subject sub in Main.facultyData.subjects) {
          //print("Checking if ${sub.classCode} has sections or not!");
          if (sub.getClassCodeWithoutSectionNumber() == element.classCode && sub.getClassCodeWithoutSectionNumber() != sub.classCode) { // if sub has sections:
            print("${sub.classCode} has a section of ${sub.getSection()}!");
            if (sub.getSection() > maxSection) {
              maxSection = sub.getSection();
            }
            bool isFound = false;
            int secIndex = 0;
            for (int j = 0 ; j < subjectsSections.length ; j++) { // sample: [{"CMPE114" : [{1:subjectOfSec1}, {2:subjectOfSec2}]}] and so on...
              if (subjectsSections[j].key == sub.getClassCodeWithoutSectionNumber()) {
                isFound = true;
                secIndex = j;
                break;
              }
            }
            if (!isFound) {
              //print("*** adding ${sub.getClassCodeWithoutSectionNumber()} ***");
              subjectsSections.add(MapEntry(sub.getClassCodeWithoutSectionNumber(), []));
              areSectionsShown.add(MapEntry(sub.getClassCodeWithoutSectionNumber(), <int, bool>{}));
              // The var secIndex has to be reset bcs now there is a new element!
              secIndex = areSectionsShown.length - 1;
            }
            // if (secIndex >= subjectsSections.length) {
            //   continue;
            // }
            print("index of $secIndex");

            if (sub.getClassCodeWithoutSectionNumber() == subjectsSections[secIndex ].key && subjectsSections[secIndex].value.length < maxSection && maxSection != 0) {
              subjectsSections[secIndex].value.add(MapEntry(sub.getSection(), sub));
              areSectionsShown[secIndex].value.addAll({sub.getSection() : true});
              print("DOING SUBJECT: $sub OF CLASSCODE ${sub.classCode}");
              print("Adding section ${sub.getSection()} for subject ${sub.getClassCodeWithoutSectionNumber()}");
            }
            //secToSubject.addEntries([MapEntry(sub.getSection(), sub)]);
          } else if (sub.getClassCodeWithoutSectionNumber() == element.classCode) { // if the sub does not have sections:

            print("*** adding ${sub.getClassCodeWithoutSectionNumber()} ***");
            subjectsSections.add(MapEntry(sub.getClassCodeWithoutSectionNumber(), []));
            areSectionsShown.add(MapEntry(sub.getClassCodeWithoutSectionNumber(), <int, bool>{}));

          }
        }

        // subjectsSections.add([]);
      }
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
                          SchedulerResultPage.subjects = subjects;
                          List<SchedulerSubjectData> list = [];
                          List<int> sections = [];
                          int skipped = 0;
                          for (int i = 0 ; i < subjects.length ; i++) {
                            sections = [];
                            print("DOING ${subjectsSections[i].key} with ${subjectsSections[i].value}");
                            for (MapEntry<int, Subject> element in subjectsSections[i].value) {
                              if (areSectionsShown[i].value.containsKey(element.key) && areSectionsShown[i].value[element.key] as bool) {
                                sections.add(element.key);
                              }
                            }
                            list.add(SchedulerSubjectData(allowCols: subjectsShown[i], sections: sections));
                          }
                          list.forEach((element) {
                            print("${element.sections} has value of cols of ${element.allowCols}");
                          });
                          SchedulerResultPage.subjectsData = list;
                          Navigator.pushNamed(context, "/home/scheduler/schedulerresult");
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

    String sectionsStr = "";
    if (areThereSecs) {
      int secIndex = -1;
      int ind = 0;
      for (MapEntry<String, List<MapEntry<int, Subject>>> element in subjectsSections) {
        if (element.key == subjects[index].getClassCodeWithoutSectionNumber()) {
          secIndex = ind;
        }
        ind++;
      }

      List<MapEntry<int, bool>> sections = [];

      //print("SubjectSections var: ${subjectsSections[secIndex]} of index $secIndex");

      for (MapEntry<int, Subject> element in subjectsSections[secIndex].value) {
        //print("Checking ${areSectionsShown[secIndex]}");
        if (areSectionsShown[secIndex].value.containsKey(element.key)) {
          sections.add(MapEntry(element.key, areSectionsShown[secIndex].value[element.key] as bool));
        } //
      }

      int numOfFalse = 0;
      for (int secNum = 0 ; secNum < sections.length ; secNum++) {
        if (!sections[secNum].value) {
          numOfFalse++;
        }
      }
      bool isAll = numOfFalse == 0;

      if (isAll) {
        sectionsStr = translateEng("All");
      } else if (sections.length - numOfFalse > 1) {
        sectionsStr = "";
        //print("Sections var: $sections");
        for (int secNum = 0 ; secNum < sections.length ; secNum++) {
          if (sections[secNum].value) {
            sectionsStr += "," + sections[secNum].key.toString();
          }
        }
        //print("SectionStr before : $sectionsStr");
        sectionsStr = sectionsStr.substring(1, sectionsStr.length); // remove the last comma
        //print("SectionStr after : $sectionsStr");
      } else { // otherwise it is only one section:
        for (int secNum = 0 ; secNum < sections.length ; secNum++) {
          if (sections[secNum].value) {
            sectionsStr = sections[secNum].key.toString();
            break;
          }
        }
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

        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          areThereSecs ? TextButton(
            child: Text(translateEng("Sections") + ": " + sectionsStr, style: TextStyle(color: Colors.blue, fontSize: 14)),
            onPressed: () {
              showAdaptiveActionSheet(
                bottomSheetColor: Main.appTheme.scaffoldBackgroundColor,
                context: context,
                title: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return buildSectionList(index, width, height);
                  },
                ),
                actions: [],
                cancelAction: CancelAction(title: Text(translateEng("Close"))),
              ).then((value) => setState(() {}));
            },
          ) : Container(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                child: const Icon(Icons.delete_forever, color: Colors.red),
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.red.withOpacity(0.2)),
                ),
                onPressed: () {
                  setState(() {
                    subjects.removeAt(index);
                    subjectsShown.removeAt(index);
                    bool hasSecs = false;
                    for (Subject sub in Main.facultyData.subjects) {
                      if (sub.getClassCodeWithoutSectionNumber() == subjectsSections[index].key) { // if it is the class we are looking for:
                        if (sub.getClassCodeWithoutSectionNumber() != sub.classCode) { // if it has sections:
                          hasSecs = true;
                          break;
                        }
                      }
                    }
                    // if (hasSecs) { // does this course subjectsSections[index].key have sections?
                    //   areSectionsShown.removeAt(index); // only for subs with sections
                    // }
                    areSectionsShown.removeAt(index); // only for subs with sections
                    subjectsSections.removeAt(index);
                  });
                },
              ),
              TextButton(
                style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
                onPressed: () {
                  setState(() {
                    subjectsShown[index] = !subjectsShown[index];
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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

    print("Sections are " + secToSubject.toString());

    for (int sec = 1 ; sec <= maxSection ; sec++) {

      if (!secToSubject.containsKey(sec)) {
        continue;
      }
      print("doing section $sec of length ${secToSubject}");
      String deps = secToSubject[sec]!.departments.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");
      List<String> temp = deps.split(",");
      for (int i = 0 ; i < temp.length ; i++) {
        temp[i] = temp[i].trim().split(" ")[0];
      }
      deps = temp.toString().replaceAll(RegExp("[\\[.*?\\]]"), "").replaceAll(",", " ,");

      int subIndex = -1;
      for (int k = 0 ; k < areSectionsShown.length ; k++) {
        if (areSectionsShown[k].key == secToSubject[sec]!.getClassCodeWithoutSectionNumber()) {
          subIndex = k;
        }
      }

      //"$dayShort. ${widget.bgnHour[i]} - $endHour:20"
      // secToSubject[sec]!
      String timeStr = "";
      if (secToSubject[sec]!.days.isNotEmpty) {
        for (int i = 0 ; i < secToSubject[sec]!.days.length ; i++) {
          for (int j = 0 ; j < secToSubject[sec]!.days[i].length ; j++) {
            timeStr += "${dayToStringShort(secToSubject[sec]!.days[i][j])}. " +
                "${bgnPeriodToStringHoursOnly(secToSubject[sec]!.bgnPeriods[i][j])}:30 - " +
                "${bgnPeriodToStringHoursOnly(secToSubject[sec]!.bgnPeriods[i][j] + secToSubject[sec]!.hours[i])}:20" +
                " | ";
          }
        }
        if (timeStr.length > 4) {
          timeStr = timeStr.substring(0, timeStr.length - 3);
        }
      }

      // TODO: Make the current department highlighted!
      // // TODO: And make it by default chosen if there deps list is not empty, if it is empty then choose it

      //print("The length of shown vars is : ${areSectionsShown[subIndex].value.length}");
      if (!areSectionsShown[subIndex].value.containsKey(sec)) {
        print("STOP HERE of index $subIndex of ${areSectionsShown[subIndex]}");
        continue;
      }

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
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Checkbox(
                        value: areSectionsShown[subIndex].value[sec],
                        onChanged: (value) {
                          print("The new value is: $value");
                          areSectionsShown[subIndex].value[sec] = value ?? true;
                          setState(() {
                            //areSectionsShown[subIndex].value[sec - 1] = value ?? true;
                            //Navigator.pop(context);
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  secToSubject[sec]!.days.isNotEmpty ? Text(
                    timeStr,
                    style: TextStyle(color: Main.appTheme.titleTextColor),
                  ) : Container(),
                  SizedBox(height: height * 0.02),
                  secToSubject[sec]!.departments.toString().replaceAll(RegExp("[\\[.*?\\]]"), "").trim().isNotEmpty ? Column(children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translateEng("Only for the following departments"),
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
