
import 'package:ders_program_test/language/teacherdictionary.dart';

class FacultySemester {

  List<Subject> subjects = []; // all subject codes taken inside this semester (with the section number)
  DateTime validDate;
  DateTime lastUpdate;
  String facName; // Faculty name

  FacultySemester({required this.facName, required this.validDate, required this.lastUpdate});

}

class Subject { // represents a class

  String classCode; // PHYS102(1) // Use this Main.classcodes to get the full name
  List<String> departments; // CMPE 1 Reg.
  List<List<String>> classrooms;
  List<List<String>> teacherCodes;
  List<int> hours = [];
  List<List<int>> bgnPeriods = [];
  List<List<int>> days = [];

  late String teachersTranslated = "";

  // NOTE: This is not stored inside the files, this is to be done when the subject object is created!
  late final List<String> forDeps; // It has a list of the departments that can take this course
  // e.g. [CMPE, CEAC, CE, EE, General Electives]
  // NOTE: There is another department called General Electives

  // Only used for custom courses
  String customName; // if it is empty, then it is not a custom class, and vice versa

  Subject({required this.classCode, required this.departments,
    required this.teacherCodes, required hours, required List<List<int>> bgnPeriods,
    required List<List<int>> days, required this.classrooms, this.customName = ""}) {
    // In each separate class, we can have multiple teachers with multiple classrooms

    teacherCodes.forEach((list) {
      list.forEach((element) {
        teachersTranslated = teachersTranslated + ", ${translateTeacher(element)}";
      });
    });
    if (teachersTranslated.length >= 2) {
      teachersTranslated = teachersTranslated.substring(2);
    }

    for (int i = 0 ; i < days.length ; i++) {
      if (days[i].isEmpty) {
        days.removeAt(i);
      }
      if (bgnPeriods[i].isEmpty) {
        bgnPeriods.removeAt(i);
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

  @override
  // This function is used to store all the info of the subject into a single string
  // example: CMPE 1 Reg.,MECE 1 Reg.|[B1007,B2032][1020]|[Sedar Water,Whatever Justdoit][Earth Fofo]|2,3|1,5|1,6
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

    String toReturn = depSec + '|' + classroomSec + '|' + teacherSec + '|' + hrSec + '|' + periodSec + '|' + daySec;

    return toReturn;
  }

  // TODO: This function is used to convert a string into a Subject object
  /*static Subject fromString(String str) {
    Subject subject = Subject(classCode: , departments: , teacherCodes: ,
        hours: , bgnPeriods: , days: , classrooms: );
    return subject;
  }*/

  int getSection() { // Get the section number of the class

    if (!classCode.contains('(')) {
      return 0;
    }

    return int.parse(classCode.substring(classCode.indexOf('(') + 1));

  }

}

// TODO: Use this class

class Course { // This class is used inside the favourite and schedule courses, it indirectly inherits the class Subject

  Subject subject;
  String note;

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

  List<Notification> changes;
  List<Course> scheduleCourses;

  Schedule({required this.changes, required this.scheduleCourses});

}



