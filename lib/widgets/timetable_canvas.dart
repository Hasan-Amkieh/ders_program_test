import 'dart:ui' as ui;

import 'package:Atsched/main.dart';
import 'package:flutter/material.dart';

import '../language/dictionary.dart';

class TimetableCanvas extends CustomPainter {

  List<List<int>> beginningPeriods;
  List<List<int>> days;
  List<int> hours;
  bool isForSchedule;
  TimetableCanvas({required this.beginningPeriods, required this.days, required this.hours, required this.isForSchedule});

  @override
  void paint(Canvas canvas, size) {

    List<List<int>> reservedPeriods = [];

    //TODO: Complete drawing the following timetable to nicely express the time of the course in the week:

    double actualWidth = (size.width - 4);
    double actualHeight = (size.height - 4);
    double colWidth = (actualWidth / 7).floorToDouble(), rowHeight = (actualHeight ~/ 11).floorToDouble();

    double periodOffset = isForSchedule ? 0.2 : 0.05;
    double dayOffset = isForSchedule ? 0.35 : 0.25;

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
    final style = TextStyle(fontSize: 10, color: Main.appTheme.titleTextColor);
    TextPainter textPainter = TextPainter(
        text: TextSpan(text: translateEng("Mo"), style: style),
        textAlign: TextAlign.justify,
        textDirection: TextDirection.ltr
    )
      ..layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * (1 + dayOffset), rowHeight * 0.25));

    textPainter.text = TextSpan(text: translateEng("Tu"), style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * (2 + dayOffset), rowHeight * 0.25));

    textPainter.text = TextSpan(text: translateEng("We"), style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * (3 + dayOffset), rowHeight * 0.25));

    textPainter.text = TextSpan(text: translateEng("Th"), style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * (4 + dayOffset), rowHeight * 0.25));

    textPainter.text = TextSpan(text: translateEng("Fr"), style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * (5 + dayOffset) + 3, rowHeight * 0.25));

    textPainter.text = TextSpan(text: translateEng("Sa"), style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * (6 + dayOffset) + 4, rowHeight * 0.25));

    // clock:
    textPainter.text = TextSpan(text: "9:30", style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * periodOffset, rowHeight * 1.25));

    textPainter.text = TextSpan(text: "10:30", style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * periodOffset, rowHeight * 2.25));

    textPainter.text = TextSpan(text: "11:30", style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * periodOffset, rowHeight * 3.25));

    textPainter.text = TextSpan(text: "12:30", style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * periodOffset, rowHeight * 4.25));

    textPainter.text = TextSpan(text: "13:30", style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * periodOffset, rowHeight * 5.25));

    textPainter.text = TextSpan(text: "14:30", style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * periodOffset, rowHeight * 6.25));

    textPainter.text = TextSpan(text: "15:30", style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * periodOffset, rowHeight * 7.25));

    textPainter.text = TextSpan(text: "16:30", style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * periodOffset, rowHeight * 8.25));

    textPainter.text = TextSpan(text: "17:30", style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * periodOffset, rowHeight * 9.25));

    textPainter.text = TextSpan(text: "18:30", style: style);
    textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
    textPainter.paint(canvas, Offset(colWidth * periodOffset, rowHeight * 10.25));

    Paint periodPaint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.fill;

    Paint periodPaintCol = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    double dx, dy;
    Rect rect;

    //print("days: $days / bgnperiods: $beginningPeriods / hours: $hours");
    // Expressing the time and date of the course by drawing boxes:
    bool isCol = false;
    for (int i = 0 ; i < days.length ; i++) {
      for (int j = 0 ; j < days[i].length ; j++) {
        for (int l = 0 ; l < hours[i] ; l++) { // I just had a mental break down writing this part of code
          isCol = false;
          for (int k = 0 ; k < reservedPeriods.length ; k++) {
            if (reservedPeriods[k][0] == days[i][j] && reservedPeriods[k][1] == (beginningPeriods[i][j] + l)) {
              isCol = true;
              break;
            }
          }
          if (!isCol) {
            reservedPeriods.add([days[i][j], beginningPeriods[i][j] + l]);
          }

          dx = (days[i][j]) * colWidth + (days[i][j] == 1 ? 1 : 0);
          dy = (beginningPeriods[i][j] + l) * rowHeight + 1; // (beginningPeriods[i][j] == 1 ? 1 : 0)

          rect = Offset(dx, dy) & ui.Size(colWidth * (days[i][j] == 6 ? 1.09 : 1.00), rowHeight * 1);
          canvas.drawRect(rect, isCol ? periodPaintCol : periodPaint);
        }
      }
    }

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;



}
