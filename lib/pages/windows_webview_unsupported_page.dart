
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

class WebviewUnsupported extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: const Text('Do you really want to quit?'),
                actions: [
                  ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Yes')),
                  ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('No')),
                ]);
          });
    });

    double height = (window.physicalSize / window.devicePixelRatio).height;

    return Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.info, color: Colors.black.withOpacity(0.8), size: (IconTheme.of(context).size ?? 64) * 3),
              SizedBox(height: height * 0.025),
              const Text('"WebView2 Runtime" is needed for Atsched\nPlease download it and restart the computer', style: TextStyle(fontSize: 18)),
              SizedBox(height: height * 0.025),
              TextButton.icon(
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                label: const Text("Download WebView2 Runtime", style: TextStyle(fontSize: 16, fontFamily: "Times New Roman", color: Colors.white)),
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.2)),
                ),
                onPressed: () async {
                  const url = 'https://developer.microsoft.com/en-us/microsoft-edge/webview2/#download-section';
                  if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                  } else {
                  throw 'Could not launch $url';
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );

  }

}
