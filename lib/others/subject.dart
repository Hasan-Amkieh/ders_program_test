
import 'package:ders_program_test/language/teacherdictionary.dart';

import '../main.dart';

class FacultySemester {

  List<Subject> subjects = []; // all subject codes taken inside this semester (with the section number)
  DateTime lastUpdate;
  String facName; // Faculty name
  String semesterName;

  FacultySemester({required this.facName, required this.lastUpdate, required this.semesterName});

}

class Subject { // represents a class

  String classCode; // PHYS102(1) // Use this Main.classcodes to get the full name
  List<String> departments; // CMPE 1 Reg.
  List<List<String>> classrooms;
  List<List<String>> teacherCodes;
  List<int> hours = [];
  List<List<int>> bgnPeriods = [];
  List<List<int>> days = [];

  late String _teachersTranslated = ""; // Access it using the getter

  // NOTE: This is not stored inside the files, this is to be done when the subject object is created!
  late final List<String> forDeps; // It has a list of the departments that can take this course
  // e.g. [CMPE, CEAC, CE, EE, General Electives]
  // NOTE: There is another department called General Electives

  // Represents the name of the course
  String customName;

  Subject({required this.classCode, required this.departments,
    required this.teacherCodes, required hours, required List<List<int>> bgnPeriods,
    required List<List<int>> days, required this.classrooms, required this.customName}) {
    // In each separate class, we can have multiple teachers with multiple classrooms

    translateTeachers();

    for (int i = 0 ; i < days.length ; i++) {
      if (days[i].isEmpty) {
        days.removeAt(i);
      }
      if (bgnPeriods.isNotEmpty) { // safety, bcs the employees are doing their jobs poorly to fetch the data into the timetable website!
        if (i < bgnPeriods.length && bgnPeriods[i].isEmpty) {
          bgnPeriods.removeAt(i);
        }
      }
    }

    // NOTE: Zeroes should not be accepted and they cause errors inside the app, they have no meaning thus they should be removed


    for (int i = 0 ; i < days.length ; i++) {
      for (int j = 0 ; j < days[i].length ; j++) {
        if (days[i][j] == 0) {
          days[i].removeAt(j);
        }
      }
    }

    for (int i = 0 ; i < bgnPeriods.length ; i++) {
      for (int j = 0 ; j < bgnPeriods[i].length ; j++) {
        if (bgnPeriods[i][j] == 0) {
          bgnPeriods[i].removeAt(j);
        }
      }
    }

    this.days = days;
    this.bgnPeriods = bgnPeriods;

    this.hours = hours.where((element) {
      if (element == 0) {
        return false;
      }
      return true;
    }).toList() as List<int>;

  }

  void translateTeachers() {

    _teachersTranslated = "";
    teacherCodes.forEach((list) {
      list.forEach((element) {
        _teachersTranslated = _teachersTranslated + ", ${translateTeacher(teacherCode: element, subject: Main.emptySubject)}";
      });
    });
    if (_teachersTranslated.length >= 2) {
      _teachersTranslated = _teachersTranslated.substring(2);
    }

  }

  String getTranslatedTeachers() => _teachersTranslated;

  bool isEqual(Subject subjectToComp) {

    return classCode == subjectToComp.classCode;

  }

