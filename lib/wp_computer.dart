import 'dart:ffi';

import 'package:Atsched/pages/loading_update_page.dart';
import 'package:flutter/material.dart';
import 'main.dart';

//import 'package:ders_program_test/others/spring_schedules.dart';

class WPComputer extends StatefulWidget { // WP stands for Webpage

  @override
  State<StatefulWidget> createState() {
    return WPComputerState();
  }

}

class WPComputerState extends State<WPComputer> {

  static int state = 0;

  static bool doNotRestart = false;

  static WPComputerState? currentState;

  @override
  void initState() {

    super.initState();

    final _changeWindowName = LoadingUpdateState.nativeApiLib?.lookup<NativeFunction<Void Function()>>('changeWindowName');
    Function changeWindowName = _changeWindowName!.asFunction<void Function()>();
    changeWindowName();

    currentState = this;
    currWidget = this;

    state = 1;
    Main.scraper.getTimetableData(null, null);

  }

  @override
  Widget build(BuildContext context) {
    return LoadingUpdate();
  }

  static WPComputerState? currWidget;

  void finish() {

    Navigator.pushNamed(context, "/home");

  }

}