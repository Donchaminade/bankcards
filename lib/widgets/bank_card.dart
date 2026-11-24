import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import 'sparkles.dart';

const kCardW = 340.0;
const kCardH = 214.0;
const kCardRatio = kCardW / kCardH;

/// Carte bancaire paysage, dessinée entièrement en code.
class BankCardView extends StatelessWidget {
  const BankCardView({super.key, required this.card, this.shine = true, this.elevation = 1});
  final CardType card;
  final bool shine;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.fill,
      child: SizedBox(
        width: kCardW,
        height: kCardH,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: card.colors[1].withValues(alpha: .35 * elevation),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: .18 * elevation),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: card.colors),
                  ),
                ),
                CustomPaint(painter: _TexturePainter(card)),
                if (card.sparkle > 0)
                  SparkleField(
                    count: (card.sparkle * 16).round(),
                    seed: card.id.hashCode,
                    maxSize: 5.5,
                    intensity: card.finish == Finish.metal ? .9 : 1,
                    colors: card.finish == Finish.metal && card.id == 'platinum'
                        ? const [Colors.white, Color(0xFFE8EEF6)]
                        : const [BC.goldLight, Colors.white, BC.gold],
                  ),
                if (shine) const _ShineSweep(),
                _CardFace(card: card),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: card.finish == Finish.black
                          ? BC.gold.withValues(alpha: .75)
                          : Colors.white.withValues(alpha: .28),
                      width: card.finish == Finish.black ? 1.4 : 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({required this.card});
  final CardType card;

  @override
  Widget build(BuildContext context) {
    final ink = card.ink;
    final soft = ink.withValues(alpha: .72);
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const BrandMark(size: 18),
              const SizedBox(width: 7),
              Text(
                'BankCards',
                style: TextStyle(color: ink, fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: .2),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: soft.withValues(alpha: .45), width: .8),
                ),
                child: Text(
                  card.tier.toUpperCase(),
                  style: TextStyle(color: soft, fontSize: 8.5, fontWeight: FontWeight.w700, letterSpacing: 1.6),
                ),
              ),
              const Spacer(),
              CustomPaint(size: const Size(22, 22), painter: ContactlessPainter(ink.withValues(alpha: .85))),
            ],
          ),
          const SizedBox(height: 18),
          CustomPaint(
            size: const Size(44, 34),
            painter: ChipPainter(black: card.finish == Finish.black),
          ),
          const Spacer(),
          Text(
            card.masked,
            style: TextStyle(
              color: ink,
              fontFamily: kMono,
              fontSize: 16,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TITULAIRE',
                      style: TextStyle(color: soft, fontSize: 7, letterSpacing: 1.4, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      holderName,
                      style: TextStyle(color: ink, fontSize: 11.5, letterSpacing: 1.1, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'EXP',
                    style: TextStyle(color: soft, fontSize: 7, letterSpacing: 1.4, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    expiry,
                    style: TextStyle(color: ink, fontFamily: kMono, fontSize: 11.5, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(width: 18),
              NetworkLogo(card: card),
            ],
          ),
        ],
      ),
    );
  }
}

/// Petit monogramme BankCards (losange doré).
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 22});
  final double size;
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 4,
      child: Container(
        width: size * .72,
        height: size * .72,
        decoration: BoxDecoration(
          gradient: BC.goldGradient,
          borderRadius: BorderRadius.circular(size * .16),
          boxShadow: [BoxShadow(color: BC.gold.withValues(alpha: .5), blurRadius: size * .35)],
        ),
        child: Center(
          child: Container(
            width: size * .26,
            height: size * .26,
            decoration: BoxDecoration(color: BC.navy, borderRadius: BorderRadius.circular(size * .05)),
          ),
        ),
      ),
    );
  }
}

