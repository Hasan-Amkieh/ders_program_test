
import 'dart:ui';
import 'dart:io' show Platform;

import 'package:Atsched/main.dart';
import 'package:flutter/material.dart';

class ChoiceBox extends StatefulWidget {

  Widget icon;
  Widget mainText;
  Widget description;
  int number;
  Null Function() onTap;
  bool isVisible;

  ChoiceBox({Key? key, required this.icon, required this.mainText, required this.description, required this.number, required this.onTap, required this.isVisible})
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

  bool isHovered = false;

  @override
  Widget build(BuildContext context) {

    double width = (window.physicalSize / window.devicePixelRatio).width;
    // double height = (window.physicalSize / window.devicePixelRatio).height;

    double choiceBoxWidth = width * (Platform.isWindows ? 0.2 : 0.43);
    // double choiceBoxHeight = width * (Platform.isWindows ? 0.2 : 0.5);

    return Visibility(
      visible: widget.isVisible,
      maintainAnimation: true,
      maintainState: true,
      maintainSize: true,
      child: TextButton(
        style:
          ButtonStyle(overlayColor: MaterialStateProperty.all(Colors.red.withOpacity(0))),
        onPressed: null,
        child: Material(
          color: Main.appTheme.scaffoldBackgroundColor.withBlue(Main.appTheme.scaffoldBackgroundColor.blue + (isHovered ? 16 : 8))
              .withRed(Main.appTheme.scaffoldBackgroundColor.red + (isHovered ? 16 : 8))
              .withGreen(Main.appTheme.scaffoldBackgroundColor.green + (isHovered ? 16 : 8)),
          borderRadius: BorderRadius.circular(width * 0.05),
          child: InkWell(
            onTap: () {
              widget.onTap();
            },
            borderRadius: BorderRadius.circular(width * 0.05),
            splashColor: Colors.blueGrey.withOpacity(0.1),
            onHover: (isHovering) {
              setState(() {isHovered = isHovering;});
            },
            child: Container(
              padding: EdgeInsets.all(width * 0.02),
              width: width * (Platform.isWindows ? 0.2 : 0.43),
              height: width * (Platform.isWindows ? 0.2 : 0.5),
              margin: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(visible: !Platform.isWindows, child: widget.icon),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Visibility(visible: Platform.isWindows, child: widget.icon),
                          SizedBox(width: width * 0.01),
                          SizedBox(
                              width: choiceBoxWidth * 0.5,
                              child: Flex(direction: Axis.horizontal,
                              children: [
                                Expanded(child: widget.mainText),
                              ],
                          )),
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
                    height: (Platform.isWindows ? 0.02 : 0.05) * width,
                  ),
                  widget.description,
                ],
              ),
            ),
          ),
        ),
      ),
    );

  }



}
