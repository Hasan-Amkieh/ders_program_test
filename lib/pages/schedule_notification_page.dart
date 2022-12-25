
import 'dart:io';
import 'dart:ui';

import 'package:Atsched/pages/saved_schedules_page.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class ScheduleNotificationPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return ScheduleNotificationPageState();
  }

}

class ScheduleNotificationPageState extends State {

  @override
  Widget build(BuildContext context) {

    double width = (window.physicalSize / window.devicePixelRatio).width;
    double height = (window.physicalSize / window.devicePixelRatio).height;

    return Scaffold(
      backgroundColor: Main.appTheme.scaffoldBackgroundColor,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight((MediaQuery.of(context).orientation == Orientation.portrait ? width : height) * (Platform.isWindows ? 0.05 : 0.1)),
          child: AppBar(backgroundColor: Main.appTheme.headerBackgroundColor)),
      body: SafeArea(
        child: ListView.separated(
          itemCount: Main.schedules[SavedSchedulePageState.schedIndex].changes.length,
          itemBuilder: (context, index) {
            var time = Main.schedules[SavedSchedulePageState.schedIndex].changes[index].time;
            return Container(
              margin: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    splashColor: Colors.red.withOpacity(0.5),
                    color: Colors.red,
                    highlightColor: Colors.red.withOpacity(0.25),
                    splashRadius: IconTheme.of(context).size! + 5,
                    icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                    onPressed: () {
                      setState(() {
                        Main.schedules[SavedSchedulePageState.schedIndex].changes.removeAt(index);
                      });
                    },
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: RichText(
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                text: "The ${Main.schedules[SavedSchedulePageState.schedIndex].changes[index].typeOfChange} has changed from ${Main.schedules[SavedSchedulePageState.schedIndex].changes[index].oldDate} into ${Main.schedules[SavedSchedulePageState.schedIndex].changes[index].newData} inside the course ${Main.schedules[SavedSchedulePageState.schedIndex].changes[index].subjectChanged.courseCode}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Main.appTheme.titleTextColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${time.year}-${time.month}-${time.day} ${time.hour}:${time.minute}",
                                  style: TextStyle(fontSize: Platform.isWindows ? 14 : 10, color: Main.appTheme.subtitleTextColor),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
          separatorBuilder: (context, index) {
            return const Divider(height: 0);
          },
        ),
      ),
    );

  }

}
