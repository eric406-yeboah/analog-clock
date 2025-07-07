import 'dart:math';
import 'package:flutter/scheduler.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnalogClock(),
      ),
    ),
  ));
}

class AnalogClock extends StatefulWidget {
  @override
  State<AnalogClock> createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  DateTime _dateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Use Ticker for smooth updates
    _ticker = Ticker((_) {
      setState(() {
        _dateTime = DateTime.now();
      });
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 300,
          height: 300,
          child: CustomPaint(
            painter: ClockPainter(_dateTime),
          ),
        ),
        SizedBox(height: 20),
        Text(
          '${_dateTime.hour.toString().padLeft(2, '0')}:${_dateTime.minute.toString().padLeft(2, '0')}:${_dateTime.second.toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class ClockPainter extends CustomPainter {
  final DateTime dateTime;

  ClockPainter(this.dateTime);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final fillBrush = Paint()..color = Colors.white;

    final outlineBrush = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final centerFillBrush = Paint()..color = Colors.black;

    final shadow = [
      BoxShadow(
        color: Colors.black.withOpacity(0.5),
        offset: Offset(2, 2),
        blurRadius: 4,
      )
    ];

    final secHandBrush = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final minHandBrush = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final hourHandBrush = Paint()
      ..color = Colors.black
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    // Clock face
    canvas.drawCircle(center, radius - 10, fillBrush);
    canvas.drawCircle(center, radius - 10, outlineBrush);

    // Draw numbers
    for (int i = 1; i <= 12; i++) {
      double angle = (i * 30) * pi / 180;
      double x = center.dx + (radius - 30) * cos(angle - pi / 2);
      double y = center.dy + (radius - 30) * sin(angle - pi / 2);
      TextPainter textPainter = TextPainter(
        text: TextSpan(
            text: '$i',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }

    // Draw hour hand
    double hourDegree =
        (dateTime.hour % 12 + dateTime.minute / 60) * 30 * pi / 180;
    final hourHandX = center.dx + 60 * cos(hourDegree - pi / 2);
    final hourHandY = center.dy + 60 * sin(hourDegree - pi / 2);

    canvas.drawLine(center, Offset(hourHandX, hourHandY), hourHandBrush);

    // Draw minute hand
    double minDegree = (dateTime.minute + dateTime.second / 60) * 6 * pi / 180;
    final minHandX = center.dx + 80 * cos(minDegree - pi / 2);
    final minHandY = center.dy + 80 * sin(minDegree - pi / 2);

    canvas.drawLine(center, Offset(minHandX, minHandY), minHandBrush);

    // Draw second hand
    double secDegree = dateTime.second * 6 * pi / 180;
    final secHandX = center.dx + 90 * cos(secDegree - pi / 2);
    final secHandY = center.dy + 90 * sin(secDegree - pi / 2);

    canvas.drawLine(center, Offset(secHandX, secHandY), secHandBrush);

    // Center dot
    canvas.drawCircle(center, 8, centerFillBrush);

    // Tick marks
    final tickBrush = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    final longTickBrush = Paint()
      ..color = Colors.black
      ..strokeWidth = 4;

    for (int i = 0; i < 60; i++) {
      double tickLength = i % 5 == 0 ? 10 : 5;
      double tickDegree = i * 6 * pi / 180;

      double startX = center.dx + (radius - 10) * cos(tickDegree);
      double startY = center.dy + (radius - 10) * sin(tickDegree);

      double endX =
          center.dx + (radius - 10 - tickLength) * cos(tickDegree);
      double endY =
          center.dy + (radius - 10 - tickLength) * sin(tickDegree);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        i % 5 == 0 ? longTickBrush : tickBrush,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
