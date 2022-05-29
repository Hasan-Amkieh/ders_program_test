import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ders_program_test/webpage.dart';

List<String> msgs = ["CONNECTING TO THE INTERNET", // state 0
  "CONNECTING TO THE SERVER", // 1
  "RETRIEVING DATA", // 2
  "CLASSIFYING DATA", // 3
  "STORING INFO", // 4
];

class LoadingUpdate extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return LoadingUpdateState();
  }

}

class LoadingUpdateState extends State<LoadingUpdate> {

  String msg = msgs[0];
  TextStyle txtStyle = const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14, fontFamily: "Times New Roman");
  int currentState = 0;

  @override
  void initState() {
    checkState();
    super.initState();
  }

  void checkState () {

    if(currentState != WebpageState.state) {
      setState(() {});
    }

    if (WebpageState.state != 5) {
      Future.delayed(const Duration(milliseconds: 300), () => checkState());
    } else {
      ModalRoute.of(context)?.popped.then((value) {
        print("Loading page is popped!");
        WebpageState.currWidget!.finish();
      });
      Navigator.pop(context);
    }

  }

  @override
  Widget build(BuildContext context) {
    currentState = WebpageState.state;
    Widget loadingWidget;
    switch (currentState) {
      case 0:
        msg = msgs[0];
        loadingWidget = SpinKitFoldingCube(color: Colors.white, size: MediaQuery.of(context).size.width * 0.1);
        break;
      case 1:
        msg = msgs[1];
        loadingWidget = SpinKitHourGlass(color: Colors.white, size: MediaQuery.of(context).size.width * 0.1);
        break;
      case 2:
        msg = msgs[2];
        loadingWidget = SpinKitThreeBounce(color: Colors.white, size: MediaQuery.of(context).size.width * 0.1,);
        break;
      case 3:
        msg = msgs[3];
        loadingWidget = SpinKitRotatingCircle(color: Colors.white, size: MediaQuery.of(context).size.width * 0.1,);
        break;
      case 4:
        msg = msgs[4];
        loadingWidget = SpinKitCubeGrid(color: Colors.white, size: MediaQuery.of(context).size.width * 0.1,);
        break;
      default:
        msg = "The state is indeterminable!";
        loadingWidget = SpinKitFoldingCube(color: Colors.white, size: MediaQuery.of(context).size.width * 0.1);
    }

    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          loadingWidget,
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          Text(msg, style: txtStyle, textAlign: TextAlign.center,),
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Container(
            margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.2, 0, MediaQuery.of(context).size.width * 0.2, 0),
            child: TextButton.icon(onPressed: () {
              // TODO:

              ;
            },
                icon: const Icon(Icons.cancel, color: Colors.white,), label: Text("CANCEL UPDATE", style: txtStyle), style: ButtonStyle(overlayColor: MaterialStateProperty.resolveWith((states) {
                  return Colors.blue.shade300;
                }))),
          )
        ],
      ),
    );
  }

}