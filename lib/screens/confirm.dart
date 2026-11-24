import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data.dart';
import '../demo.dart';
import '../theme.dart';
import '../widgets/bank_card.dart';
import '../widgets/ui.dart';
import 'placed.dart';

class ConfirmScreen extends StatefulWidget {
  const ConfirmScreen({super.key, required this.card});
  final CardType card;
  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> with TickerProviderStateMixin {
  bool _loading = false;
  Offset _tilt = Offset.zero;
  late final AnimationController _enter =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  late final AnimationController _back =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  Timer? _timer;
  Offset _tiltStart = Offset.zero;

  @override
  void initState() {
    super.initState();
    _back.addListener(() {
      final t = Curves.elasticOut.transform(_back.value);
      setState(() => _tilt = Offset.lerp(_tiltStart, Offset.zero, t)!);
    });
    Demo.after(this, 1900, _order);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _enter.dispose();
    _back.dispose();
    super.dispose();
  }

  void _order() {
    if (_loading) return;
    setState(() => _loading = true);
    _timer = Timer(Demo.d(2300), () {
      if (!mounted) return;
      Navigator.of(context).push(fadeRoute(PlacedScreen(card: widget.card), 'placed', ms: 800)).then((_) {
        if (mounted) setState(() => _loading = false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: BC.paper,
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, pad.top + 8, 20, pad.bottom + 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleIconButton(icon: Icons.chevron_left_rounded, onTap: () => Navigator.pop(context), tooltip: 'Retour'),
            const SizedBox(height: 14),
            Reveal(
              anim: _enter,
              start: 0,
              end: .6,
              child: const Text('Confirmer la commande',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -.5)),
            ),
            const SizedBox(height: 4),
            Reveal(
              anim: _enter,
              start: .1,
              end: .7,
              child: const Text('Vérifiez votre nouvelle carte avant de payer.',
                  style: TextStyle(color: BC.muted, fontSize: 14)),
            ),
            const SizedBox(height: 18),
            // Carte inclinable au doigt (effet 3D), revient en place avec un ressort.
            GestureDetector(
              onPanUpdate: (d) => setState(() {
                _tilt = Offset(
                  (_tilt.dx + d.delta.dx / 300).clamp(-.35, .35),
                  (_tilt.dy + d.delta.dy / 300).clamp(-.35, .35),
                );
              }),
              onPanEnd: (_) {
                _tiltStart = _tilt;
                _back.forward(from: 0);
              },
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, .0015)
                  ..rotateX(-_tilt.dy)
                  ..rotateY(_tilt.dx),
                child: AspectRatio(aspectRatio: kCardRatio, child: CardHero(card: card)),
              ),
            ),
            const SizedBox(height: 18),
            Reveal(
              anim: _enter,
              start: .35,
              end: 1,
              child: Panel(
                child: Column(
                  children: [
                    InfoRow('Carte', '${card.networkLabel} ${card.name} · ${card.material}'),
                    InfoRow('Cotisation annuelle', fcfa(card.price)),
                    const InfoRow('Livraison', 'Offerte · 5–7 jours'),
                    const InfoRow('Adresse', 'Adidogomé · Lomé, Togo'),
                    InfoRow('Total aujourd\'hui', fcfa(card.price), bold: true, last: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Reveal(
              anim: _enter,
              start: .5,
              end: 1,
              child: Row(
                children: [
                  for (final (i, p) in [Icons.workspace_premium_outlined, Icons.contactless_outlined].indexed) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: BC.navy,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: BC.gold.withValues(alpha: .45)),
                        ),
                        child: Row(
                          children: [
                            Icon(p, color: BC.goldLight, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(card.perks[i],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Spacer(),
            Center(child: _OrderButton(loading: _loading, label: 'Commander · ${fcfa(card.price)}', onTap: _order)),
            const SizedBox(height: 12),
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Row(
                  key: ValueKey(_loading),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_loading ? Icons.verified_user_outlined : Icons.lock_outline_rounded, size: 14, color: BC.muted),
                    const SizedBox(width: 6),
                    Text(
                      _loading ? 'Confirmation de votre paiement…' : 'Paiement sécurisé · Annulable à tout moment',
                      style: const TextStyle(color: BC.muted, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderButton extends StatelessWidget {
  const _OrderButton({required this.loading, required this.label, required this.onTap});
  final bool loading;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeInOutCubic,
          width: loading ? 104 : c.maxWidth,
          height: 56,
          decoration: BoxDecoration(
            color: BC.ink,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: BC.gold.withValues(alpha: .6)),
            boxShadow: [BoxShadow(color: BC.navy.withValues(alpha: .25), blurRadius: 18, offset: const Offset(0, 8))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: loading
                  ? const LoadingDots(key: ValueKey('dots'))
                  : Center(
                      key: const ValueKey('label'),
                      child: Text(label,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15.5)),
                    ),
            ),
          ),
        ),
      );
    });
  }
}

class LoadingDots extends StatefulWidget {
  const LoadingDots({super.key});
  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < 3; i++)
            Builder(builder: (_) {
              final v = (math.sin((_c.value - i * .18) * math.pi * 2) + 1) / 2;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3.5),
                width: 9 + 5 * v,
                height: 9 + 5 * v,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.lerp(Colors.white, BC.goldLight, v),
                ),
              );
            }),
        ],
      ),
    );
  }
}
