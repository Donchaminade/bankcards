import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Champ de paillettes dorées (étoiles à 4 branches qui scintillent).
class SparkleField extends StatefulWidget {
  const SparkleField({
    super.key,
    this.count = 22,
    this.seed = 7,
    this.colors = const [BC.goldLight, BC.gold, Colors.white],
    this.maxSize = 7,
    this.intensity = 1,
    this.speed = 1,
  });

  final int count;
  final int seed;
  final List<Color> colors;
  final double maxSize;
  final double intensity;
  final double speed;

  @override
  State<SparkleField> createState() => _SparkleFieldState();
}

class _SparkleFieldState extends State<SparkleField> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  late List<_Sparkle> _items = _make();

  List<_Sparkle> _make() {
    final r = math.Random(widget.seed);
    return List.generate(widget.count, (i) {
      return _Sparkle(
        x: r.nextDouble(),
        y: r.nextDouble(),
        size: widget.maxSize * (.35 + r.nextDouble() * .65),
        phase: r.nextDouble(),
        rate: (1 + r.nextInt(3)).toDouble(),
        color: widget.colors[r.nextInt(widget.colors.length)],
        drift: (r.nextDouble() - .5) * .04,
      );
    });
  }

  @override
  void didUpdateWidget(covariant SparkleField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count || oldWidget.seed != widget.seed) _items = _make();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _SparklePainter(_c, _items, widget.intensity, widget.speed),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Sparkle {
  _Sparkle({
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
    required this.rate,
    required this.color,
    required this.drift,
  });
  final double x, y, size, phase, rate, drift;
  final Color color;
}

class _SparklePainter extends CustomPainter {
  _SparklePainter(this.anim, this.items, this.intensity, this.speed) : super(repaint: anim);
  final Animation<double> anim;
  final List<_Sparkle> items;
  final double intensity;
  final double speed;

  @override
  void paint(Canvas canvas, Size size) {
    final t = anim.value * speed;
    for (final s in items) {
      final v = math.sin((t * s.rate + s.phase) * math.pi * 2);
      final a = (v.clamp(0.0, 1.0)) * intensity;
      if (a < .02) continue;
      final dx = (s.x + s.drift * math.sin(t * math.pi * 2)) * size.width;
      final dy = s.y * size.height;
      drawStar(canvas, Offset(dx, dy), s.size * (.5 + .5 * a), s.color.withValues(alpha: a.clamp(0, 1)));
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter old) => old.items != items || old.intensity != intensity;
}

void drawStar(Canvas canvas, Offset c, double r, Color color) {
  final p = Path()
    ..moveTo(c.dx, c.dy - r)
    ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
    ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
    ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
    ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
    ..close();
  canvas.drawCircle(c, r * .9, Paint()
    ..color = color.withValues(alpha: color.a * .25)
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * .6));
  canvas.drawPath(p, Paint()..color = color);
}

/// Explosion de paillettes (succès).
class SparkleBurst extends StatelessWidget {
  const SparkleBurst({super.key, required this.progress, this.count = 26, this.radius = 150});
  final Animation<double> progress;
  final int count;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: _BurstPainter(progress, count, radius), size: Size.infinite),
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter(this.p, this.count, this.radius) : super(repaint: p);
  final Animation<double> p;
  final int count;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final t = p.value;
    if (t <= 0 || t >= 1) return;
    final r = math.Random(3);
    final c = size.center(Offset.zero);
    for (var i = 0; i < count; i++) {
      final ang = (i / count) * math.pi * 2 + r.nextDouble() * .4;
      final dist = radius * (.45 + r.nextDouble() * .55) * Curves.easeOutCubic.transform(t);
      final o = c + Offset(math.cos(ang), math.sin(ang)) * dist;
      final fade = (1 - t);
      final col = i.isEven ? BC.gold : (i % 3 == 0 ? Colors.white : BC.goldLight);
      drawStar(canvas, o, (3 + r.nextDouble() * 6) * (0.4 + fade), col.withValues(alpha: fade));
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter oldDelegate) => false;
}
