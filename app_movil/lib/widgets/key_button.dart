import 'package:flutter/material.dart';

class KeyButton extends StatelessWidget {
  final double progress;
  final bool isCounting;
  final Color circleColor;
  final VoidCallback onTap;

  const KeyButton({
    super.key,
    required this.progress,
    required this.isCounting,
    required this.circleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _KeyButtonPainter(progress, isCounting, circleColor),
        child: Container(
          width: 175,
          height: 175,
          alignment: Alignment.center,
          child: Image.asset('assets/key.png', width: 150),
        ),
      ),
    );
  }
}

class _KeyButtonPainter extends CustomPainter {
  final double progress;
  final bool isCounting;
  final Color circleColor;

  _KeyButtonPainter(this.progress, this.isCounting, this.circleColor);

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;

    final Paint outerCircle = Paint()
      ..color = const Color(0xFF013B72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 70;

    canvas.drawCircle(Offset(radius, radius), radius - 1, outerCircle);

    if (!isCounting) {
      final Paint fullPaint = Paint()
        ..color = circleColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 70;

      canvas.drawCircle(Offset(radius, radius), radius - 20, fullPaint);
    } else {
      final Paint passedArc = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 70;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius - 20),
        -90 * 0.0174533,
        -360 * (1 - progress) * 0.0174533,
        false,
        passedArc,
      );

      final Paint remainingArc = Paint()
        ..color = circleColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 70;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius - 20),
        (-90 + 360 * progress) * 0.0174533,
        -360 * progress * 0.0174533,
        false,
        remainingArc,
      );
    }

    final Paint innerCircle = Paint()
      ..color = const Color(0xFF013B72)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(radius, radius), radius, innerCircle);
  }

  @override
  bool shouldRepaint(covariant _KeyButtonPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isCounting != isCounting ||
        oldDelegate.circleColor != circleColor;
  }
}