  @override
  // This function is used to store all the info of the subject into a single string
  // example: Basics of C Programming II|CMPE 1 Reg.,MECE 1 Reg.|[B1007,B2032][1020]|[Sedar Water,Whatever Justdoit][Earth Fofo]|2,3|1,5|1,6
  // departments|classrooms|teacherCodes|hours|bgnPeriods|days
  String toString() {

    String depSec = "", classroomSec = "", teacherSec = "", hrSec = "", periodSec = "", daySec = "", str = "";
    int index = 1, index_;
    departments.forEach((element) {
      depSec = depSec + element;
      if (index < departments.length) {
        depSec = depSec + ',';
      }
      index++;
    });

    index_ = 1;
    classrooms.forEach((list) {
      index = 1;
      if (list.isNotEmpty) {
        str = "[";
        list.forEach((element) {
          str = str + element;
          if (index < list.length) {
            str = str + ',';
          }
          index++;
        });
        str = str + ']';
        classroomSec = classroomSec + str;
        if (index_ < classrooms.length) {
          classroomSec = classroomSec + ',';
        }
      }
      index_++;
    });

    // teacherSec:
    index_ = 1;
    teacherCodes.forEach((list) {
      index = 1;
      if (list.isNotEmpty) {
        str = "[";
        list.forEach((element) {
          str = str + element;
          if (index < list.length) {
            str = str + ',';
          }
          index++;
        });
        str = str + ']';
        teacherSec = teacherSec + str;
        if (index_ < teacherCodes.length) {
          teacherSec = teacherSec + ',';
        }
      }
      index_++;
    });

    // hrSec:
    if (hours.isNotEmpty) {
      hrSec = hours.toString().substring(1, hours.toString().length - 1);
    }

    // bgnHoursSec: (periodSec)
    if (bgnPeriods.isNotEmpty) {
      periodSec = bgnPeriods.toString().substring(1, bgnPeriods.toString().length - 1);
    }

    // daySec: (days)
    if (days.isNotEmpty) {
      daySec = days.toString().substring(1, days.toString().length - 1);
    }

    String toReturn = customName + "|" + depSec + '|' + classroomSec + '|' + teacherSec + '|' + hrSec + '|' + periodSec + '|' + daySec;

    return toReturn;
  }

  static Subject fromStringWithClassCode(String str) {

    String classCode = "", name = "";
    List<String> departments = [];
    List<List<String>> teacherCodes = [], classrooms = [];
    List<List<int>> bgnPeriods = [], days = [];
    List<int> hours = [];

    // print("str is $str");
    List<String> str_ = str.split("|");//str.replaceAll(" ", "").split("|");
    if (str_.length < 7) {
      return Main.emptySubject;
    }
    // print("str_ is $str_");

    classCode = str_[0];
    name = str_[1];
    departments = str_[2].split(',');

    // classrooms:
    List<String> classroomsList = str_[3].split('], [');
    for (int i = 0 ; i < classroomsList.length ; i++) { // delete '[' and ']'
      classroomsList[i] = classroomsList[i].replaceAll('[', '').replaceAll(']', '');
      var l_ = classroomsList[i].split(',');
      l_ = l_.where((element) => element.trim().isNotEmpty).toList();
      classrooms.add(l_);
    }

    // teachers:
    List<String> teachersList = str_[4].split('], [');
    for (int i = 0 ; i < teachersList.length ; i++) { // delete '[' and ']'
      teachersList[i] = teachersList[i].replaceAll('[', '').replaceAll(']', '');
      var l_ = teachersList[i].split(',');
      l_ = l_.where((element) => element.trim().isNotEmpty).toList();
      teacherCodes.add(l_);
    }

    // hours:
    List<String> list;
    if (str_[5].trim().isNotEmpty) {
      list = str_[5].split(',');
      for (int i = 0; i < list.length; i++) {
        hours.add(int.parse(list[i]));
      }
    }

    // bgnPeriods:
    list = str_[6].replaceAll(" ", "").split('],[');
    // print("Orig string: $list");
    list = list.where((element) => element.trim().isNotEmpty).toList();// ["[5, 1, 5]"]
    // list.forEach((element) {print(element);});

    List<int> tempList;
    for (int i = 0 ; i < list.length ; i++) { // delete '[' and ']' // aa|aa||||3, 2|[1], [4]|[1], [2]
      list[i] = list[i].replaceAll('[', '').replaceAll(']', '');
      tempList = [];
      list[i].split(',').forEach((element) { tempList.add(int.parse(element)); });
      // print("temp list: $tempList");
      bgnPeriods.add(tempList);
    }

    // days:
    list = str_[7].replaceAll(" ", "").split('],[');
    list = list.where((element) => element.trim().isNotEmpty).toList();
    for (int i = 0 ; i < list.length ; i++) { // delete '[' and ']'
      list[i] = list[i].replaceAll('[', '').replaceAll(']', '');
      tempList = [];
      list[i].split(',').forEach((element) { if (element.isNotEmpty) {
        tempList.add(int.parse(element));
      } });
      days.add(tempList);
    }

    return Subject(customName: name, classCode: classCode, departments: departments, teacherCodes: teacherCodes,
        hours: hours, bgnPeriods: bgnPeriods, days: days, classrooms: classrooms);
  }

