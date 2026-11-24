import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data.dart';
import '../demo.dart';
import '../theme.dart';
import '../widgets/bank_card.dart';
import '../widgets/sparkles.dart';
import '../widgets/terminal.dart';
import '../widgets/ui.dart';
import 'receipt.dart';

class PlacedScreen extends StatefulWidget {
  const PlacedScreen({super.key, required this.card});
  final CardType card;
  @override
  State<PlacedScreen> createState() => _PlacedScreenState();
}

class _PlacedScreenState extends State<PlacedScreen> with TickerProviderStateMixin {
  late final AnimationController _tl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600));
  late final AnimationController _bob = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
    ..repeat();

  @override
  void initState() {
    super.initState();
    Future.delayed(Demo.d(750), () {
      if (mounted) _tl.forward();
    });
    Demo.after(this, 5200, _receipt);
  }

  @override
  void dispose() {
    _tl.dispose();
    _bob.dispose();
    super.dispose();
  }

  void _receipt() => Navigator.of(context).push(fadeRoute(ReceiptScreen(card: widget.card), 'receipt', ms: 700));

  double _iv(double a, double b, [Curve c = Curves.easeInOut]) =>
      c.transform(((_tl.value - a) / (b - a)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: BC.paper,
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                // L'illustration s'adapte à la hauteur disponible ; en dessous d'un minimum, la page défile.
                final illusH = (c.maxHeight - pad.top - 16 - 262).clamp(200.0, 420.0);
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, pad.top + 4, 20, 12),
                  child: Column(
                    children: [
                      SizedBox(
                        height: illusH,
                        child: FittedBox(
                          child: SizedBox(
                            width: 360,
                            height: 380,
                            child: AnimatedBuilder(
                              animation: Listenable.merge([_tl, _bob]),
                              builder: (_, _) {
                                const termTopLeft = Offset(92, 70);
                                final dip = _iv(.18, .3) - _iv(.3, .44);
                                final bob = math.sin(_bob.value * math.pi * 2) * 4 * _iv(.44, .6);
                                final lift = 78 - 46 * dip + bob;
                                final center =
                                    projectTerminalPoint(kTerminalScreenCenter, termTopLeft) - Offset(0, lift);
                                const box = Size(150, 94);
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      left: termTopLeft.dx,
                                      top: termTopLeft.dy,
                                      child: PaymentTerminal(
                                        check: _iv(.3, .5),
                                        receipt: _iv(.34, .78),
                                        glow: _iv(.3, .45) * (1 - _iv(.6, .9)),
                                      ),
                                    ),
                                    Positioned(
                                      left: center.dx - box.width / 2,
                                      top: center.dy - box.height / 2,
                                      width: box.width,
                                      height: box.height,
                                      child: CardHero(
                                        card: card,
                                        pose: const CardPose(rotX: kIsoRotX, rotZ: kIsoRotZ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: SparkleBurst(
                                        progress: CurvedAnimation(parent: _tl, curve: const Interval(.3, .62)),
                                        radius: 170,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Reveal(
                        anim: _tl,
                        start: .42,
                        end: .62,
                        child: const Text(
                          'Commande validée',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -.5),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Reveal(
                        anim: _tl,
                        start: .48,
                        end: .68,
                        child: Text(
                          'Votre carte ${card.networkLabel} ${card.name} est en route.\nNous vous prévenons dès son expédition.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: BC.muted, fontSize: 14, height: 1.45),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Reveal(
                        anim: _tl,
                        start: .55,
                        end: .78,
                        child: Panel(
                          child: Column(
                            children: [
                              InfoRow('Payé', fcfa(card.price)),
                              InfoRow('Carte', '${card.networkLabel} ${card.name} ·· ${card.last4}'),
                              const InfoRow('Arrivée', '5–7 jours ouvrés', last: true),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Boutons fixés en bas, au-dessus de la zone de sécurité.
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, safeBottom(context)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Reveal(
                  anim: _tl,
                  start: .68,
                  end: .9,
                  child: PrimaryButton(
                    label: 'Voir le reçu',
                    light: true,
                    icon: Icons.receipt_long_outlined,
                    onTap: _receipt,
                  ),
                ),
                const SizedBox(height: 10),
                Reveal(
                  anim: _tl,
                  start: .74,
                  end: .96,
                  child: PrimaryButton(label: 'Terminé', onTap: () => Navigator.of(context).popUntil((r) => r.isFirst)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
