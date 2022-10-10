import 'dart:ui';

import 'package:Atsched/language/dictionary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';

import '../main.dart';

class UpdatePage extends StatelessWidget {

  static bool isCloseFuncSet = false;

  @override
  Widget build(BuildContext context) {

    if (!isCloseFuncSet) {
      isCloseFuncSet = true;
      FlutterWindowClose.setWindowShouldCloseHandler(() async {
        return await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  title: Text('Do you really want to quit?' + (Main.forceUpdate ? "\nNext time you open Atsched the update will start" : "")),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          Main.save();
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Yes')),
                    ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('No')),
                  ]
              );
            });
      });
    }

    // double width = (window.physicalSize / window.devicePixelRatio).width;
    double height = (window.physicalSize / window.devicePixelRatio).height;

    return Scaffold(backgroundColor: Colors.blue,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.update, size: 48, color: Colors.white),
          SizedBox(
            height: height * 0.05,
          ),
          Text(
            translateEng("There is a newer version of this application,\nplease update the application first!"),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontFamily: "Times New Roman", fontSize: 16),
          ),
        ],
      ),
    );

  }

}
