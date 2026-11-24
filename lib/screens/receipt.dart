import 'package:flutter/material.dart';

import '../data.dart';
import '../demo.dart';
import '../theme.dart';
import '../widgets/sparkles.dart';
import '../widgets/terminal.dart';
import '../widgets/ui.dart';

const _receiptNo = 'BC-261124-0048';

class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({super.key, required this.card});
  final CardType card;
  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> with TickerProviderStateMixin {
  late final AnimationController _print = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  );
  late final AnimationController _stamp = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
  late final AnimationController _led = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
    ..repeat(reverse: true);
  bool _done = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Demo.d(800), () async {
      if (!mounted) return;
      await _print.forward();
      if (!mounted) return;
      _led.stop();
      await Future.delayed(Demo.d(200));
      if (!mounted) return;
      await _stamp.forward();
      if (mounted) setState(() => _done = true);
    });
    Demo.after(this, 7400, _finish);
  }

  @override
  void dispose() {
    _print.dispose();
    _stamp.dispose();
    _led.dispose();
    super.dispose();
  }

  void _finish() {
    Navigator.of(context).popUntil((r) => r.isFirst);
    if (Demo.enabled && Demo.loop) Demo.restartHome?.call();
  }

  /// Impression « ligne par ligne » : progression en paliers adoucis.
  double get _printed {
    const steps = 22;
    final v = _print.value * steps;
    final f = v.floor();
    return ((f + Curves.easeOut.transform(v - f)) / steps).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: BC.ink,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(center: Alignment(0, -.5), radius: 1.1, colors: [Color(0xFF13285A), BC.ink]),
              ),
            ),
          ),
          const Positioned.fill(child: SparkleField(count: 30, seed: 21, maxSize: 6, intensity: .9)),
          Padding(
            padding: EdgeInsets.fromLTRB(20, pad.top + 8, 20, safeBottom(context)),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleIconButton(
                      icon: Icons.chevron_left_rounded,
                      dark: true,
                      onTap: () => Navigator.pop(context),
                      tooltip: 'Retour',
                    ),
                    const Expanded(
                      child: Text(
                        'Reçu',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 42),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: 330,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([_print, _stamp, _led]),
                          builder: (_, _) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _Printer(led: _print.isAnimating ? _led.value : 1),
                              Transform.translate(
                                offset: const Offset(0, -14),
                                child: ClipRect(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    heightFactor: _printed,
                                    child: _Paper(card: widget.card, stamp: _stamp.value),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 56,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    transitionBuilder: (c, a) => FadeTransition(
                      opacity: a,
                      child: SlideTransition(
                        position: Tween(begin: const Offset(0, .4), end: Offset.zero).animate(a),
                        child: c,
                      ),
                    ),
                    child: _done
                        ? Row(
                            key: const ValueKey('actions'),
                            children: [
                              Expanded(
                                child: _DarkButton(
                                  label: 'Partager',
                                  icon: Icons.ios_share_rounded,
                                  onTap: () => ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(const SnackBar(content: Text('Reçu prêt à être partagé (démo).'))),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: PrimaryButton(label: 'Terminé', light: true, onTap: _finish),
                              ),
                            ],
                          )
                        : Center(
                            key: const ValueKey('printing'),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.print_outlined, size: 16, color: Colors.white.withValues(alpha: .6)),
                                const SizedBox(width: 8),
                                Text(
                                  'Impression de votre reçu…',
                                  style: TextStyle(color: Colors.white.withValues(alpha: .6), fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkButton extends StatelessWidget {
  const _DarkButton({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Material(
        color: Colors.white.withValues(alpha: .06),
        shape: StadiumBorder(side: BorderSide(color: BC.gold.withValues(alpha: .5))),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: BC.goldLight),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Printer extends StatelessWidget {
  const _Printer({required this.led});
  final double led;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF4F6FA), Color(0xFFC3C9D4), Color(0xFF8E96A6)],
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .5), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 16,
            top: 9,
            child: ShaderMask(
              shaderCallback: (r) => BC.goldGradient.createShader(r),
              child: const Text(
                'BANKCARDS',
                style: TextStyle(color: Colors.white, fontSize: 8.5, letterSpacing: 2.5, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 10,
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.lerp(const Color(0xFF14532D), const Color(0xFF22C55E), led),
                boxShadow: [BoxShadow(color: const Color(0xFF22C55E).withValues(alpha: .8 * led), blurRadius: 6)],
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              height: 8,
              decoration: BoxDecoration(color: const Color(0xFF0B0D12), borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Paper extends StatelessWidget {
  const _Paper({required this.card, required this.stamp});
  final CardType card;
  final double stamp;

  @override
  Widget build(BuildContext context) {
    const mono = TextStyle(fontFamily: kMono, fontSize: 10.5, color: Color(0xFF1A1A1A), height: 1.5);
    final small = mono.copyWith(fontSize: 9, color: const Color(0xFF6B6B6B));
    Widget kv(String k, String v, {TextStyle? s}) => Row(
      children: [
        Text(k, style: s ?? small),
        const Spacer(),
        Text(v, style: s ?? mono),
      ],
    );
    final st = Curves.easeOutBack.transform(stamp.clamp(0, 1));
    return ClipPath(
      clipper: _ZigZag(),
      child: Container(
        width: 290,
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 30),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE9E6DE), Color(0xFFFBFAF6), Color(0xFFF7F5EF)],
            stops: [0, .08, 1],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'BANKCARDS',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, letterSpacing: 6, fontWeight: FontWeight.w600, color: BC.ink),
                ),
                const SizedBox(height: 2),
                Text('REÇU DE COMMANDE CARTE', textAlign: TextAlign.center, style: small.copyWith(letterSpacing: 2)),
                const SizedBox(height: 12),
                const _Dashed(),
                const SizedBox(height: 8),
                kv('REÇU', _receiptNo),
                kv('DATE', '24 NOV 2026 · 11:48'),
                kv('TITULAIRE', holderName),
                const SizedBox(height: 8),
                const _Dashed(),
                const SizedBox(height: 8),
                kv(
                  '${card.networkLabel} ${card.name}'.toUpperCase(),
                  fcfa(card.price),
                  s: mono.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(card.material, style: small),
                kv('ÉMISSION CARTE', 'OFFERT', s: mono),
                kv('LIVRAISON · 5–7 J', 'OFFERT', s: mono),
                const SizedBox(height: 8),
                Container(height: 1.4, color: const Color(0xFF1A1A1A)),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('TOTAL', style: mono.copyWith(fontSize: 14, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text(fcfa(card.price), style: mono.copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
                  ],
                ),
                Row(
                  children: [
                    Text('PAYÉ PAR ${card.networkLabel.toUpperCase()} ·· ${card.last4}', style: small),
                    const Spacer(),
                    Text('APPROUVÉ', style: small),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(height: 46, child: CustomPaint(painter: BarcodePainter(_receiptNo))),
                const SizedBox(height: 4),
                Text(_receiptNo, textAlign: TextAlign.center, style: small.copyWith(letterSpacing: 2)),
                const SizedBox(height: 10),
                const Text(
                  'Merci d\'avoir choisi BankCards.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: kSerif, fontStyle: FontStyle.italic, fontSize: 16, color: BC.ink),
                ),
              ],
            ),
            // Tampon « PAYÉ » qui s'abat sur le total.
            if (stamp > 0)
              Positioned(
                right: 4,
                top: 112,
                child: Opacity(
                  opacity: (stamp * 2.5).clamp(0, 1) * .88,
                  child: Transform.rotate(
                    angle: -.32 + .1 * (1 - st),
                    child: Transform.scale(scale: 2.6 - 1.6 * st, child: const _Stamp()),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Stamp extends StatelessWidget {
  const _Stamp();
  @override
  Widget build(BuildContext context) {
    const c = Color(0xFF15803D);
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: c, width: 3),
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: c, width: 1.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('★ ★ ★', style: TextStyle(color: c, fontSize: 7, letterSpacing: 1)),
            Text(
              'PAYÉ',
              style: TextStyle(
                color: c,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                fontFamily: kMono,
                height: 1.1,
              ),
            ),
            const Text(
              '24.11.26',
              style: TextStyle(color: c, fontSize: 7.5, fontFamily: kMono, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dashed extends StatelessWidget {
  const _Dashed();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final n = (c.maxWidth / 6).floor();
        return Row(
          children: List.generate(
            n,
            (_) => Expanded(
              child: Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 1.2),
                color: const Color(0xFFB5B2A8),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ZigZag extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    const t = 7.0;
    final p = Path()
      ..lineTo(s.width, 0)
      ..lineTo(s.width, s.height - t);
    var x = s.width;
    var up = false;
    while (x > 0) {
      x -= t;
      p.lineTo(x.clamp(0, s.width), up ? s.height - t : s.height);
      up = !up;
    }
    p
      ..lineTo(0, s.height - t)
      ..close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
