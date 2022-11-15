
import 'dart:ui';
import 'dart:io'show Platform;

import 'package:Atsched/widgets/emptycontainer.dart';
import 'package:flutter/material.dart';

import '../language/dictionary.dart';
import '../main.dart';
import '../others/university.dart';

class ChooseSettingsPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {

    return ChooseSettingsState();

  }

}

class ChooseSettingsState extends State<ChooseSettingsPage> {

  @override
  void initState() {

    super.initState();

  }

  @override
  Widget build(BuildContext context) {

    double width = (window.physicalSize / window.devicePixelRatio).width;
    double height = (window.physicalSize / window.devicePixelRatio).height;

    ;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_forward_rounded),
        onPressed: () {
          Navigator.popAndPushNamed(context, "/webpage");
        },
      ),
      backgroundColor: Main.appTheme.navigationBarColor,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(80, 86, 107, 1.0),
                  Color.fromRGBO(60, 64, 72, 1.0),
            ]),
          ),
          // width: width, // unnecessary
          // height: height, // unnecessary
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("lib/icons/" + Main.uni.toLowerCase() + ".png", width: width * 0.20, height: height * 0.20),
              DropdownButton<String>(
                dropdownColor: Main.appTheme.scaffoldBackgroundColor,
                value: Main.uni,
                items: Main.unis.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem(
                    value: value, // Image.asset("lib/icons/atacs.png", width: IconTheme.of(context).size!, height: IconTheme.of(context).size!)
                    child: Text(translateEng(value), style: TextStyle(color: Main.appTheme.titleTextColor)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    Main.uni = newValue!;
                  });
                },
              ),
              SizedBox(
                height: height * 0.01,
              ),
              University.areFacsSupported() ? DropdownButton<String>(
                dropdownColor: Main.appTheme.scaffoldBackgroundColor,
                value: Main.faculty,
                items: University.getFaculties().map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem(value: value, child: Text(translateEng(value), style: TextStyle(color: Main.appTheme.titleTextColor)));
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue == Main.faculty) {
                    return;
                  }
                  setState(() {
                    Main.faculty = newValue!;
                    Main.department = University.getFacultyDeps(Main.faculty).keys.elementAt(0);
                  });
                },
              ) : EmptyContainer(),
              SizedBox(
                height: height * 0.01,
              ),
              University.areDepsSupported() ? DropdownButton<String>(
                dropdownColor: Main.appTheme.scaffoldBackgroundColor,
                value: Main.department,
                items: University.getFacultyDeps(Main.faculty).keys.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem(value: value, child: Row(children: [
                    Text(translateEng(value) + "  ", style: TextStyle(color: Main.appTheme.titleTextColor)),
                    Text(translateEng(University.getFacultyDeps(Main.faculty)[value]!),
                        style: TextStyle(fontSize: 10, color: Main.appTheme.titleTextColor))
                  ],),);
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    Main.department = newValue!;
                  });
                },
              ) : EmptyContainer(),
              SizedBox(
                height: height * 0.01,
              ),
              DropdownButton<String>(
                dropdownColor: Main.appTheme.scaffoldBackgroundColor,
                value: Main.language,
                items: langs.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem(
                    value: value,
                    child: TextButton.icon(onPressed: null, icon: Image.asset("lib/icons/" + value + ".png"),
                        label: Text(translateEng(value), style: TextStyle(color: Main.appTheme.titleTextColor))
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    Main.language = newValue!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );

  }

}
