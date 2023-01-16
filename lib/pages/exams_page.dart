import "dart:io" show Platform;
import 'dart:ui';

import 'package:Atsched/language/dictionary.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Atsched/main.dart';

import '../others/subject.dart';

class ExamsPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {

    return ExamsPageState();
  }

}

class ExamsPageState extends State<ExamsPage> {

  static TextEditingController txtController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    double width = (window.physicalSize / window.devicePixelRatio).width, height = (window.physicalSize / window.devicePixelRatio).height;
    h = height;

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
                itemBuilder: buildExamListTile,
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.search),
              label: Text(translateEng("Search")),
              onPressed: () {
                showDialog(context: context, builder: (context) => AlertDialog(
                  backgroundColor: Main.appTheme.scaffoldBackgroundColor,
                  content: SizedBox(
                    height: height * 0.7,
                    width: width * 0.55,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(translateEng("Search by course code"), style: TextStyle(color: Main.appTheme.titleTextColor)),
                        Container(
                          color: Main.appTheme.scaffoldBackgroundColor,
                          height: height * 0.65,
                          child: StatefulBuilder(
                            builder: (context, setState) {
                              return Column(
                                children: [
                                  TextFormField(
                                    controller: txtController,
                                    style: TextStyle(color: Main.appTheme.titleTextColor),
                                    cursorColor: Main.appTheme.titleTextColor,
                                    decoration: InputDecoration(
                                      icon: Icon(Icons.search, color: txtController.text.isNotEmpty ? Colors.blue : Main.appTheme.titleTextColor),
                                      hintStyle: TextStyle(color: Main.appTheme.hintTextColor),
                                      hintText: "E.g. ENG101",
                                      labelStyle: TextStyle(color: Main.appTheme.titleTextColor),
                                      labelText: translateEng("SEARCH"),
                                    ),
                                    onChanged: (String qry) {
                                      setState(() {
                                        search(qry);
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                        itemCount: result.length,
                                        itemBuilder: buildExamListTile_,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: const Text("Close"),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ));
              },
            ),
          ],
        ),
      ),
    );

  }

  List<Exam> result = [];
  List<Exam> original = Main.exams; // not to be changed
  String searchText = "";

  void search(String query) {

    searchText = query;
    result = original.where((e) => e.subject.toLowerCase().contains(query.toLowerCase())).toList();

  }

  double h = 0.0;

  Widget buildExamListTile(context, count) {

    return ListTile(
      title: Column(
        children: [
          Text(Main.exams[count].subject, style: TextStyle(color: Main.appTheme.titleTextColor)),
          Text(Main.exams[count].classrooms, style: TextStyle(color: Main.appTheme.titleTextColor)),
          Text(Main.exams[count].date.day.toString() + "-" + Main.exams[count].date.month.toString() + "-" + Main.exams[count].date.year.toString()+ " " + Main.exams[count].time, style: TextStyle(color: Main.appTheme.titleTextColor)),
          SizedBox(
            height: h * 0.025,
          ),
        ],
      ),
      onTap: null,
    );
  }

  Widget buildExamListTile_(context, count) {

    return ListTile(
      title: Column(
        children: [
          Text(result[count].subject, style: TextStyle(color: Main.appTheme.titleTextColor)),
          Text(result[count].classrooms, style: TextStyle(color: Main.appTheme.titleTextColor)),
          Text(result[count].date.day.toString() + "-" + result[count].date.month.toString() + "-" + result[count].date.year.toString()+ " " + result[count].time, style: TextStyle(color: Main.appTheme.titleTextColor)),
          SizedBox(
            height: h * 0.025,
          ),
        ],
      ),
      onTap: null,
    );
  }

}
