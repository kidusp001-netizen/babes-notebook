import 'package:flutter/material.dart';

import '../../config/theme.dart';

/// Minimal line-art illustrations for onboarding — pink queen theme.
class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({super.key, required this.type});

  final OnboardingIllustrationType type;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: CustomPaint(
        painter: _IllustrationPainter(type),
      ),
    );
  }
}

enum OnboardingIllustrationType {
  love,
  journal,
  categories,
  offline,
}

class _IllustrationPainter extends CustomPainter {
  _IllustrationPainter(this.type);

  final OnboardingIllustrationType type;

  static const _ink = Color(0xFF4A1942);
  static const _accent = AppTheme.primary;
  static const _soft = AppTheme.primaryLight;

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case OnboardingIllustrationType.love:
        _paintLove(canvas, size);
      case OnboardingIllustrationType.journal:
        _paintJournal(canvas, size);
      case OnboardingIllustrationType.categories:
        _paintCategories(canvas, size);
      case OnboardingIllustrationType.offline:
        _paintOffline(canvas, size);
    }
  }

  void _paintLove(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Soft glow
    canvas.drawCircle(
      Offset(cx, cy),
      90,
      Paint()..color = _soft.withValues(alpha: 0.6),
    );

    // Heart
    final heart = Path();
    heart.moveTo(cx, cy + 42);
    heart.cubicTo(cx - 70, cy - 10, cx - 42, cy - 58, cx, cy - 28);
    heart.cubicTo(cx + 42, cy - 58, cx + 70, cy - 10, cx, cy + 42);
    canvas.drawPath(
      heart,
      Paint()
        ..color = _accent.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      heart,
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );

    // Crown
    final crown = Path();
    crown.moveTo(cx - 28, cy - 52);
    crown.lineTo(cx - 20, cy - 72);
    crown.lineTo(cx - 8, cy - 58);
    crown.lineTo(cx, cy - 78);
    crown.lineTo(cx + 8, cy - 58);
    crown.lineTo(cx + 20, cy - 72);
    crown.lineTo(cx + 28, cy - 52);
    crown.close();
    canvas.drawPath(
      crown,
      Paint()
        ..color = AppTheme.roseGold.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      crown,
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Sparkles
    _sparkle(canvas, Offset(cx - 80, cy - 20));
    _sparkle(canvas, Offset(cx + 85, cy - 30));
    _sparkle(canvas, Offset(cx + 60, cy + 50), size: 8);
  }

  void _paintJournal(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final top = size.height * 0.18;

    // Notebook
    final book = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 70, top, 140, 180),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      book,
      Paint()..color = _soft.withValues(alpha: 0.5),
    );
    canvas.drawRRect(
      book,
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Spine
    canvas.drawLine(
      Offset(cx - 70, top),
      Offset(cx - 70, top + 180),
      Paint()
        ..color = _accent
        ..strokeWidth = 6,
    );

    // Lines on page
    for (var i = 0; i < 5; i++) {
      final y = top + 40 + i * 24.0;
      canvas.drawLine(
        Offset(cx - 48, y),
        Offset(cx + 52, y),
        Paint()
          ..color = _ink.withValues(alpha: 0.15)
          ..strokeWidth = 1.5,
      );
    }

    // Pen
    final pen = Path();
    pen.moveTo(cx + 55, top + 130);
    pen.lineTo(cx + 110, top + 75);
    pen.lineTo(cx + 118, top + 83);
    pen.lineTo(cx + 63, top + 138);
    pen.close();
    canvas.drawPath(
      pen,
      Paint()..color = _accent.withValues(alpha: 0.35),
    );
    canvas.drawPath(
      pen,
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Cross at top of page
    canvas.drawLine(
      Offset(cx - 10, top + 22),
      Offset(cx + 10, top + 22),
      Paint()
        ..color = _accent
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(cx, top + 12),
      Offset(cx, top + 32),
      Paint()
        ..color = _accent
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintCategories(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    _bubble(canvas, Offset(cx - 70, cy - 30), '♡', _accent);
    _bubble(canvas, Offset(cx + 70, cy - 20), '🙏', AppTheme.roseGold);
    _bubble(canvas, Offset(cx, cy + 55), '✦', const Color(0xFFDB2777));

    // Calendar grid hint
    final gridTop = cy - 90.0;
    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 4; col++) {
        final x = cx - 54 + col * 36;
        final y = gridTop + row * 28;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, 28, 20),
            const Radius.circular(4),
          ),
          Paint()
            ..color = row == 1 && col == 2
                ? _accent.withValues(alpha: 0.35)
                : _ink.withValues(alpha: 0.06),
        );
      }
    }

    // Connecting arcs
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy - 10), radius: 95),
      0.2,
      2.8,
      false,
      Paint()
        ..color = _ink.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _paintOffline(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Cloud
    final cloud = Path();
    cloud.addOval(Rect.fromCircle(center: Offset(cx - 30, cy), radius: 32));
    cloud.addOval(Rect.fromCircle(center: Offset(cx + 10, cy - 12), radius: 38));
    cloud.addOval(Rect.fromCircle(center: Offset(cx + 45, cy + 4), radius: 28));
    canvas.drawPath(
      cloud,
      Paint()..color = _soft,
    );
    canvas.drawPath(
      cloud,
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Heart inside cloud
    final heart = Path();
    heart.moveTo(cx + 8, cy + 12);
    heart.cubicTo(cx - 18, cy - 8, cx - 8, cy - 28, cx + 8, cy - 12);
    heart.cubicTo(cx + 24, cy - 28, cx + 34, cy - 8, cx + 8, cy + 12);
    canvas.drawPath(
      heart,
      Paint()..color = _accent.withValues(alpha: 0.45),
    );

    // Book below
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 72), width: 56, height: 44),
        const Radius.circular(6),
      ),
      Paint()
        ..color = _accent.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 72), width: 56, height: 44),
        const Radius.circular(6),
      ),
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Shield check
    final shield = Path();
    shield.moveTo(cx + 72, cy + 20);
    shield.lineTo(cx + 88, cy + 28);
    shield.lineTo(cx + 88, cy + 48);
    shield.quadraticBezierTo(cx + 88, cy + 68, cx + 72, cy + 78);
    shield.quadraticBezierTo(cx + 56, cy + 68, cx + 56, cy + 48);
    shield.lineTo(cx + 56, cy + 28);
    shield.close();
    canvas.drawPath(
      shield,
      Paint()..color = AppTheme.success.withValues(alpha: 0.2),
    );
    canvas.drawPath(
      shield,
      Paint()
        ..color = AppTheme.success
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(cx + 65, cy + 50),
      Offset(cx + 72, cy + 58),
      Paint()
        ..color = AppTheme.success
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(cx + 72, cy + 58),
      Offset(cx + 82, cy + 42),
      Paint()
        ..color = AppTheme.success
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  void _bubble(Canvas canvas, Offset center, String emoji, Color color) {
    canvas.drawCircle(
      center,
      38,
      Paint()..color = color.withValues(alpha: 0.18),
    );
    canvas.drawCircle(
      center,
      38,
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: emoji,
        style: const TextStyle(fontSize: 22),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _sparkle(Canvas canvas, Offset center, {double size = 12}) {
    final paint = Paint()
      ..color = _accent
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center - Offset(size, 0),
      center + Offset(size, 0),
      paint,
    );
    canvas.drawLine(
      center - Offset(0, size),
      center + Offset(0, size),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