class NetworkLogo extends StatelessWidget {
  const NetworkLogo({super.key, required this.card, this.scale = 1});
  final CardType card;
  final double scale;
  @override
  Widget build(BuildContext context) {
    if (card.network == Network.mastercard) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CustomPaint(size: Size(46 * scale, 28 * scale), painter: _MastercardPainter()),
          const SizedBox(height: 2),
          Text(
            card.tier,
            style: TextStyle(color: card.ink.withValues(alpha: .8), fontSize: 8 * scale, fontWeight: FontWeight.w600),
          ),
        ],
      );
    }
    final color = card.finish == Finish.black ? null : card.ink;
    final text = Transform(
      transform: Matrix4.skewX(-.22),
      child: Text(
        'VISA',
        style: TextStyle(
          fontSize: 25 * scale,
          fontWeight: FontWeight.w800,
          height: 1,
          letterSpacing: .5,
          color: color ?? Colors.white,
        ),
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        color == null ? ShaderMask(shaderCallback: (r) => BC.goldGradient.createShader(r), child: text) : text,
        const SizedBox(height: 1),
        Text(
          card.tier,
          style: TextStyle(
            color: (color ?? BC.goldLight).withValues(alpha: .8),
            fontSize: 8 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MastercardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final r = s.height / 2;
    final a = Offset(r, r);
    final b = Offset(s.width - r, r);
    canvas.drawCircle(a, r, Paint()..color = const Color(0xFFEB001B));
    canvas.drawCircle(b, r, Paint()..color = const Color(0xFFF79E1B));
    final inter = Path.combine(
      PathOperation.intersect,
      Path()..addOval(Rect.fromCircle(center: a, radius: r)),
      Path()..addOval(Rect.fromCircle(center: b, radius: r)),
    );
    canvas.drawPath(inter, Paint()..color = const Color(0xFFFF5F00));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChipPainter extends CustomPainter {
  ChipPainter({this.black = false});
  final bool black;
  @override
  void paint(Canvas canvas, Size s) {
    final rr = RRect.fromRectAndRadius(Offset.zero & s, Radius.circular(s.height * .2));
    canvas.drawRRect(
      rr,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF7E08E), Color(0xFFD4AF37), Color(0xFFB58A22), Color(0xFFF1D27A)],
        ).createShader(Offset.zero & s),
    );
    final line = Paint()
      ..color = const Color(0xFF6E5313).withValues(alpha: .55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .9;
    final w = s.width, h = s.height;
    canvas.drawLine(Offset(0, h * .33), Offset(w * .32, h * .33), line);
    canvas.drawLine(Offset(0, h * .66), Offset(w * .32, h * .66), line);
    canvas.drawLine(Offset(w * .68, h * .33), Offset(w, h * .33), line);
    canvas.drawLine(Offset(w * .68, h * .66), Offset(w, h * .66), line);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(w * .32, h * .18, w * .68, h * .82), Radius.circular(h * .12)),
      line,
    );
    canvas.drawLine(Offset(w * .5, 0), Offset(w * .5, h * .18), line);
    canvas.drawLine(Offset(w * .5, h * .82), Offset(w * .5, h), line);
    canvas.drawRRect(rr, line..color = const Color(0xFF6E5313).withValues(alpha: .4));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ContactlessPainter extends CustomPainter {
  ContactlessPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = s.width * .09;
    final c = Offset(s.width * .1, s.height / 2);
    for (var i = 1; i <= 3; i++) {
      final r = s.width * .28 * i;
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi / 4, math.pi / 2, false, p);
    }
  }

  @override
  bool shouldRepaint(covariant ContactlessPainter old) => old.color != color;
}

class _TexturePainter extends CustomPainter {
  _TexturePainter(this.card);
  final CardType card;
  @override
  void paint(Canvas canvas, Size s) {
    final r = math.Random(card.id.length * 31);
    switch (card.finish) {
      case Finish.metal:
        // Métal brossé : fines lignes horizontales.
        for (double y = 0; y < s.height; y += 1.2) {
          final a = r.nextDouble() * .09;
          canvas.drawLine(
            Offset(0, y),
            Offset(s.width, y),
            Paint()
              ..color = (r.nextBool() ? Colors.white : Colors.black).withValues(alpha: a)
              ..strokeWidth = .6,
          );
        }
        canvas.drawRect(
          Offset.zero & s,
          Paint()
            ..shader = RadialGradient(
              center: const Alignment(-.6, -.8),
              radius: 1.2,
              colors: [Colors.white.withValues(alpha: .35), Colors.transparent],
            ).createShader(Offset.zero & s),
        );
      case Finish.gloss:
        // Vagues lumineuses.
        final p = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        for (var i = 0; i < 9; i++) {
          final path = Path()..moveTo(-20, s.height * (.25 + i * .09));
          path.cubicTo(
            s.width * .3,
            s.height * (.05 + i * .1),
            s.width * .6,
            s.height * (.9 + i * .02),
            s.width + 20,
            s.height * (.35 + i * .07),
          );
          canvas.drawPath(path, p..color = card.accent.withValues(alpha: .05 + i * .012));
        }
        canvas.drawCircle(
          Offset(s.width * .92, s.height * .05),
          s.width * .45,
          Paint()..color = Colors.white.withValues(alpha: .06),
        );
      case Finish.black:
        // Fibre de carbone + filet or.
        for (double x = -s.height; x < s.width; x += 6) {
          canvas.drawLine(
            Offset(x, s.height),
            Offset(x + s.height, 0),
            Paint()
              ..color = Colors.white.withValues(alpha: .025)
              ..strokeWidth = 2,
          );
        }
        final gold = Paint()
          ..shader = BC.goldGradient.createShader(Offset.zero & s)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
        final path = Path()
          ..moveTo(s.width * .55, 0)
          ..quadraticBezierTo(s.width * .7, s.height * .55, s.width, s.height * .42);
        canvas.drawPath(path, gold..color = BC.gold.withValues(alpha: .6));
        final path2 = Path()
          ..moveTo(s.width * .62, 0)
          ..quadraticBezierTo(s.width * .76, s.height * .5, s.width, s.height * .52);
        canvas.drawPath(path2, gold);
    }
  }

