
import 'dart:ui';
import 'dart:io' show Platform;

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

class ChooseSettingsState extends State<ChooseSettingsPage> with SingleTickerProviderStateMixin { // (with) This fixed the error of the compilation of the

  @override
  void initState() {

    super.initState();

    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    animation = CurvedAnimation(parent: controller, curve: Curves.ease);

    controller.animateTo(1.0); // automatically the bg img opacity is set 0.0 thus transparent

  }

  late AnimationController controller;
  late Animation<double> animation;

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Main.appTheme.navigationBarColor,

      body: SafeArea(
        child: Stack(
          children: [
            FadeTransition(
              opacity: animation,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: University.getImageBg().image,
                      fit: BoxFit.fill,
                    ),
                  ),
                  width: width,
                  height: height,
                ),
              ),
            ),
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.025,
                  vertical: width * 0.025,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.all(Radius.circular(width * 0.02)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
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
                        controller.animateTo(0.0).then((value) { // first let the picture disappear, then show the new pic and let it fade in!
                          setState(() {
                            Main.uni = newValue!;
                            controller.animateTo(1.0);
                          });
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
                    SizedBox(height: height * 0.05),
                    TextButton(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(translateEng("Continue")),
                            Icon(Icons.arrow_right, color: Colors.blue),
                          ],
                        ),
                        onPressed: () {
                          Main.assignScrapersNClassifiers();
                          Navigator.popAndPushNamed(context, "/webpage");
                        }
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }

}
