
import 'dart:convert';
import 'dart:io' show HttpClient, Platform;

import 'package:Atsched/others/subject.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../language/dictionary.dart';
import '../main.dart';

class University {

  // NOTE: Add only functions, no attributes are allowed unless they are constants

  // Here all the specific universities variables are to be stored:
  // Bilkent has the semester code stored in here:
  static Map<String, String> variables = {};

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

  static Future<String> getSubjectSyllabusLink(Subject sub) async {

    switch (Main.uni) {

      case "Atilim":
        try {
          var request = await (HttpClient()..connectionTimeout = const Duration(seconds: 5)).getUrl(Uri.parse('https://www.atilim.edu.tr/get-lesson-ects/' + sub.getCourseCodeWithoutSectionNumber().replaceAll(" ", "")));
          var response = await request.close();
          await for (var contents in response.transform(const Utf8Decoder())) {
            return contents;
          }
        } catch(e) {
          print("ERROR: $e");
        }

        break;

      case "Bilkent": // ARCH/301 / from ARCH301
        String str = sub.getCourseCodeWithoutSectionNumber();
        return ('https://stars.bilkent.edu.tr/syllabus/view/' +
            str.substring(0, str.indexOf(RegExp("[1-9]"))) + "/" + str.substring(str.indexOf(RegExp("[1-9]"))) + "/");

    }

    return "";

  }

