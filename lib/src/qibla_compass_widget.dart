import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qibla_compass/qibla_compass.dart';

/// A standalone compass dial that can be embedded anywhere.
///
/// [qiblaBearing] – pre-calculated bearing from [QiblaCalculator].
/// [deviceHeading] – live reading from `FlutterCompass.events`.
/// [size] – diameter of the compass widget (default 280).
/// [theme] – visual theme (defaults to [QiblaTheme.defaultTheme]).
class QiblaCompassWidget extends StatefulWidget {
  const QiblaCompassWidget({
    super.key,
    required this.qiblaBearing,
    required this.deviceHeading,
    this.size = 280,
    this.theme = QiblaTheme.defaultTheme,
    this.alignmentThresholdDegrees = 5.0,
  });

  final double qiblaBearing;
  final double deviceHeading;
  final double size;
  final QiblaTheme theme;
  final double alignmentThresholdDegrees;

  @override
  State<QiblaCompassWidget> createState() => _QiblaCompassWidgetState();
}

class _QiblaCompassWidgetState extends State<QiblaCompassWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _needleController;
  late Animation<double> _needleAnimation;
  double _lastRotation = 0;

  @override
  void initState() {
    super.initState();
    _needleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _lastRotation = _computeRotation();
    _needleAnimation = AlwaysStoppedAnimation<double>(_lastRotation);
  }

  @override
  void didUpdateWidget(QiblaCompassWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deviceHeading != widget.deviceHeading ||
        oldWidget.qiblaBearing != widget.qiblaBearing) {
      final next = _computeRotation();
      // Unwrap to avoid spinning the wrong way around 0/360 boundary.
      final diff = _shortestAngle(_lastRotation, next);
      final from = _lastRotation;
      final to = from + diff;
      _lastRotation = to;
      _needleAnimation = Tween<double>(begin: from, end: to).animate(
        CurvedAnimation(parent: _needleController, curve: Curves.easeOut),
      );
      _needleController
        ..reset()
        ..forward();
    }
  }

  double _computeRotation() =>
      (widget.qiblaBearing - widget.deviceHeading) * pi / 180;

  static double _shortestAngle(double from, double to) {
    double diff = (to - from) % (2 * pi);
    if (diff > pi) diff -= 2 * pi;
    if (diff < -pi) diff += 2 * pi;
    return diff;
  }

  @override
  void dispose() {
    _needleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAligned = QiblaCalculator.isAligned(
      widget.qiblaBearing,
      widget.deviceHeading,
      thresholdDegrees: widget.alignmentThresholdDegrees,
    );

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Compass face ──
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.theme.compassFaceStart,
                  widget.theme.compassFaceEnd,
                ],
                stops: const [0.3, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.theme.gold.withValues(alpha: isAligned ? 0.5 : 0.2),
                  blurRadius: isAligned ? 40 : 20,
                  spreadRadius: isAligned ? 8 : 2,
                ),
              ],
            ),
          ),

          // ── Tick marks + cardinal letters ──
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _CompassRingPainter(
              heading: widget.deviceHeading,
              theme: widget.theme,
            ),
          ),

          // ── Animated Qibla needle ──
          AnimatedBuilder(
            animation: _needleAnimation,
            builder: (_, __) => Transform.rotate(
              angle: _needleAnimation.value,
              child: _QiblaNeedle(
                size: widget.size,
                isAligned: isAligned,
                theme: widget.theme,
              ),
            ),
          ),

          // ── Centre dot ──
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAligned ? widget.theme.gold : Colors.white38,
              boxShadow: [
                BoxShadow(
                  color: widget.theme.gold.withValues(alpha: 0.6),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Qibla needle (Kaaba icon + arrow)
// ─────────────────────────────────────────────────────────────────────────────

class _QiblaNeedle extends StatelessWidget {
  const _QiblaNeedle({
    required this.size,
    required this.isAligned,
    required this.theme,
  });

  final double size;
  final bool isAligned;
  final QiblaTheme theme;

  @override
  Widget build(BuildContext context) {
    final color = isAligned ? theme.gold : Colors.white70;
    final needleLength = size * 0.38;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Kaaba SVG-style icon ──
        _KaabaIcon(size: 36, color: color),
        const SizedBox(height: 6),
        // ── Label ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isAligned
                ? theme.gold.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color:
                  isAligned ? theme.gold.withValues(alpha: 0.5) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Text(
            'الكعبة',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'Amiri',
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // ── Stem ──
        Container(
          width: 2,
          height: needleLength * 0.6,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, color.withValues(alpha: 0)],
            ),
          ),
        ),
        // ── Arrowhead ──
        CustomPaint(
          size: Size(24, 20),
          painter: _ArrowheadPainter(color: color),
        ),
      ],
    );
  }
}

