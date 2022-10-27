import 'dart:ui' as ui;

import 'package:Atsched/main.dart';
import 'package:Atsched/others/subject.dart';
import 'package:Atsched/others/university.dart';
import 'package:flutter/material.dart';

import '../language/dictionary.dart';

class TimetableCanvas extends CustomPainter {

  List<List<int>> beginningPeriods;
  List<List<int>> days;
  List<int> hours;
  bool isForSchedule;
  bool isForClassrooms;
  PeriodData wantedPeriod;

  TimetableCanvas({required this.beginningPeriods, required this.days, required this.hours, required this.isForSchedule, required this.isForClassrooms, required this.wantedPeriod});

  static bool isSatNeeded = false;
  static bool isSunNeeded = false;

  static List<int> neededHrs = [9, 10, 11, 12, 13, 14, 15, 16, 17, 18];

  static const List<String> days_ = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"];

  @override
  void paint(Canvas canvas, size) {

    isSatNeeded = false;
    isSunNeeded = false;

    for (int x = 0 ; x < days.length ; x++) {
      for (int y = 0 ; y < days[x].length ; y++) {
        if (!isSatNeeded || !isSunNeeded) {
          if (days[x][y] == 6) {
            isSatNeeded = true;
          }
          if (days[x][y] == 7) {
            isSunNeeded = true;
          }
        } else {
          break;
        }
      }
      if (isSatNeeded && isSunNeeded) {
        break;
      }
    }

    List<List<int>> reservedPeriods = [];

    double actualWidth = (size.width - 0);
    double actualHeight = (size.height - 4);
    double colWidth = (actualWidth / (6 + (isSunNeeded ? 1 : 0) + (isSatNeeded ? 1 : 0))).floorToDouble(), rowHeight = (actualHeight ~/ 11).floorToDouble();

    // print("Divisions: ${6 + (isSunNeeded ? 1 : 0) + (isSatNeeded ? 1 : 0)}");

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
      ..strokeWidth = 1.0;


    // rows:
    for (int i = 1 ; i < 11 ; i++) {
      canvas.drawLine(Offset(0, rowHeight * i), Offset(size.width, rowHeight * i), innerBarrierLinesPaint);
    }

    // cols:
    for (int i = 1 ; i < (6 + (isSatNeeded ? 1 : 0) + (isSunNeeded ? 1 : 0)) ; i++) {
      canvas.drawLine(Offset(colWidth * i, 0), Offset(colWidth * i, size.height), specInnerBarrierLinesPaint);
    }

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

    List<String> days__ = [];
    days__.addAll(days_);

    if (isSunNeeded && !isSatNeeded) {
      days__.removeAt(5);
    }

    for (int i = 2 ; i < (6 + (isSatNeeded ? 1 : 0) + (isSunNeeded ? 1 : 0)) ; i++) {
      textPainter.text = TextSpan(text: translateEng(days__[i - 1]), style: style);
      textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
      textPainter.paint(canvas, Offset(colWidth * (i + dayOffset), rowHeight * 0.25));
    }

    // clock:

    // neededHrs
    for (int i = 0 ; i < neededHrs.length ; i++) {
      textPainter.text = TextSpan(text: neededHrs[i].toString() + ":" + University.getBgnMinutes().toString(), style: style);
      textPainter.layout(maxWidth: size.width - 12.0 - 12.0);
      textPainter.paint(canvas, Offset(colWidth * periodOffset, rowHeight * (i + 1.25)));
    }

    Paint periodPaint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.fill;

    Paint periodPaintCol = Paint()
      ..color = isForClassrooms ? Colors.blue : Colors.red
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

          dx = (days[i][j] - ((isSunNeeded && !isSatNeeded) ? 1 : 0)) * colWidth + (days[i][j] == 1 ? 1 : 0);
          dy = (beginningPeriods[i][j] + l) * rowHeight + 1; // (beginningPeriods[i][j] == 1 ? 1 : 0)

          rect = Offset(dx, dy) & ui.Size(colWidth * 1, rowHeight * 1);
          canvas.drawRect(rect, isCol ? periodPaintCol : periodPaint);
        }
      }
    }

    if (isForClassrooms && wantedPeriod.day != -1 && wantedPeriod.bgnPeriod != -1 && wantedPeriod.hours != -1) {
      dx = (wantedPeriod.day - ((isSunNeeded && !isSatNeeded) ? 1 : 0)) * colWidth + (wantedPeriod.day == 1 ? 1 : 0);
      dy = (wantedPeriod.bgnPeriod) * rowHeight + 1; // (beginningPeriods[i][j] == 1 ? 1 : 0)

      rect = Offset(dx, dy) & ui.Size(colWidth * 1, rowHeight * wantedPeriod.hours);
      canvas.drawRect(rect, Paint()..color=Colors.green..style=PaintingStyle.fill);
    }

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;



}
