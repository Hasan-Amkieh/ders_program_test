import "dart:io" show Platform;
import 'dart:ui';

import 'package:Atsched/language/dictionary.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Atsched/main.dart';

class ExamsPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {

    return ExamsPageState();
  }

}

class ExamsPageState extends State<ExamsPage> {

  @override
  Widget build(BuildContext context) {

    double width = (window.physicalSize / window.devicePixelRatio).width, height = (window.physicalSize / window.devicePixelRatio).height;

    double iconSize = (const Icon(Icons.info_outline, color: Colors.blue).size ?? ((window.physicalSize / window.devicePixelRatio).width) * 0.025);

    return Scaffold(
      backgroundColor: Main.appTheme.scaffoldBackgroundColor,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight((MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * (Platform.isWindows ? 0.05 : 0.1)),
          child: AppBar(backgroundColor: Main.appTheme.headerBackgroundColor)
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Main.exams.isEmpty ? Center(child: SizedBox(
              height: height * 0.75,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.archivebox_fill, color: Main.appTheme.titleIconColor, size: iconSize * 1.5),
                  SizedBox(height: height * 0.025),
                  Text(translateEng("No upcoming exams"), style: TextStyle(color: Main.appTheme.titleTextColor), textAlign: TextAlign.center),
                ],
              ),
            )) :
            SizedBox(
              width: width,
              height: height * 0.95 - iconSize,
              child: ListView.builder(
                itemCount: Main.exams.length,
                itemBuilder: (context, count) {
                  return ListTile(
                    title: Column(
                      children: [
                        Text(Main.exams[count].subject, style: TextStyle(color: Main.appTheme.titleTextColor)),
                        Text(Main.exams[count].classrooms, style: TextStyle(color: Main.appTheme.titleTextColor)),
                        Text(Main.exams[count].date.day.toString() + "-" + Main.exams[count].date.month.toString() + "-" + Main.exams[count].date.year.toString()+ " " + Main.exams[count].time, style: TextStyle(color: Main.appTheme.titleTextColor)),
                        SizedBox(
                          height: height * 0.025,
                        ),
                      ],
                    ),
                    onTap: null,
                  );
                },
              ),
            ),
            TextButton.icon(
              icon: Icon(Icons.search),
              label: Text("Search"),
              onPressed: () {

              },
            ),
          ],
        ),
      ),
    );

  }


}
