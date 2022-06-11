import 'dart:ui';

import 'package:ders_program_test/language/dictionary.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../main.dart';

class EditCoursePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return EditCoursePageState();
  }

}

// TODO: At the main page, the first widget is a row of three buttons, which are the modes, Select mode, Edit mode, Delete mode
// TODO: Open up an animated dialog that will show up from the bottom and center at the middle of the page:
// TODO: At the same button position it will be split into two buttons, left green for accept, the right is red for decline: 4
// TODO: At that dialog, we will have text fields for all the information and a big text field for the note,

class EditCoursePageState extends State<EditCoursePage> {

  static int mode = 0; // 0 - view / 1 - edit / 2 - remove
  late double width, height;
  static const Duration duration = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {

    width = (window.physicalSize / window.devicePixelRatio).width; // Because if it is converted from portrait to landscape or the opposite, the width changes
    height = (window.physicalSize / window.devicePixelRatio).height;

    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(child: const Icon(Icons.add), tooltip: translateEng("Add a course") ,onPressed: () {

        Navigator.pushNamed(context, "/home/editcourses/addcourses");

      }),
      body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(width * 0.05),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 0.05 * width,
                    ),
                    AnimatedContainer(
                      duration: duration,
                      curve: Curves.easeIn,
                      decoration: BoxDecoration(
                        // TODO: Change it into the theme background color
                        //color: mode == 2 ? Colors.blue : Colors.white,
                        //borderRadius: BorderRadius.circular(100.0),
                        border: Border(bottom: BorderSide(color: mode == 0 ? Colors.grey.shade700 : Theme.of(context).scaffoldBackgroundColor, width: 2)),
                      ),
                      child: Container(
                        child: IconButton(
                          tooltip: translateEng("view mode"),
                          splashColor: Colors.transparent,
                          icon: Icon(Icons.remove_red_eye_outlined, color: mode == 0 ? Colors.grey.shade700 : Colors.blue),
                          onPressed: () {
                            setState(() {
                              if (mode != 0) {
                                mode = 0;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: duration,
                      curve: Curves.easeIn,
                      decoration: BoxDecoration(
                        // TODO: Change it into the theme background color
                        //color: mode == 2 ? Colors.blue : Colors.white,
                        //borderRadius: BorderRadius.circular(100.0),
                        border: Border(bottom: BorderSide(color: mode == 1 ? Colors.green.shade700 : Theme.of(context).scaffoldBackgroundColor, width: 2)),
                      ),
                      child: Container(
                        child: IconButton(
                          tooltip: translateEng("edit mode"),
                          splashColor: Colors.transparent,
                          icon: Icon(Icons.edit_note, color: mode == 1 ? Colors.green.shade700 : Colors.blue),
                          onPressed: () {
                            setState(() {
                              if (mode != 1) {
                                mode = 1;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: duration,
                      curve: Curves.easeIn,
                      decoration: BoxDecoration(
                        // TODO: Change it into the theme background color
                        //color: mode == 2 ? Colors.blue : Colors.white,
                        //borderRadius: BorderRadius.circular(100.0),
                        border: Border(bottom: BorderSide(color: mode == 2 ? Colors.red.shade700 : Theme.of(context).scaffoldBackgroundColor, width: 2)),
                      ),
                      child: Container(
                        child: IconButton(
                          tooltip: translateEng("delete mode"),
                          splashColor: Colors.transparent,
                          icon: Icon(Icons.delete, color: mode == 2 ? Colors.red.shade700 : Colors.blue),
                          onPressed: () {
                            setState(() {
                              if (mode != 2) {
                                mode = 2;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 0.05 * width,
                    ),
                  ],
                ),
                Expanded(
                  child: Container(padding: EdgeInsets.symmetric(horizontal: 0.02 * width, vertical: 0.1 * height),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent
                        ),
                        child: buildList()
                      )
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  Widget buildList() {

    Color color = Colors.blue;
    switch (mode) {
      case 0:
        color = Colors.grey.shade700;
        break;
      case 1:
        color = Colors.green.shade700;
        break;
      case 2:
        color = Colors.red.shade700;
        break;
    }

    if (Main.scheduleCourses.isEmpty) {
      return Text(translateEng("You have no courses in the current schedule"));
    } else {
      return ListView.builder(itemCount: Main.scheduleCourses.length, itemBuilder: (context, index) {
        return AnimatedContainer(
          //margin: EdgeInsets.symmetric(vertical: 0.01 * width),
          duration: duration,
          decoration: BoxDecoration(
            border: Border(left: BorderSide(width: 3.0, color: color), top: BorderSide(width: height * 0.05, color: Colors.transparent)),
          ),
          child: Container(
            child: ListTile(
              style: ListTileStyle.drawer,
              contentPadding: EdgeInsets.fromLTRB(width * 0.02, 0, 0, 0),
              title: Text(Main.scheduleCourses.elementAt(index).classCode),
              onTap: () {

                if (mode == 0) { // view

                } else if (mode == 1) { // edit

                } else { // remove
                  setState(() {
                    String str = Main.scheduleCourses.elementAt(index).classCode;
                    Main.scheduleCourses.removeAt(index);
                    Fluttertoast.showToast(
                        msg: "$str " + translateEng("was removed"),
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        fontSize: 12.0
                    );
                  });
                }

              },
            ),
          ),
        );
      });
    }

  }

}