class _ArrowheadPainter extends CustomPainter {
  _ArrowheadPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width / 2, size.height * 0.4)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ArrowheadPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Kaaba icon (drawn with Canvas so no asset needed)
// ─────────────────────────────────────────────────────────────────────────────

class _KaabaIcon extends StatelessWidget {
  const _KaabaIcon({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _KaabaPainter(color: color),
    );
  }
}

class _KaabaPainter extends CustomPainter {
  _KaabaPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final w = size.width;
    final h = size.height;

    // Main body (cube front face)
    canvas.drawRect(
        Rect.fromLTWH(w * 0.15, h * 0.3, w * 0.7, h * 0.6),
        paint
          ..style = PaintingStyle.fill
          ..color = color.withValues(alpha: 0.15));
    canvas.drawRect(
        Rect.fromLTWH(w * 0.15, h * 0.3, w * 0.7, h * 0.6),
        paint
          ..style = PaintingStyle.stroke
          ..color = color);

    // Top face (isometric)
    final topPath = Path()
      ..moveTo(w * 0.15, h * 0.3)
      ..lineTo(w * 0.35, h * 0.1)
      ..lineTo(w * 0.85, h * 0.1)
      ..lineTo(w * 0.85, h * 0.3)
      ..close();
    canvas.drawPath(
        topPath,
        paint
          ..style = PaintingStyle.fill
          ..color = color.withValues(alpha: 0.1));
    canvas.drawPath(
        topPath,
        paint
          ..style = PaintingStyle.stroke
          ..color = color);

    // Door
    canvas.drawRect(
        Rect.fromLTWH(w * 0.38, h * 0.55, w * 0.24, h * 0.35),
        paint
          ..style = PaintingStyle.fill
          ..color = color.withValues(alpha: 0.3));
    canvas.drawRect(
        Rect.fromLTWH(w * 0.38, h * 0.55, w * 0.24, h * 0.35),
        paint
          ..style = PaintingStyle.stroke
          ..color = color
          ..strokeWidth = 1.5);

    // Kiswa band (horizontal stripe)
    canvas.drawLine(
      Offset(w * 0.15, h * 0.47),
      Offset(w * 0.85, h * 0.47),
      paint
        ..strokeWidth = 1.5
        ..color = color.withValues(alpha: 0.6),
    );
  }

  @override
  bool shouldRepaint(_KaabaPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Compass ring: tick marks + cardinal letters
// ─────────────────────────────────────────────────────────────────────────────

class _CompassRingPainter extends CustomPainter {
  _CompassRingPainter({required this.heading, required this.theme});

  final double heading;
  final QiblaTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2 - 4;

    final majorPaint = Paint()
      ..color = Colors.white38
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final minorPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Outer ring
    canvas.drawCircle(center, outerR, minorPaint);

    // Tick marks every 5°
    for (int i = 0; i < 72; i++) {
      final deg = i * 5.0;
      final rad = (deg - heading) * pi / 180;
      final isMajor = deg % 45 == 0;
      final isQuarter = deg % 90 == 0;
      final tickLen = isQuarter ? 16.0 : (isMajor ? 10.0 : 5.0);
      final paint = isMajor ? majorPaint : minorPaint;

      final x1 = center.dx + outerR * sin(rad);
      final y1 = center.dy - outerR * cos(rad);
      final x2 = center.dx + (outerR - tickLen) * sin(rad);
      final y2 = center.dy - (outerR - tickLen) * cos(rad);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    // Cardinal letters
    final cardinals = ['N', 'E', 'S', 'W'];
    final cardAngles = [0.0, 90.0, 180.0, 270.0];
    final labelR = outerR - 26;

    for (int i = 0; i < 4; i++) {
      final rad = (cardAngles[i] - heading) * pi / 180;
      final x = center.dx + labelR * sin(rad);
      final y = center.dy - labelR * cos(rad);

      final isNorth = i == 0;
      final tp = TextPainter(
        text: TextSpan(
          text: cardinals[i],
          style: TextStyle(
            color: isNorth ? theme.northIndicator : Colors.white70,
            fontSize: isNorth ? 18 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_CompassRingPainter old) => old.heading != heading;
}
