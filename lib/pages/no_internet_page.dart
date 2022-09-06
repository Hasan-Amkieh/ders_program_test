import 'dart:io';
import 'dart:ui';

import 'package:Atsched/language/dictionary.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class NoInternetPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return NoInternetPageState();
  }

}

class NoInternetPageState extends State {

  @override
  void initState() {

    super.initState();

    check();

  }

  static void check() {

    Future.delayed(const Duration(milliseconds: 500), () async {
      await checkInternet();
      if (Main.isInternetOn) {
        Main.restart();
      } else {
        check();
      }
    });

  }

  static Future checkInternet() async {

    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Main.isInternetOn = true;
      }
    } on SocketException catch (_) {
      Main.isInternetOn = false;
      // print('NO INTERNET');
    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("lib/icons/no_internet.png", width: MediaQuery.of(context).size.width * 0.25, height: MediaQuery.of(context).size.width * 0.25),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              Text(
                  translateEng("No internet connection\nconnect to the internet please\nIt will automatically restart"),
                  style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.5), textAlign: TextAlign.center
              ),
            ],
          ),
        ),
      ),
    );

  }
}
