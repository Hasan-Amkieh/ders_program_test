import 'package:flutter/material.dart';

class CounterButton extends TextButton {

  bool isIncrement;

  CounterButton({required this.isIncrement, required onPressed}) : super(
      onPressed: onPressed,
      child: Icon(isIncrement ? Icons.add : Icons.remove, color: Colors.white),
      style: ButtonStyle(
        padding: MaterialStateProperty.all(EdgeInsets.zero),
        overlayColor: MaterialStateProperty.all(const Color.fromRGBO(255, 255, 255, 0.2)),
        backgroundColor: MaterialStateProperty.all(Colors.blue),
        shape: MaterialStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(1000.0)))),

        shadowColor: MaterialStateProperty.all(Colors.black),
    )
  );

}

