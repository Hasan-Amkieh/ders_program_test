
import '../main.dart';

class University {

  // NOTE: Add only functions, no attributes are allowed unless they are constants

  static bool areFacsSupported() {

    switch(Main.uni) {

      case "Atilim":
        return true;

      case "Bilkent":
        return false;

      default:
        print("[ERROR] The university entered is not supported!");
        print(StackTrace.current);
        return false;

    }

  }

  static bool areDepsSupported() {

    switch(Main.uni) {

      case "Atilim":
        return true;

      case "Bilkent":
        return false;

      default:
        print("[ERROR] The university entered is not supported!");
        print(StackTrace.current);
        return false;

    }

  }

  static List<String> getFaculties() {

    switch (Main.uni) {

      case "Atilim":
        return [
          "Engineering",
          "Business",
          "Fine Arts",
          "Arts and Sciences",
          "Civil Aviation",
          "Law",
          "Health Sciences"
        ];
      case "Bilkent":
        return [];
      default:
        return [];

    }

  }

  static int getBgnMinutes() { // getEndMinutes

    switch (Main.uni) {
      case "Atilim":
        return 30;
      case "Bilkent":
        return 30;
      default:
        return 30;
    }

  }

  static int getEndMinutes() { // getEndMinutes

    switch (Main.uni) {
      case "Atilim":
        return 20;
      case "Bilkent":
        return 20;
      default:
        return 20;
    }

  }

  static String addMinsToBgnPeriod(int hr) {

    return hr.toString() + ":" + getBgnMinutes().toString();

  }

  static stringToBgnPeriod(String str) {

    return int.parse(str.substring(0, str.indexOf(":")));

  }

  static Map<String, String> getFacultyDeps(String faculty) {

    switch (Main.uni) {
      case "Atilim":
        switch (faculty) {
          case "Business":
            return {
              "ECON" : "Economics", // In English
              "IR" : "International Relations",
              "KAM" : "Political Science & Business Admin.",
              "LOG" : "International Trade and Logistics",
              "MAN" : "Business Administration (English)",
              "ISL" : "Business Administration (Turkish)",
              "MLY" : "Public Finance",
              "PR" : "Public Relations and Advertising",
              "TOUR" : "Tourism Management"
            };
          case "Fine Arts":
            return {
              "EUT" : "Industrial Product Design", // Endüstriyel Ürün Tasarımı
              "GRT" : "Graphics Design", // Grafik Tasarim
              "ICM" : "Interior Architecture & Env. Design", // and Environmental Design , I cut Env. word bcs no space
              "MMR" : "Architecture", // Mimar
              "MMT" : "Textile and Fashion Design",
            };
        // case "Law": // The university removed support for Law
        //   return {
        //     "LAW" : "Law", // hukuk
        //     "Adalet" : "Justice"
        //   };
          case "Arts and Sciences":
            return {
              "ELIT" : "English Language and Literature",
              "ETI" : "English Translation and Interpretation",
              "MATH" : "Mathematics",
              "PSY" : "Psychology",
            };
          case "Health Sciences":
            return { // TODO: Look For CHL1 and do smth about it
              "NURS" : "Nursery",
              "NUT" : "Nutrition and Dietetics",
              "PTR" : "Physiotherapy and Rehabilitation",
            };
          case "Civil Aviation":
            return {
              "AEE" : "Avionics",
              "APM" : "Airframe & Powerplant Maintenance",
              "AVM" : "Aviation Management",
              "PLT" : "Pilot Training",
            };
          case "Engineering":
            return {
              "AE" : "Automotive Engineering",
              "ASE" : "Aerospace Engineering",
              "CE": "Civil Engineering",
              "CEAC": "Chemical Engineering",
              "CMPE": "Computer Engineering",
              "EE": "Electrical Engineering",
              "ENE": "Energy Engineering",
              "IE": "Industrial Engineering",
              "ISE": "Information Systems Engineering",
              "MATE": "Material Engineering",
              "ME": "Mechanical Engineering",
              "MECE": "Mechatronics Engineering",
              "MFGE": "Manufacturing Engineering",
              "SE": "Software Engineering"
            };
          default:
            return {};
        }
      case "Bilkent": // Bilkent does not need to have faculties nor departments
        return {};
      default:
        print("[ERROR] The university entered is not supported!");
        print(StackTrace.current);

        return {};
    }

  }

  static String getFacultyLink(String depName) {

    switch (Main.uni) {
      case "Atilim":
        {
          if (getFacultyDeps("Engineering").keys.contains(depName)) {
            return Main.engineeringLink;
          } else if (getFacultyDeps("Civil Aviation").keys.contains(depName)) {
            return Main.civilAviationLink;
          } else if (getFacultyDeps("Health Sciences").keys.contains(depName)) {
            return Main.healthSciencesLink;
          } else if (getFacultyDeps("Arts and Sciences").keys.contains(depName)) {
            return Main.artsNSciencesLink;
          } else if (getFacultyDeps("Fine Arts").keys.contains(depName)) {
            return Main.fineArtsLink;
          } else if (getFacultyDeps("Law").keys.contains(depName)) {
            return Main.lawLink;
          } else if (getFacultyDeps("Business").keys.contains(depName)) {
            return Main.businessLink;
          }
        }
        break;
      case "Bilkent": // Bilkent does not need to have faculties nor departments
        return "";
      default:
        print("[ERROR] The university entered is not supported!");
        print(StackTrace.current);

        return "";
    }

    return "";

  }

}
