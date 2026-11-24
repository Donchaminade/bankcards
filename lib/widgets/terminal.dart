import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Matrice isométrique partagée par le terminal et la carte posée dessus.
const kIsoRotX = .82;
const kIsoRotZ = -.62;

Matrix4 isoMatrix() => Matrix4.identity()
  ..setEntry(3, 2, .0011)
  ..rotateX(kIsoRotX)
  ..rotateZ(kIsoRotZ);

const kTerminalSize = Size(200, 300);

/// Centre de l'écran du terminal dans le repère plat du terminal.
const kTerminalScreenCenter = Offset(100, 118);

/// Projette un point du terminal plat dans l'espace de son parent.
Offset projectTerminalPoint(Offset p, Offset topLeft) {
  final c = kTerminalSize.center(Offset.zero);
  final v = MatrixUtils.transformPoint(isoMatrix(), p - c);
  return topLeft + c + v;
}

/// Terminal de paiement isométrique, dessiné en code.
class PaymentTerminal extends StatelessWidget {
  const PaymentTerminal({super.key, required this.check, required this.receipt, this.glow = 0});
  final double check;
  final double receipt;
  final double glow;

  @override
  Widget build(BuildContext context) {
    final m = isoMatrix();
    Widget layer(CustomPainter p) => Transform(
          alignment: Alignment.center,
          transform: m,
          child: CustomPaint(size: kTerminalSize, painter: p),
        );
    return SizedBox.fromSize(
      size: kTerminalSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Ombre portée au sol.
          Transform.translate(
            offset: const Offset(10, 34),
            child: layer(_ShadowPainter()),
          ),
          // Épaisseur du boîtier (couches décalées).
          for (var k = 26; k >= 1; k -= 1)
            Transform.translate(
              offset: Offset(0, k.toDouble()),
              child: layer(_SilhouettePainter(
                Color.lerp(const Color(0xFFF2F3F7), const Color(0xFFC9CDD8), k / 26)!,
                k < 10 ? 1 : 0,
              )),
            ),
          layer(_FacePainter(check, receipt, glow)),
        ],
      ),
    );
  }
}

RRect _bodyRect() => RRect.fromRectAndRadius(const Rect.fromLTWH(0, 30, 200, 270), const Radius.circular(30));

class _ShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      _bodyRect(),
      Paint()
        ..color = BC.navy.withValues(alpha: .22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SilhouettePainter extends CustomPainter {
  _SilhouettePainter(this.color, this.dark);
  final Color color;
  final int dark;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(_bodyRect(), Paint()..color = dark == 1 ? const Color(0xFF1A1D26) : color);
  }

  @override
  bool shouldRepaint(covariant _SilhouettePainter old) => old.color != color;
}

class _FacePainter extends CustomPainter {
  _FacePainter(this.check, this.receipt, this.glow);
  final double check, receipt, glow;

  @override
  void paint(Canvas canvas, Size size) {
    // Ticket qui sort de l'imprimante (derrière le boîtier).
    if (receipt > 0) {
      final h = 150 * Curves.easeOut.transform(receipt);
      final r = Rect.fromLTWH(38, 36 - h, 124, h);
      canvas.drawRect(r, Paint()..color = Colors.white);
      canvas.drawRect(r, Paint()
        ..color = const Color(0xFFD9DCE5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1);
      final line = Paint()
        ..color = const Color(0xFFB9BECB)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 6; i++) {
        final y = 36 - h + 18 + i * 20.0;
        if (y > 26) break;
        canvas.drawLine(Offset(52, y), Offset(i.isEven ? 140 : 112, y), line);
      }
    }
    // Boîtier.
    final body = _bodyRect();
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF232733), Color(0xFF0B0D12)],
        ).createShader(body.outerRect),
    );
    // Liseré or.
    canvas.drawRRect(
      body.deflate(3),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..shader = BC.goldGradient.createShader(body.outerRect),
    );
    // Fente d'impression.
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(30, 40, 140, 10), const Radius.circular(5)),
        Paint()..color = const Color(0xFF000000));
    // Écran.
    final screen = RRect.fromRectAndRadius(const Rect.fromLTWH(22, 64, 156, 108), const Radius.circular(12));
    canvas.drawRRect(screen, Paint()..color = const Color(0xFFF7F8FC));
    canvas.drawRRect(
        screen,
        Paint()
          ..color = BC.green.withValues(alpha: .18 * glow)
          ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 18));
    // Mini logo en haut de l'écran.
    final tp = TextPainter(
      text: const TextSpan(
          text: 'BankCards Pay', style: TextStyle(fontFamily: 'Manrope', fontSize: 9, fontWeight: FontWeight.w800, color: BC.navy)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, const Offset(32, 72));
    // Coche verte animée.
    if (check > 0) {
      final path = Path()
        ..moveTo(58, 122)
        ..lineTo(88, 148)
        ..lineTo(146, 94);
      final metric = path.computeMetrics().first;
      final sub = metric.extractPath(0, metric.length * Curves.easeOutCubic.transform(check));
      canvas.drawPath(
          sub,
          Paint()
            ..color = BC.green
            ..style = PaintingStyle.stroke
            ..strokeWidth = 13
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round);
    }
    // Clavier.
    const cols = 3, rows = 4;
    const kw = 40.0, kh = 18.0, gx = 14.0, gy = 9.0;
    const left = (200 - (cols * kw + (cols - 1) * gx)) / 2;
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final rect = Rect.fromLTWH(left + c * (kw + gx), 188 + r * (kh + gy), kw, kh);
        Color col = const Color(0xFFDADDE6);
        if (r == rows - 1 && c == cols - 1) col = BC.green;
        if (r == rows - 1 && c == 0) col = const Color(0xFFE5484D);
        if (r == rows - 1 && c == 1) col = BC.gold;
        canvas.drawRRect(RRect.fromRectAndRadius(rect.shift(const Offset(0, 3)), const Radius.circular(7)),
            Paint()..color = Colors.black.withValues(alpha: .6));
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(7)), Paint()..color = col);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FacePainter old) =>
      old.check != check || old.receipt != receipt || old.glow != glow;
}

/// Code-barres déterministe.
class BarcodePainter extends CustomPainter {
  BarcodePainter(this.data, {this.color = const Color(0xFF111111)});
  final String data;
  final Color color;
  @override
  void paint(Canvas canvas, Size s) {
    final r = math.Random(data.hashCode);
    final widths = <double>[];
    var total = 0.0;
    while (total < s.width) {
      final w = (1 + r.nextInt(4)).toDouble();
      widths.add(w);
      total += w;
    }
    final k = s.width / total;
    var x = 0.0;
    final p = Paint()..color = color;
    for (var i = 0; i < widths.length; i++) {
      final w = widths[i] * k;
      if (i.isEven) canvas.drawRect(Rect.fromLTWH(x, 0, w, s.height), p);
      x += w;
    }
  }

  @override
  bool shouldRepaint(covariant BarcodePainter old) => old.data != data;
}