  // static Subject fromStringWithoutClassCode(String str) {
  //   Subject subject = Subject(classCode: classCode, departments: , teacherCodes: ,
  //       hours: , bgnPeriods: , days: , classrooms: );
  //   return subject;
  // }

  static List<String> convertToListWithClassCodes(List<Course> courses) {

    List<String> subjects = [];

    for (int i = 0 ; i < courses.length ; i++) {
      subjects.add(courses[i].subject.classCode + "|" + courses[i].subject.toString());
    }

    return subjects;

  }

  static List<String> convertToListWithoutClassCodes(List<Course> courses) {

    List<String> subjects = [];

    for (int i = 0 ; i < courses.length ; i++) {
      subjects.add(courses[i].subject.toString());
    }

    return subjects;

  }

  int getSection() { // Get the section number of the class

    // if (!classCode.contains('(')) {
    //   return 0;
    // }
    //
    // return int.parse(classCode.substring(classCode.indexOf('(') + 1));

    if (classCode.contains('(')) { // MATH151(1) / MATH151-01 / MATH151- 01
      //print("Found the sec number : ${int.parse(classCode.substring(classCode.indexOf('(') + 1, classCode.indexOf(')')))}");
      return int.parse(classCode.substring(classCode.indexOf('(') + 1, classCode.indexOf(')')));
    } else if (classCode.contains('-')) {
      String str = classCode.substring(classCode.indexOf('-') + 1).trim();
      if (str.contains("0")) {
        str = str.substring(str.indexOf("0") + 1);
        if (str.contains("-")) {
          str = str.substring(0, str.indexOf("-"));
        }
      }
      //print("RETURNING section ${int.parse(str)} for subject ${classCode}");
      // print("Trying to parse $str into a section number");
      if (str.isEmpty) {
        return 0;
      }
      return int.parse(str);
    }

    return 0;

  }

  String getClassCodeWithoutSectionNumber() {

    if (classCode.contains('(')) { // MATH151(1) / MATH151-01 / MATH151- 01
      return classCode.substring(0, classCode.indexOf("("));
    } else if (classCode.contains('-') && classCode.contains("0")) {
      return classCode.substring(0, classCode.indexOf("-"));
    } else if (classCode.contains(' 0')) {
      return classCode.substring(0, classCode.indexOf(" 0"));
    }

    return classCode;

  }

  String getNameWithoutSection() {

    if (customName.contains('(')) { // MATH151(1) / MATH151-01 / MATH151- 01
      return customName.substring(0, customName.indexOf("("));
    } else if (customName.contains('-')) {
      return customName.substring(0, customName.indexOf("-"));
    }

    return customName;

  }

}

class Course { // This class is used inside the favourite and schedule courses, it indirectly inherits the class Subject

  Subject subject;
  String note; // The note is something that is personal, it is not shared with the link share

  Course({required this.note, required this.subject});

}

class Notification {

  Subject subjectChanged;
  String typeOfChange; // classroom / teacher / time&date
  String oldDate;
  String newData;

  Notification({required this.subjectChanged, required this.typeOfChange, required this.oldDate, required this.newData, });

}

class Schedule {

  String scheduleName;
  List<Course> scheduleCourses;
  List<Notification> changes = []; // The changes wont be passed along the Branch link share

  Schedule({required this.scheduleName, required this.scheduleCourses});

}

class PeriodData {

  final int day;
  final int bgnPeriod;
  final int hours;

  PeriodData({required this.day, required this.bgnPeriod, required this.hours});

}

class CollisionData {

  List<Subject> subjects; // We did this, bcs we could have multiple collisions
  List<PeriodData> subjectsData;
  List<bool> isDrawn = [];
  bool is3Col = false; // To determine if it is a collision of 3

  CollisionData({required this.subjects, required this.subjectsData}) {
    for (int i = 0 ; i < subjects.length ; i++) {
      isDrawn.add(false);
    }
  }

}

class SchedulerSubjectData { // used inside the schedule page: stores the chosen sections and whether it is allowed to be collided or not

  bool allowCols; // allow collisions or not
  List<int> sections;

  SchedulerSubjectData({required this.allowCols, required this.sections});

}

