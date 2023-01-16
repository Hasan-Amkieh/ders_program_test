import 'dart:ui';
import 'dart:io' show Platform;

import 'package:Atsched/others/schedule_solution.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

import '../language/dictionary.dart';
import '../main.dart';
import '../others/appthemes.dart';
import '../others/subject.dart';
import '../others/university.dart';
import 'home_page.dart';

class SchedulerResultPage extends StatefulWidget {

  // to be filled before opening this page!
  static late List<Subject> subjects; // this has the class codes of the subjects, it does not have the section number
  static late List<SchedulerSubjectData> subjectsData; // referenced by the same index inside subjects
  List<Schedule> schedules = []; // to be filled up!
  List<bool> isSaved = [];

  @override
  State<StatefulWidget> createState() {

    return SchedulerResultPageState();

  }

}

class SchedulerResultPageState extends State<SchedulerResultPage> {

  double width = (window.physicalSize / window.devicePixelRatio).width;
  double height = (window.physicalSize / window.devicePixelRatio).height;
  int currentScheduleIndex = 0;

  List<ScheduleSolution> scheduleSols = [];

  @override
  void initState() {

    super.initState();

    // finding all the possible schedules:
    chosenSections = [];
    findPossibleSchedule(0);
    //print("All the schedules are: \n\n");
    //widget.schedules.forEach((element) { print("${element.scheduleName} of courses: "); element.scheduleCourses.forEach((element) {print("${element.subject.classCode}");}); });

    // print("If not results were found, please fix the following collisions:");
    // scheduleSols.forEach((element) {
    //   String subsStr = "";
    //   element.subs.forEach((s) {subsStr = subsStr + s.classCode; });
    //   print("the course ${element.sub.classCode} is colliding with the following courses: $subsStr");
    // });

  }

  List<int> chosenSections = [];

