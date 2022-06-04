import 'dart:ui';

import 'package:ders_program_test/language/dictionary.dart';
import 'package:ders_program_test/others/departments.dart';
import 'package:ders_program_test/subject.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/searchwidget.dart';


class SearchPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return SearchPageState();
  }

}

class SearchPageState extends State<SearchPage> {

  String query = "";
  List <Subject> subjects = Main.semesters[0].subjects;
  bool onlyInCurrDep = true;
  List<String> deps = [];
  String depToSearch = "-";

  @protected
  @mustCallSuper
  void initState() {
    deps.addAll(faculties[Main.faculty]!.keys);
    deps.add("-");
  }

  @override
  Widget build(BuildContext context) {

    double width = (window.physicalSize / window.devicePixelRatio).width, height = (window.physicalSize / window.devicePixelRatio).height;
    print("Putting ${subjects.length} subjects into the page");

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(width * 0.03),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(translateEng("Only search in this department")),
                  DropdownButton<String>(
                    value: depToSearch,
                    items: deps.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem(value: value, child: Text(value)
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        depToSearch = newValue!;
                        ;
                      });
                    },
                  )
                ],
              ),
              SearchWidget(
                text: query,
                hintText: "Course code, teacher name or classroom",
                onChanged: search,
              ),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    return buildSubject(subjects[index]);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );

  }

  ListTile buildSubject(Subject sub) {

    double width = (window.physicalSize / window.devicePixelRatio).width, height = (window.physicalSize / window.devicePixelRatio).height;

    return ListTile(
      title: Text(sub.classCode),
      onTap: () {
        String? name = Main.classcodes[sub.classCode];
        print("subject name is: $name");
        showDialog(context: context,
            builder: (context) => AlertDialog(
              title: Text(sub.classCode),
              content: Builder(
                builder: (context) {
                  return Container(
                      height: height * 0.4,
                      child: Scrollbar( // Just to make the scrollbar viewable
                        thumbVisibility: true,
                        child: ListView(
                          children: [
                            ListTile(
                              title: Row(children: [Expanded(child: Text(translateEng("Name: ") + name!))]),
                              onTap: null,
                            ),
                            ListTile(
                              title: Row(children: [Expanded(child: Text(translateEng("Classrooms: ") + sub.classrooms.toString()))]),
                              onTap: null,
                            ),
                            ListTile(
                              title: Row(children: [Expanded(child: Text(translateEng("Teachers: ") + sub.teacherCodes.toString()))]),
                              onTap: null,
                            ),
                            ListTile(
                              title: Row(children: [Expanded(child: Text(translateEng("Departments: ") + sub.departments.toString()))]),
                              onTap: null,
                           ),
                          ],
                        ),
                      )
                  );
                }
              ),
              actions: [
                TextButton(onPressed: () {
                  Navigator.pop(context);
                }, child: Text(translateEng("OK")))
            ],
          ),
          );
        },
    );

  }

  void search(String query) {

    final subjects = Main.semesters[0].subjects.where((element) {

      ;

      return true;
    }).toList();

    setState(() {
      this.query = query;
      this.subjects = subjects;
    });

  }

}
