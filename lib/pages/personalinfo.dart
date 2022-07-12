import 'dart:ui';

import 'package:ders_program_test/language/dictionary.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

class PersonalInfo extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    double width = (window.physicalSize / window.devicePixelRatio).width;
    double height = (window.physicalSize / window.devicePixelRatio).height;

    return Scaffold(
      backgroundColor: Main.appTheme.scaffoldBackgroundColor,
      appBar: AppBar(backgroundColor: Main.appTheme.headerBackgroundColor),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: height * 0.03, horizontal: width * 0.15),
            child: Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: height * 0.1,
                    backgroundImage: Image.asset("lib/icons/personal_pic.jpg").image,
                  ),
                  SizedBox(height: height * 0.03),
                  Text("Hasan Amkieh", style: TextStyle(color: Main.appTheme.titleTextColor, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: "Times New Roman")),
                  SizedBox(height: height * 0.1),
                  Text(
                    translateEng(
                        "Studying Computer Engineering at Atilim\n\n"
                            "I made this app to help students choose and set up their courses prior the course registration phase, it aims to help the student avoid courses' conflicts\n"
                            "It helps the students to easily share their schedules with their friends by a screenshot of the schedule or by a generated link\n"
                            "I wanted to leave something remarkable that will help all the students, I hope that I have achieved my purpose, it took me 2 months, I hope the time that I have spent was worth it"
                    ),
                    style: TextStyle(height: 2.0, fontSize: 16, color: Main.appTheme.titleTextColor),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.05),
                  GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("lib/icons/github.png", width: width * 0.1, height: width * 0.1),
                        SizedBox(width: width * 0.05),
                        Text("Github", style: TextStyle(color: Main.appTheme.titleTextColor),),
                      ],
                    ),
                    onTap: () async {
                      const url = 'https://github.com/Hasan-Amkieh';
                      if (await canLaunch(url)) {
                      await launch(url);
                      } else {
                      throw 'Could not launch $url';
                      }
                    },
                  ),
                  SizedBox(height: height * 0.03),
                  GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("lib/icons/stackoverflow.png", width: width * 0.1, height: width * 0.1),
                        SizedBox(width: width * 0.05),
                        Text("Stackoverflow", style: TextStyle(color: Main.appTheme.titleTextColor)),
                      ],
                    ),
                    onTap: () async {
                      const url = 'https://stackoverflow.com/users/9381321/hasan-shadi';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

  }



}