  void findPossibleSchedule(int subjectIndex) { // Recursion is used here:

    if (SchedulerResultPage.subjectsData[subjectIndex].sections.isEmpty) { // then this course has no sections:
      SchedulerResultPage.subjectsData[subjectIndex].sections.add(0);
    }

    for (int sectionIndex = 0 ; sectionIndex < SchedulerResultPage.subjectsData[subjectIndex].sections.length ; sectionIndex++) { // loop through each section
      // SchedulerResultPage.subjectsData[subjectIndex].sections[sectionIndex]
      if (subjectIndex != (SchedulerResultPage.subjects.length - 1)) { // if it is not the last subject in the list of subjects, then go deeper:

        chosenSections.add(SchedulerResultPage.subjectsData[subjectIndex].sections[sectionIndex]);
        findPossibleSchedule(subjectIndex + 1);

      } else { // otherwise make a schedule:

        List<Course> courses = [];
        Subject sub = Main.emptySubject;
        chosenSections.add(SchedulerResultPage.subjectsData[subjectIndex].sections[sectionIndex]);
        // print("Doing search inside $chosenSections");
        for (int index = 0 ; index < chosenSections.length ; index++) { // translate the sections into their subjects:
          for (int i = 0 ; i < Main.facultyData.subjects.length ; i++) {
            if (Main.facultyData.subjects[i].getCourseCodeWithoutSectionNumber() == SchedulerResultPage.subjects[index].courseCode) {
              if (Main.facultyData.subjects[i].getSection() == chosenSections[index] || chosenSections[index] == 0) {
                // print("Adding ${Main.facultyData.subjects[i]}");
                sub = Main.facultyData.subjects[i];
              }
            }
          }
          courses.add(Course(note: "", subject: sub));
        }
        if (chosenSections.isNotEmpty) {
          chosenSections.removeLast();
        }

        bool toAdd = true;

        List<Subject> notToCollideSubjects = [];
        for (int i = 0 ; i < SchedulerResultPage.subjectsData.length ; i++) {
          if (!SchedulerResultPage.subjectsData[i].allowCols) {
            notToCollideSubjects.add(SchedulerResultPage.subjects[i]);
          }
        }

        List<CollisionData> collisions = findCourseCollisions(courses);
        for (CollisionData col in collisions) {

          // check notToCollideSubjects, if a course inside the col var had a subject inside notToCollide subs then, make toAdd false and break
          for (int i = 0 ; i < col.subjects.length ; i++) {
            for (int j = 0 ; j < notToCollideSubjects.length ; j++) {
              if (col.subjects[i].getCourseCodeWithoutSectionNumber() == notToCollideSubjects[j].getCourseCodeWithoutSectionNumber()) {
                toAdd = false;
                List<Subject> subs = [];
                for (int ind_ = 0 ; ind_ < col.subjects.length ; ind_++) {
                  if (i != ind_) { //
                    subs.add(col.subjects[ind_]);
                  }
                }

                bool isToAdd = true;
                // Check first if it was already added:
                List<Subject> subs1 = [];
                List<Subject> subs2 = [];
                subs1.add(col.subjects[i]);subs1.addAll(subs);
                List<Subject> subs1_ = [];subs1_.addAll(subs1);

                for (int solIndex = 0 ; solIndex < scheduleSols.length ; solIndex++) {
                  subs1.clear();
                  subs1.addAll(subs1_);
                  subs2.clear();
                  subs2.add(scheduleSols[solIndex].sub);
                  subs2.addAll(scheduleSols[solIndex].subs);
                  for (int i_ = 0 ; i_ < subs1.length ; i_++) {
                    for (int j_ = 0 ; j_ < subs2.length ; ) {
                      if (subs1.isEmpty || subs2.isEmpty) {
                        break;
                      }
                      if (subs1[i_].isEqual(subs2[j_])) {
                        subs1.removeAt(i_);
                        subs2.removeAt(j_);
                        if (i_ != 0) {
                          i_--;
                        }
                        if (j_ != 0) {
                          j_--;
                        }
                      } else {
                        j_++;
                      }
                      if (subs1.isEmpty && subs2.isEmpty) {
                        isToAdd = false;
                        break;
                      }
                    }
                    if (!isToAdd) {
                      break;
                    }
                  }
                  if (!isToAdd) {
                    break;
                  }
                }

                if (isToAdd) { // if both are not empty, then the lists do not match:
                  scheduleSols.add(ScheduleSolution(sub: col.subjects[i], subs: subs));
                } else {
                  isToAdd = true;
                }

                // print("This schedule was refused because ${notToCollideSubjects[j].getClassCodeWithoutSectionNumber()} is colliding with $subs");
                subs = [];
                break;
              }
            }
          }

          if (!toAdd) {
            break;
          }

        }

        if (toAdd) {
          widget.isSaved.add(false);
          widget.schedules.add(Schedule(scheduleName: "Schedule - " + widget.schedules.length.toString(), scheduleCourses: courses));
        }

      }
    }

    if (chosenSections.isNotEmpty) {
      chosenSections.removeLast();
    }

  }

  @override
  Widget build(BuildContext context) {

    List<TextSpan> txts = [];

    if (widget.schedules.isEmpty) {

      String subs = "";

      scheduleSols.forEach((sol) {
        subs = "";
        sol.subs.forEach((sub_) {subs = subs + "  |  " + sub_.courseCode;});
        subs = subs.substring(5) + "\n";
        txts.add(TextSpan(
          children: [
            TextSpan(
              text: sol.sub.getCourseCodeWithoutSectionNumber() + " Sec. ${sol.sub.getSection()}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            TextSpan(
              text: "  is colliding with  ",
              style: TextStyle(fontSize: 12, color: Main.appTheme.titleTextColor),
            ),
            TextSpan(
              text: subs + '\n',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red) ,
            ),
          ],
        ));
      });

    }