  static List<Widget> getLinksPageWidgets(double width, double iconWidth) {

    switch (Main.uni) {

      case "Atilim":

        return [
          Container(
            padding: EdgeInsets.fromLTRB(0, 0.03 * width, 0, 0),
            child: ListTile(
              leading: Image.asset("lib/icons/atacs.png", width: iconWidth, height: iconWidth),
              title: Text('Atacs', style: TextStyle(color: Main.appTheme.titleTextColor)),
              onTap: () async {
                const url = 'https://atacs.atilim.edu.tr/Anasayfa/Student';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: ListTile(
              leading: Icon(Icons.schedule, color: Main.appTheme.titleTextColor),
              title: Text(translateEng("School's Schedules"), style: TextStyle(color: Main.appTheme.titleTextColor)),
              onTap: () async {
                const url = 'https://www.atilim.edu.tr/en/dersprogrami';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                } else {
                  throw 'Could not launch $url';
                }
              },
            ),
          ),
        ];

      default:
        return [];

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

  static bool areExamsSupported() {

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
          // "Law", // It is the university's fault, they stopped supporting the Law faculky inside the edupage website
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

  static Image getImageBg() {

    switch (Main.uni) {

      case "Atilim":
        return Image.asset("lib/icons/atilim_" + (Platform.isWindows ? "landscape" : "portrait") + "_bg.jpeg");
      case "Bilkent":
        return Image.asset("lib/icons/bilkent_" + (Platform.isWindows ? "landscape" : "portrait") + "_bg.jpg");
      default:
        return Image.asset("lib/icons/atilim_landscape_bg.jpeg");

    }

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

  static Future<String> getFacultyLink(String depName) async {

    switch (Main.uni) {
      case "Atilim":

        // Before, the links need to be received from the uni website:
        // print("update: ${Main.forceUpdate} / internet: ${Main.isInternetOn}"); Main.forceUpdate
        if (Main.forceUpdate && Main.isInternetOn &&
            (Main.semesterName.isEmpty || Main.artsNSciencesLink.isEmpty ||
                /* law is deleted*/ Main.fineArtsLink.isEmpty || Main.businessLink.isEmpty
                || Main.engineeringLink.isEmpty || Main.civilAviationLink.isEmpty || Main.healthSciencesLink.isEmpty)) {

          try {

            // print("Getting the new links: ");
            var request = await (HttpClient()..connectionTimeout = const Duration(seconds: 5)).getUrl(Uri.parse('https://www.atilim.edu.tr/en/dersprogrami'));
            // sends the request
            var response = await request.close();

            // print("The status code is : ${response.statusCode}");
            // transforms and prints the response
            if (response.statusCode == 200) {
              await for (var contents in response.transform(const Utf8Decoder())) {
                int pos;

                if (Main.semesterName.isEmpty) {
                  int pos_;
                  int start;
                  pos = contents.indexOf('https://atilimartsci'); // first search for
                  if (pos != -1) {
                    start = contents.lastIndexOf('<table', pos);
                    pos_ = contents.lastIndexOf('Schedule', pos);
                    if (pos_ == -1 || pos_ < start) {
                      pos_ = contents.lastIndexOf('schedule', pos);
                    }
                    if (pos_ == -1 || pos_ < start) {
                      pos_ = contents.lastIndexOf('SCHEDULE', pos);
                    }
                    if (pos_ == -1 || pos_ < start) {
                      pos_ = contents.lastIndexOf('School', pos);
                    }
                    if (pos_ == -1 || pos_ < start) {
                      pos_ = contents.lastIndexOf('SCHOOL', pos);
                    }
                    if (pos_ == -1 || pos_ < start) {
                      pos_ = contents.lastIndexOf('school', pos);
                    }

                    if (pos_ != -1 && pos_ > start) { // then the semester name is found:

                      pos = contents.lastIndexOf('>', pos_) + 1;
                      pos_ = contents.indexOf('<', pos_);
                      Main.semesterName = contents.substring(pos, pos_);
                      Main.semesterName = Main.semesterName.replaceAll("&nbsp;", " ");

                    }
                  }
                }

                if (Main.artsNSciencesLink.isEmpty) {
                  pos = contents.indexOf('https://atilimartsci');
                  if (pos != -1) {
                    Main.artsNSciencesLink = contents.substring(pos, contents.indexOf('"', pos + 32));
                  }
                }
                if (Main.fineArtsLink.isEmpty) {
                  pos = contents.indexOf('https://atilimgstm');
                  if (pos != -1) {
                    Main.fineArtsLink = contents.substring(pos, contents.indexOf('"', pos + 32));
                  }
                }
                if (Main.lawLink.isEmpty) {
                  pos = contents.indexOf('https://atilimlaw');
                  if (pos != -1) {
                    Main.lawLink = contents.substring(pos, contents.indexOf('"', pos + 32));
                  }
                }
                if (Main.businessLink.isEmpty) {
                  pos = contents.indexOf('https://atilimmgmt');
                  if (pos != -1) {
                    Main.businessLink = contents.substring(pos, contents.indexOf('"', pos + 32));
                  }
                }
                if (Main.engineeringLink.isEmpty) {
                  pos = contents.indexOf('https://atilimengr');
                  if (pos != -1) {
                    Main.engineeringLink = contents.substring(pos, contents.indexOf('"', pos + 32));
                  }
                }
                if (Main.healthSciencesLink.isEmpty) {
                  pos = contents.indexOf('https://atilimhlth');
                  if (pos != -1) {
                    Main.healthSciencesLink = contents.substring(pos, contents.indexOf('"', pos + 32));
                  }
                }
                if (Main.civilAviationLink.isEmpty) {
                  pos = contents.indexOf('https://atilimcav');
                  if (pos != -1) {
                    Main.civilAviationLink = contents.substring(pos, contents.indexOf('"', pos + 32));
                  }
                }
              }
            } else {
              Main.forceUpdate = false;
              return "";
            }

            // print("found the following links: "
            //     "${Main.artsNSciencesLink}\n${Main.fineArtsLink}\n${Main.businessLink}\n${Main.engineeringLink}\n${Main.civilAviationLink}\n${Main.healthSciencesLink}\n${Main.lawLink}");


          } catch (e) {
            Main.forceUpdate = false;
            print("ERROR: $e");
            return "";
          }

        }

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
      // case "Bilkent": // Bilkent does not need to have faculties nor departments,
      //thus while using Bilkent university this function SHOULDN'T BE USED!!!
      default:
        print("[ERROR] The university entered is not supported!");
        print(StackTrace.current);

        return "";
    }

    return "";

  }

}
