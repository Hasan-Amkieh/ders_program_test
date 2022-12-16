import 'dart:convert';
import 'dart:io';

import 'package:Atsched/pages/loading_update_page.dart';
import 'package:flutter/material.dart';
import 'package:Atsched/main.dart';

import 'others/university.dart';

//import 'package:Atsched/others/spring_schedules.dart';

class WPPhone extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return WPPhoneState();
  }

}

class WPPhoneState extends State<WPPhone> {

  static int state = 0;

  static bool doNotRestart = false;

  static WPPhoneState? currentState;

  @override
  void initState() {

    super.initState();

    currentState = this;
    currWidget = this;

    state = 1;
    Main.scraper.getTimetableData();

  }

  Future<void> getTimetableLinks() async {

    switch (Main.uni) {
      case "Atilim":
        facLink = await University.getFacultyLink(Main.department);

        var request = await HttpClient().getUrl(Uri.parse('https://www.atilim.edu.tr/en/dersprogrami'));
        // sends the request
        var response = await request.close();

        // transforms and prints the response
        await for (var contents in response.transform(const Utf8Decoder())) {
          int pos;

          if (semesterName.isEmpty) {
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
                semesterName = contents.substring(pos, pos_);
                semesterName = semesterName.replaceAll("&nbsp;", " ");

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
        break;


    }

  }

  String facLink = "";
  String semesterName = "";

  @override
  Widget build(BuildContext context) {

    getTimetableLinks();

    return Scaffold(
      body: Stack(
          children: [
            LoadingUpdate(),
          ],
      ),
    );
  }

  static WPPhoneState? currWidget;

  void finish() {

    Navigator.pushNamed(context, "/home");

  }

}
