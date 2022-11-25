
import 'dart:ui';
import 'dart:io' show Platform;

import 'package:Atsched/main.dart';
import 'package:flutter/material.dart';

class ChoiceBox extends StatefulWidget {

  Icon icon;
  Widget mainText;
  Widget description;
  int number;
  Null Function() onTap;

  ChoiceBox({Key? key, required this.icon, required this.mainText, required this.description, required this.number, required this.onTap})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChoiceBoxState();
  }

}

class ChoiceBoxState extends State<ChoiceBox> {

  @override
  void initState() {

    super.initState();

  }

  @override
  Widget build(BuildContext context) {

    double width = (window.physicalSize / window.devicePixelRatio).width;
    double height = (window.physicalSize / window.devicePixelRatio).height;
      /**/

    return TextButton(
      onPressed: () {
        widget.onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Main.appTheme.scaffoldBackgroundColor.withBlue(Main.appTheme.scaffoldBackgroundColor.blue + 8)
              .withRed(Main.appTheme.scaffoldBackgroundColor.red + 8).withGreen(Main.appTheme.scaffoldBackgroundColor.green + 8),
          borderRadius: BorderRadius.circular(width * 0.05),
        ),
        padding: EdgeInsets.all(width * 0.02),
        width: width * (Platform.isWindows ? 0.18 : 0.35),
        height: width * (Platform.isWindows ? 0.18 : 0.35),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    widget.icon,
                    SizedBox(width: width * 0.01),
                    widget.mainText
                  ],
                ),
                Visibility(
                  visible: widget.number != -1,
                  child: Text(widget.number.toString(), style: TextStyle(color: Main.appTheme.titleTextColor)),
                ),
              ],
            ),
            // SizedBox(
            //   height: height * 0.02,
            // ),
            SizedBox(
              height: (Platform.isWindows ? 0.02 : 0.5) * width,
            ),
            widget.description,
          ],
        ),
      ),
    );

  }



}
