import 'dart:ui';

import 'package:Atsched/language/dictionary.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class UpdatePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    double width = (window.physicalSize / window.devicePixelRatio).width;
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