  @override
  bool shouldRepaint(covariant _TexturePainter old) => old.card.id != card.id;
}

/// Reflet doré/blanc qui balaie la carte en continu.
class _ShineSweep extends StatefulWidget {
  const _ShineSweep();
  @override
  State<_ShineSweep> createState() => _ShineSweepState();
}

class _ShineSweepState extends State<_ShineSweep> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 4200))
    ..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: CustomPaint(painter: _ShinePainter(_c)));
  }
}

class _ShinePainter extends CustomPainter {
  _ShinePainter(this.a) : super(repaint: a);
  final Animation<double> a;
  @override
  void paint(Canvas canvas, Size s) {
    final t = (a.value / .4).clamp(0.0, 1.0);
    if (t <= 0 || t >= 1) return;
    final x = lerpDouble(-s.width * .6, s.width * 1.3, Curves.easeInOutSine.transform(t))!;
    canvas.save();
    canvas.translate(x, 0);
    canvas.skew(-.5, 0);
    final rect = Rect.fromLTWH(0, -20, s.width * .32, s.height + 40);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0),
            const Color(0xFFFFF4CC).withValues(alpha: .38),
            Colors.white.withValues(alpha: .55),
            const Color(0xFFFFF4CC).withValues(alpha: .3),
            Colors.white.withValues(alpha: 0),
          ],
          stops: const [0, .35, .5, .65, 1],
        ).createShader(rect)
        ..blendMode = BlendMode.plus,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Pose d'une carte dans un écran (pour les vols Hero qui la font pivoter).
class CardPose {
  const CardPose({this.quarter = 0, this.rotX = 0, this.rotZ = 0});

  /// 0 = paysage, 1 = portrait (rotation de 90°).
  final double quarter;
  final double rotX;
  final double rotZ;

  static CardPose lerp(CardPose a, CardPose b, double t) => CardPose(
    quarter: lerpDouble(a.quarter, b.quarter, t)!,
    rotX: lerpDouble(a.rotX, b.rotX, t)!,
    rotZ: lerpDouble(a.rotZ, b.rotZ, t)!,
  );
}

/// Carte posée dans une boîte : en portrait elle est pivotée de 90°.
class PosedCard extends StatelessWidget {
  const PosedCard({super.key, required this.card, this.pose = const CardPose(), this.elevation = 1});
  final CardType card;
  final CardPose pose;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final bw = c.maxWidth, bh = c.maxHeight;
        final q = pose.quarter;
        final w = lerpDouble(bw, bh, q)!;
        final h = lerpDouble(bh, bw, q)!;
        final m = Matrix4.identity()
          ..setEntry(3, 2, .0012)
          ..rotateX(pose.rotX)
          ..rotateZ(q * math.pi / 2 + pose.rotZ);
        return OverflowBox(
          minWidth: w,
          maxWidth: w,
          minHeight: h,
          maxHeight: h,
          child: Transform(
            alignment: Alignment.center,
            transform: m,
            child: SizedBox(
              width: w,
              height: h,
              child: BankCardView(card: card, elevation: elevation),
            ),
          ),
        );
      },
    );
  }
}

/// Hero de carte : interpole la boîte et la pose (rotation, inclinaison 3D).
class CardHero extends StatelessWidget {
  const CardHero({super.key, required this.card, this.pose = const CardPose(), this.elevation = 1});
  final CardType card;
  final CardPose pose;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'card-${card.id}',
      flightShuttleBuilder: (ctx, animation, direction, fromCtx, toCtx) {
        final from = (fromCtx.widget as Hero).child as PosedCard;
        final to = (toCtx.widget as Hero).child as PosedCard;
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic);
        return AnimatedBuilder(
          animation: curved,
          builder: (_, _) {
            final t = curved.value;
            final pose = direction == HeroFlightDirection.push
                ? CardPose.lerp(from.pose, to.pose, t)
                : CardPose.lerp(to.pose, from.pose, t);
            // Petit « soulèvement » au milieu du vol.
            final lift = math.sin(t * math.pi);
            return Transform.scale(
              scale: 1 + .06 * lift,
              child: PosedCard(card: card, pose: pose, elevation: 1 + lift),
            );
          },
        );
      },
      child: PosedCard(card: card, pose: pose, elevation: elevation),
    );
  }
}
