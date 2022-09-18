import 'dart:io';
import 'dart:ui';

import 'package:Atsched/language/dictionary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';

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

    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: Text(Main.isInternetOn ? "The internet is back, please close the app and open it again" : "After connecting to the internet, open the app again"),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        Main.save();
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('Yes')),
                  ElevatedButton(
                      onPressed: () { Main.newFaculty = ""; Navigator.of(context).pop(false); },
                      child: const Text('No')),
                ]
            );
          });
    });

  }

  static void check() {

    Future.delayed(const Duration(milliseconds: 500), () async {
      await checkInternet();
      if (Main.isInternetOn) {
        if (Platform.isWindows) {
          FlutterWindowClose.closeWindow();
        } else {
          Main.restart();
        }
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
                  translateEng("No internet connection\nconnect to the internet please"),
                  style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.5), textAlign: TextAlign.center
              ),
            ],
          ),
        ),
      ),
    );

  }
}
