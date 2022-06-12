
import 'dart:ffi';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class TimetableCanvas extends CustomPainter {

  List<List<int>> beginningPeriods;
  List<List<int>> days;
  List<int> hours;

  TimetableCanvas({required this.beginningPeriods, required this.days, required this.hours});

  @override
  void paint(Canvas canvas, size) {

    //TODO: Complete drawing the following timetable to nicely express the time of the course in the week:

    double actualWidth = (size.width - 4);
    double actualHeight = (size.height - 4);
    double colWidth = (actualWidth / 7).floorToDouble(), rowHeight = (actualHeight ~/ 11).floorToDouble();

    Paint outerBarrierLinesPaint = Paint()
    ..color = Colors.blueAccent.shade200
    ..strokeWidth = 2.0;

    canvas.drawLine(const Offset(0, 0), Offset(0, size.height), outerBarrierLinesPaint);
    canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), outerBarrierLinesPaint);
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), outerBarrierLinesPaint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, size.height), outerBarrierLinesPaint);

    Paint innerBarrierLinesPaint = Paint()
      ..color = Colors.black45
      ..strokeWidth = 1.0;
    Paint specInnerBarrierLinesPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;


    // rows:
    canvas.drawLine(Offset(0, rowHeight * 1), Offset(size.width, rowHeight * 1), specInnerBarrierLinesPaint);
    canvas.drawLine(Offset(0, rowHeight * 2), Offset(size.width, rowHeight * 2), innerBarrierLinesPaint);
    canvas.drawLine(Offset(0, rowHeight * 3), Offset(size.width, rowHeight * 3), innerBarrierLinesPaint);
    canvas.drawLine(Offset(0, rowHeight * 4), Offset(size.width, rowHeight * 4), innerBarrierLinesPaint);
    canvas.drawLine(Offset(0, rowHeight * 5), Offset(size.width, rowHeight * 5), innerBarrierLinesPaint);
    canvas.drawLine(Offset(0, rowHeight * 6), Offset(size.width, rowHeight * 6), innerBarrierLinesPaint);
    canvas.drawLine(Offset(0, rowHeight * 7), Offset(size.width, rowHeight * 7), innerBarrierLinesPaint);
    canvas.drawLine(Offset(0, rowHeight * 8), Offset(size.width, rowHeight * 8), innerBarrierLinesPaint);
    canvas.drawLine(Offset(0, rowHeight * 9), Offset(size.width, rowHeight * 9), innerBarrierLinesPaint);
    canvas.drawLine(Offset(0, rowHeight * 10), Offset(size.width, rowHeight * 10), innerBarrierLinesPaint);

    // cols:
    canvas.drawLine(Offset(colWidth * 1, 0), Offset(colWidth * 1, size.height), specInnerBarrierLinesPaint);
    canvas.drawLine(Offset(colWidth * 2, 0), Offset(colWidth * 2, size.height), innerBarrierLinesPaint);
    canvas.drawLine(Offset(colWidth * 3, 0), Offset(colWidth * 3, size.height), innerBarrierLinesPaint);
    canvas.drawLine(Offset(colWidth * 4, 0), Offset(colWidth * 4, size.height), innerBarrierLinesPaint);
    canvas.drawLine(Offset(colWidth * 5, 0), Offset(colWidth * 5, size.height), innerBarrierLinesPaint);
    canvas.drawLine(Offset(colWidth * 6, 0), Offset(colWidth * 6, size.height), innerBarrierLinesPaint);

    // Headers:
    // days:
    final style = TextStyle(fontSize: 10, color: Colors.blueGrey);
    TextPainter textPainter = TextPainter(
        text: TextSpan(text: "Mo", style: style),
        textAlign: TextAlign.justify,
        textDirection: TextDirection.ltr
    )
      ..layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * 1.25, rowHeight * 0.25));

    textPainter.text = TextSpan(text: "Tu", style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * 2.25, rowHeight * 0.25));

    textPainter.text = TextSpan(text: "We", style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * 3.25, rowHeight * 0.25));

    textPainter.text = TextSpan(text: "Th", style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * 4.25, rowHeight * 0.25));

    textPainter.text = TextSpan(text: "Fr", style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * 5.25 + 3, rowHeight * 0.25));

    textPainter.text = TextSpan(text: "Sa", style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * 6.25 + 4, rowHeight * 0.25));

    // clock:
    textPainter.text = TextSpan(text: "9:30", style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * 0.05, rowHeight * 1.25));

    textPainter.text = TextSpan(text: "10:30", style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * 0.05, rowHeight * 2.25));

    textPainter.text = TextSpan(text: "11:30", style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * 0.05, rowHeight * 3.25));

    textPainter.text = TextSpan(text: "12:30", style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * 0.05, rowHeight * 4.25));

    textPainter.text = TextSpan(text: "13:30", style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * 0.05, rowHeight * 5.25));

    textPainter.text = TextSpan(text: "14:30", style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * 0.05, rowHeight * 6.25));

    textPainter.text = TextSpan(text: "15:30", style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * 0.05, rowHeight * 7.25));

    textPainter.text = TextSpan(text: "16:30", style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * 0.05, rowHeight * 8.25));

    textPainter.text = TextSpan(text: "17:30", style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * 0.05, rowHeight * 9.25));

    textPainter.text = TextSpan(text: "18:30", style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * 0.05, rowHeight * 10.25));

    Paint periodPaint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.fill;
    double dx, dy;
    Rect rect;
    int hourVal;

    print("days: $days / bgnperiods: $beginningPeriods / hours: $hours");
    // Expressing the time and date of the course by drawing boxes:
    for (int i = 0 ; i < days.length ; i++) {
      for (int j = 0 ; j < days[i].length ; j++) {
        // dx, dy:
        dx = (days[i][j]) * colWidth;
        dy = (beginningPeriods[i][j]) * rowHeight;

        hourVal = hours[i];
        rect = Offset(dx, dy) & ui.Size(colWidth, rowHeight * hourVal);
        canvas.drawRect(rect, periodPaint);
      }
    }

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;



}