
import 'package:ders_program_test/language/teacherdictionary.dart';

class FacultySemester {

  List<Subject> subjects = []; // all subject codes taken inside this semester (with the section number)
  DateTime validDate;
  DateTime lastUpdate;
  String facName; // Faculty name

  FacultySemester({required this.facName, required this.validDate, required this.lastUpdate});

}

class Subject { // represents a class

  final String classCode; // PHYS102(1) // Use this Main.classcodes to get the full name
  final List<String> departments; // CMPE 1 Reg.
  final List<List<String>> classrooms;
  final List<List<String>> teacherCodes;
  final List<int> hours;
  final List<int> bgnPeriods;
  final List<int> days;

  late String teachersTranslated = "";

  // NOTE: This is not stored inside the files, this is to be done when the subject object is created!
  late final List<String> forDeps; // It has a list of the departments that can take this course
  // e.g. [CMPE, CEAC, CE, EE, General Electives]
  // NOTE: There is another department called General Electives

  Subject({required this.classCode, required this.departments,
    required this.teacherCodes, required this.hours, required this.bgnPeriods,
    required this.days, required this.classrooms}) {
    // In each separate class, we can have multiple teachers with multiple classrooms

    teacherCodes.forEach((list) {
      list.forEach((element) {
        teachersTranslated = teachersTranslated + ", ${translateTeacher(element)}";
      });
    });
    if (teachersTranslated.length >= 2) {
      teachersTranslated = teachersTranslated.substring(2);
    }

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