    return Scaffold(
      backgroundColor: Main.appTheme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight((MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * (Platform.isWindows ? 0.05 : 0.1)),
        child: AppBar(
            backgroundColor: Main.appTheme.headerBackgroundColor,
        ),
      ),
      body: Column(
        children: [
          widget.schedules.isEmpty ? Container() : Row( // remove the schedule or the save the schedule commands
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                label: Text(translateEng("Remove Schedule"), style: const TextStyle(color: Colors.red)),
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.red.withOpacity(0.2)),
                ),
                onPressed: () {
                  setState(() {
                    widget.isSaved.removeAt(currentScheduleIndex);
                    widget.schedules.removeAt(currentScheduleIndex);
                    if (currentScheduleIndex >= widget.isSaved.length) {
                      currentScheduleIndex--;
                    }
                  });
                },
              ),
              SizedBox(
                width: width * 0.03,
              ),
              widget.isSaved[currentScheduleIndex] ? Container() : TextButton.icon(
                icon: const Icon(Icons.save, color: Colors.blue),
                label: Text(translateEng("Save Schedule")),
                onPressed: () {
                  showDialog(context: context, builder: (context) {
                    TextEditingController nameController = TextEditingController(); // Main.schedules[scheduleIndex].scheduleName

                    return AlertDialog(
                      backgroundColor: Main.appTheme.scaffoldBackgroundColor,
                      title: Text(translateEng("Name the Schedule"), style: TextStyle(color: Main.appTheme.titleTextColor)),
                      content: Builder(
                          builder: (context) {
                            return SizedBox(
                              width: width * 1,
                              height: height * 0.25,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: width * 0.6,
                                        child: TextFormField(controller: nameController,
                                          cursorColor: Main.appTheme.titleTextColor,
                                          style: TextStyle(color: Main.appTheme.titleTextColor),
                                          decoration: InputDecoration(
                                            hintText: translateEng("e.g. Fall Semester"),
                                            hintStyle: TextStyle(color: Main.appTheme.hintTextColor),
                                            labelText: "Schedule Name",
                                            labelStyle: TextStyle(color: Main.appTheme.titleTextColor),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }
                      ),
                      actions: [
                        TextButton(
                          child: Text(translateEng("SAVE")),
                          onPressed: () {
                            if (nameController.text.isNotEmpty && nameController.text.replaceAll(RegExp('[^A-Za-z0-9\\s\\-üÜğĞöÖçÇşŞ\\(\\)]'), '') == nameController.text) {
                              widget.schedules[currentScheduleIndex].scheduleName = nameController.text;
                              widget.isSaved[currentScheduleIndex] = true;
                              Main.schedules.add(widget.schedules[currentScheduleIndex]); // widget.schedules[currentScheduleIndex]
                              Main.currentScheduleIndex = Main.schedules.length - 1;
                              Navigator.pop(context);
                              showToast(
                                translateEng("schedule was saved"),
                                duration: const Duration(milliseconds: 1500),
                                position: ToastPosition.bottom,
                                backgroundColor: Colors.blue.withOpacity(0.8),
                                radius: 100.0,
                                textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
                              );
                            } else {
                              showToast(
                                translateEng("The name cannot be empty and can only have numbers and characters"),
                                duration: const Duration(milliseconds: 1500),
                                position: ToastPosition.bottom,
                                backgroundColor: Colors.red.withOpacity(0.8),
                                radius: 100.0,
                                textStyle: const TextStyle(fontSize: 12.0, color: Colors.white),
                              );
                            }
                          },
                        ),
                        TextButton(
                          child: Text(translateEng("CANCEL")),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  });
                },
              ),
            ],
          ),
          widget.schedules.isEmpty ? Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.grey.shade700, size: (IconTheme.of(context).size ?? 64) * 2),
                    SizedBox(height: height * 0.05),
                    Text(translateEng("No possible schedules were found!\nPlease fix one of the following collisions\n"),textAlign: TextAlign.center, style: TextStyle(color: Main.appTheme.titleTextColor, fontSize: 18)),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      child: RichText(
                        text: TextSpan(
                          children: txts,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          )
              : Row( // counter of the schedules
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                child: const Icon(Icons.chevron_left, color: Colors.blue),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                ),
                onPressed: () {
                  setState(() {
                    if (currentScheduleIndex == 0) {
                      currentScheduleIndex = widget.schedules.length - 1;
                    } else {
                      currentScheduleIndex--;
                    }
                  });
                },
              ),
              SizedBox(width: width * 0.03),
              Text((currentScheduleIndex + 1).toString() + " / " + widget.schedules.length.toString(), style: TextStyle(color: Main.appTheme.titleTextColor)),
              SizedBox(width: width * 0.03),
              TextButton(
                child: const Icon(Icons.chevron_right, color: Colors.blue),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                ),
                onPressed: () {
                  setState(() {
                    if (currentScheduleIndex + 1 == widget.schedules.length) {
                      currentScheduleIndex = 0;
                    } else {
                      currentScheduleIndex++;
                    }
                  });
                },
              ),
            ],
          ),
          widget.schedules.isEmpty ? Container() : Expanded(
            child: SingleChildScrollView(
              child: buildSchedule(currentScheduleIndex),
            ),
          ),
        ],
      ),
    );

  }

  Widget buildSchedule(int scheduleIndex) {

    bool isSatNeeded = false, isSunNeeded = false;

    for (int subIndex = 0 ; subIndex < Main.schedules[Main.currentScheduleIndex].scheduleCourses.length ; subIndex++) {

      for (int x = 0 ; x < Main.schedules[Main.currentScheduleIndex].scheduleCourses[subIndex].subject.days.length ; x++) {
        for (int y = 0 ; y < Main.schedules[Main.currentScheduleIndex].scheduleCourses[subIndex].subject.days[x].length ; y++) {
          if (!isSatNeeded || !isSunNeeded) {
            if (Main.schedules[Main.currentScheduleIndex].scheduleCourses[subIndex].subject.days[x][y] == 6) {
              isSatNeeded = true;
            }
            if (Main.schedules[Main.currentScheduleIndex].scheduleCourses[subIndex].subject.days[x][y] == 7) {
              isSunNeeded = true;
            }
          } else {
            break;
          }
        }
        if (isSatNeeded && isSunNeeded) {
          break;
        }
      }
      if (isSatNeeded && isSunNeeded) {
        break;
      }
    }

    int bgnHour = 9, endHour = 16;

    List<int> neededHours = []; // 15 and 16 were deleted, now it depends on the courses we have

    widget.schedules[scheduleIndex].scheduleCourses.forEach((crs) {

      for (int i = 0 ; i < crs.subject.days.length ; i++) {

        for (int j = 0 ; j < crs.subject.days[i].length ; j++) {

          if (bgnHour > crs.subject.bgnPeriods[i][j]) { // first convert the hours
            bgnHour = crs.subject.bgnPeriods[i][j];
          }

          if (endHour < (crs.subject.bgnPeriods[i][j] + crs.subject.hours[i])) {
            // print("The end hour has been changed into ${crs.subject.bgnPeriods[i][j] + crs.subject.hours[i]}");
            endHour = crs.subject.bgnPeriods[i][j] + crs.subject.hours[i];
          }

        }

      }

    });

    for (int i = bgnHour ; i <= endHour ; i++) { // equivalent to bgnHour:1:endHour in MATLAB
      neededHours.add(i);
    }

    double colWidth = (width) / ( 6 + (isSatNeeded ? 1 : 0) + (isSunNeeded ? 1 : 0) ); // 5 days and a col for the clock
    double rowHeight = (height * 1) / (neededHours.length + 1); // some for the clock and one for the empty box // 91 percent because of the horizontal borders

    Color emptyCellColor = Main.appTheme.emptyCellColor;
    Color horizontalBorderColor = Colors.black38; // bgnHours seperator
    Container emptyCell = Container(decoration: BoxDecoration(
        color: emptyCellColor,
        border: Border.symmetric(
            horizontal: BorderSide(color: horizontalBorderColor, width: 1)
        )),
        child: SizedBox(width: colWidth, height: rowHeight,));

    List<Widget> hoursWidgets = [];

    hoursWidgets.add(SizedBox(width: colWidth, height: rowHeight));
    neededHours.forEach((hr) {
      hoursWidgets.add(Container(
        //padding: EdgeInsets.symmetric(horizontal: colWidth / (Platform.isWindows ? 4 : 6.5)), // This screwed up the phone version
          color: Main.appTheme.headerBackgroundColor,
          child: Center(child: Text(hr.toString() + ':' + University.getBgnMinutes().toString(), style: Main.appTheme.headerSchedulePageTextStyle)),
          height: rowHeight
      ));
    });

    List<Widget> colsList = [
      Container(
        color: Main.appTheme.headerBackgroundColor, // Main.appTheme.headerBackgroundColor.withGreen(50)
        child: Column(
          children: hoursWidgets,
        ),
      ),
      Container(
        color: Main.appTheme.headerBackgroundColor,
        child: Column( // Headers
          children: HomeState.prepareDay("Mon", rowHeight, colWidth, neededHours.length, emptyCell),
        ),
      ),
      Container(
        color: Main.appTheme.headerBackgroundColor,
        child: Column( // Headers
          children: HomeState.prepareDay("Tue", rowHeight, colWidth, neededHours.length, emptyCell),
        ),
      ),
      Container(
        color: Main.appTheme.headerBackgroundColor,
        child: Column( // Headers
          children: HomeState.prepareDay("Wed", rowHeight, colWidth, neededHours.length, emptyCell),
        ),
      ),
      Container(
        color: Main.appTheme.headerBackgroundColor,
        child: Column( // Headers
          children: HomeState.prepareDay("Thur", rowHeight, colWidth, neededHours.length, emptyCell),
        ),
      ),
      Container(
        color: Main.appTheme.headerBackgroundColor,
        child: Column( // Headers
          children: HomeState.prepareDay("Fri", rowHeight, colWidth, neededHours.length, emptyCell),
        ),
      ),
      isSatNeeded ? (
          Container(
            color: Main.appTheme.headerBackgroundColor,
            child: Column( // Headers
              children: HomeState.prepareDay("Sat", rowHeight, colWidth, neededHours.length, emptyCell),
            ),
          )
      ) : Container(),
      isSunNeeded ? (
          Container(
            color: Main.appTheme.headerBackgroundColor,
            child: Column( // Headers
              children: HomeState.prepareDay("Sun", rowHeight, colWidth, neededHours.length, emptyCell),
            ),
          )
      ) : Container(),
    ];

    List<Widget> coursesList = [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: colsList,
      ),
    ];

    //widget.schedules[scheduleIndex].scheduleCourses.forEach((element) {print(element.subject.toString());});
    // First find all the collisions:
    List<CollisionData> collisions = findCourseCollisionsWithIndex(scheduleIndex);
    //print("All the collisions are: ");
    //collisions.forEach((col) { print("\nCOLLISION:"); col.subjects.forEach((element) {print(element.classCode);}); });

    int colorIndex = -1;

    widget.schedules[scheduleIndex].scheduleCourses.forEach((course) {
      colorIndex++;
      for (int i = 0; i < course.subject.days.length; i++) {
        for (int j = 0; j < course.subject.days[i].length; j++) {
          bool isCol = false, isColOf3 = false;
          int atIndex = 0, drawingIndex = 0, colSize = 1; // colSize determines how many subjects are actually in this collision
          int colIndex = 0;
          collisions.forEach((col) {
            atIndex = 0;
            Subject sub;
            for( ; atIndex < col.subjects.length ; atIndex++ ) {
              sub = col.subjects[atIndex];
              //print("${sub.classCode} N ${course.subject.classCode}");
              if (sub.isEqual(course.subject) && course.subject.days[i][j] == col.subjectsData[atIndex].day &&
                  course.subject.bgnPeriods[i][j] == col.subjectsData[atIndex].bgnPeriod && !col.isDrawn[atIndex]) {
                // print("Drawing the collisioned course: ${course.subject.classCode}");
                collisions[colIndex].isDrawn[atIndex] = true;
                isCol = true;
                isColOf3 = collisions[colIndex].subjects.length >= 3;
                drawingIndex = atIndex;
                colSize = col.subjects.length;
                continue;
              } else {
                // print("NOT Drawing the collisioned course bcs the period is different: ${course.subject.classCode}");
              }
              if (isCol) {
                continue;
              }
            }
            colIndex++;
            if (isCol) {
              return;
            }
          });
          //print("index of ${course.subject.classCode} is $drawingIndex N $colSize");

          String classroomStr = i < course.subject.classrooms.length ? deleteRepitions(course.subject.classrooms[i]).toString().replaceAll(RegExp("[\\[.*?\\]]"), "") : "";
          if (classroomStr.isEmpty) {
            for (int j = 0 ; j < course.subject.classrooms.length ; j++) {
              if (classroomStr.isNotEmpty && course.subject.classrooms[j].isNotEmpty && deleteRepitions(course.subject.classrooms[j]).toString().replaceAll(RegExp("[\\[.*?\\]]"), "") != classroomStr) {
                classroomStr = "";
                break;
              }
              if (course.subject.classrooms[j].isNotEmpty) {
                classroomStr = deleteRepitions(course.subject.classrooms[j]).toString().replaceAll(RegExp("[\\[.*?\\]]"), "");
              }
            }
          }
          //print("Of period $i of subject ${course.subject.classCode} has classrooms $classroomStr");

          coursesList.add(
            Positioned(child: TextButton(
              //clipBehavior: Clip.none,
                onPressed: () => showCourseInfo(course),
                child: RotatedBox(
                  quarterTurns: isCol ? 1 : 0,
                  child: RichText(
                    text: TextSpan(
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyText2,
                        children: [
                          TextSpan(
                            text: course.subject.courseCode,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.0),
                          ),
                          TextSpan(
                            text: (isCol ? "  " : "\n") + classroomStr,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.0),
                          ),
                        ]
                    ),
                  ),
                ),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                      isColOf3 ? EdgeInsets.symmetric(vertical: 0.01 * width, horizontal: 0.005 * width) : EdgeInsets.all(0.01 * width)),
                  backgroundColor: MaterialStateProperty.all(
                      AppTheme.getColor(colorIndex),
                  ),
                  shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero)),
                  overlayColor: MaterialStateProperty.all(
                      const Color.fromRGBO(255, 255, 255, 0.2)),
                )),
              width: isCol ? colWidth / colSize : colWidth,
              height: rowHeight * course.subject.hours[i],
              left: colWidth * (course.subject.days[i][j] - ((course.subject.days[i][j] == 7 && !isSatNeeded) ? 1 : 0)) +
                  (isCol ? (drawingIndex * colWidth) / colSize : 0),
              top: rowHeight * (course.subject.bgnPeriods[i][j] - bgnHour + 1) +
                  2 * (course.subject.bgnPeriods[i][j] - bgnHour),
            ),
          );
        }
      }
    });

    return Stack(
        children: [
          SingleChildScrollView(
            child: Stack(
              children: [
                Stack(
                  children: coursesList,
                )
              ],
            ),
          ),
        ]
    );

  }

  List<CollisionData> collisionsTemp = [];

  List<CollisionData> findCourseCollisionsWithIndex(int scheduleIndex) {

    return findCourseCollisions(widget.schedules[scheduleIndex].scheduleCourses);

  }

  List<CollisionData> findCourseCollisions(List<Course> courses) {

    collisionsTemp = [];

    courses.forEach((course1) {

      for (int i1 = 0 ; i1 < course1.subject.days.length ; i1++) {
        for (int j1 = 0 ; j1 < course1.subject.days[i1].length ; j1++) {

          int day1 = course1.subject.days[i1][j1], bgnHour1 = course1.subject.bgnPeriods[i1][j1], hours1 = course1.subject.hours[i1];

          courses.forEach((course2) {

            // Check if they are not the same:
            if (course1.subject.isEqual(course2.subject)) {
              return;
            }

            for (int i2 = 0 ; i2 < course2.subject.days.length ; i2++) {
              for (int j2 = 0 ; j2 < course2.subject.days[i2].length ; j2++) {

                int day2 = course2.subject.days[i2][j2], bgnHour2 = course2.subject.bgnPeriods[i2][j2], hours2 = course2.subject.hours[i2];

                // Check if both courses collide:
                if (day1 == day2 &&
                    ((bgnHour1 >= bgnHour2 && bgnHour1 < (bgnHour2 + hours2)) || ((bgnHour1 + hours1) > bgnHour2 && (bgnHour1 + hours1) < (bgnHour2 + hours2)))) {
                  // yes, they collide
                  // Then check if they BOTH already exist inside collisions List:
                  if (!checkIfBothTogetherExistInCollisions(course1.subject, bgnHour1, course2.subject, bgnHour2, day1)) { // No they dont BOTH TOGETHER exist inside one collision:

                    // Then, check if ONLY one of both exist inside a collision:
                    List<int> data = checkIfOneExistInCollisions(course1.subject, bgnHour1, course2.subject, bgnHour2, day1);
                    if (data[0] != -1) {
                      // If yes, then check if one of course1, course2 or the rest of the courses actually collide with the rest of the courses in the collision:

                      //if (checkIfCommonCourseCollidesWithAll(commonSub, day1, bgnHour, data[0])) {
                      // if yes, then add the course that is NOT in common:
                      collisionsTemp[data[0]].subjects.add(data[1] == 2 ? course1.subject : course2.subject);
                      collisionsTemp[data[0]].subjectsData.add(PeriodData(day: day1, bgnPeriod: data[1] == 2 ? bgnHour1 : bgnHour2, hours: data[1] == 2 ? hours1 : hours2));
                      collisionsTemp[data[0]].isDrawn.add(false);
                      //}

                    } else { // Since they both collide, and none of one them already collides with any other course and they were not already added to cols
                      // So add them as a collision of 2:
                      PeriodData data1 = PeriodData(day: day1, bgnPeriod: bgnHour1, hours: hours1), data2 = PeriodData(day: day2, bgnPeriod: bgnHour2, hours: hours2);
                      collisionsTemp.add(CollisionData(subjects: [course1.subject, course2.subject], subjectsData: [data1, data2]));
                    }
                  }
                  // They already exist inside collisions, so dont add them
                }
                // if both courses dont collide, then do nothing!
              }
            }

          });

        }

      }

    });

    return collisionsTemp;

  }

  bool checkIfBothTogetherExistInCollisions(Subject sub1, int bgnHour1, Subject sub2, int bgnHour2, int day) {

    bool isFound1 = false, isFound2 = false;
    for (int i = 0 ; i < collisionsTemp.length ; i++) {

      for (int j = 0 ; j < collisionsTemp[i].subjects.length ; j++) {

        if (isFound1 && isFound2) {
          break;
        } else {
          if (!isFound1 && collisionsTemp[i].subjects[j].isEqual(sub1)) { // if it was not found and both courses are the same: then check the period:
            if (collisionsTemp[i].subjectsData[j].day == day && collisionsTemp[i].subjectsData[j].bgnPeriod == bgnHour1) {
              isFound1 = true;
            }
          }
          if (!isFound2 && collisionsTemp[i].subjects[j].isEqual(sub2)) { // if it was not found and both courses are the same: then check the period:
            if (collisionsTemp[i].subjectsData[j].day == day && collisionsTemp[i].subjectsData[j].bgnPeriod == bgnHour2) {
              isFound2 = true;
            }
          }
        }
      }
      if (isFound1 && isFound2) {
        break;
      } else { // reset at the end of each collision
        isFound1 = false;
        isFound2 = false;
      }
    }

    return isFound1 && isFound2;

  }

  List<int> checkIfOneExistInCollisions(Subject sub1, int bgnHour1, Subject sub2, int bgnHour2, int day) {

    for (int i = 0 ; i < collisionsTemp.length ; i++) {

      for (int j = 0 ; j < collisionsTemp[i].subjects.length ; j++) {

        if (collisionsTemp[i].subjects[j].isEqual(sub1) && collisionsTemp[i].subjectsData[j].day == day && collisionsTemp[i].subjectsData[j].bgnPeriod == bgnHour1) {
          return [i, 1];
        }

        if (collisionsTemp[i].subjects[j].isEqual(sub2) && collisionsTemp[i].subjectsData[j].day == day && collisionsTemp[i].subjectsData[j].bgnPeriod == bgnHour2) {
          return [i, 2];
        }

      }
    }

    return [-1];

  }

  Container? showCourseInfo(Course course) {

    Subject subject = course.subject;

    String name = subject.customName;

    String classrooms = "", teachers = "", departments = "";

    List<List<String>> classroomsList = subject.classrooms;

    classrooms = classroomsList.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");
    departments = subject.departments.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");
    if (subject.getTranslatedTeachers().isEmpty) {
      teachers = subject.teacherCodes.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");
    } else {
      teachers = subject.getTranslatedTeachers();
    }

    List<String> list = classrooms.split(",").toList();
    list = deleteRepitions(list);
    classrooms = list.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");

    list = teachers.split(",").toList();
    list = deleteRepitions(list);
    teachers = list.toString().replaceAll(RegExp("[\\[.*?\\]]"), "");

    classrooms.trim();
    teachers.trim();
    departments.trim();

    showAdaptiveActionSheet(
      bottomSheetColor: Main.appTheme.scaffoldBackgroundColor,
      context: context,
      title: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Center(child: Text(name, style: TextStyle(color: Main.appTheme.titleTextColor, fontSize: 16, fontWeight: FontWeight.bold))),
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
                  Expanded(child: Container(padding: EdgeInsets.fromLTRB(width * 0.05, 0, 0, 0), child: Text(departments, style: TextStyle(color: Main.appTheme.titleTextColor)))),
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
                  course.note.isNotEmpty ? Icon(CupertinoIcons.text_aligncenter, color: Main.appTheme.titleTextColor) : Container(),
                  Expanded(child: Container(padding: EdgeInsets.fromLTRB(width * 0.05, 0, 0, 0), child: Text(course.note, style: TextStyle(color: Main.appTheme.titleTextColor)))),
                ]
            ),
          ),
        ],
      ),
      actions: [],
      cancelAction: CancelAction(title: const Text('Close')),
    );

    return null;

  }

}
