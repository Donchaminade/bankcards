import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data.dart';
import '../demo.dart';
import '../theme.dart';
import '../widgets/bank_card.dart';
import '../widgets/sparkles.dart';
import '../widgets/ui.dart';
import 'confirm.dart';

class PickerScreen extends StatefulWidget {
  const PickerScreen({super.key});
  @override
  State<PickerScreen> createState() => _PickerScreenState();
}

class _PickerScreenState extends State<PickerScreen> {
  final _pc = PageController(viewportFraction: .7);
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _pc.addListener(() => setState(() => _page = _pc.page ?? 0));
    var t = 1500;
    for (final p in [1, 2, 3, 4, 2]) {
      Demo.after(this, t, () => _pc.animateToPage(p, duration: const Duration(milliseconds: 750), curve: Curves.easeInOutCubic));
      t += 1250;
    }
    Demo.after(this, t + 300, _choose);
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  int get _index => _page.round().clamp(0, catalog.length - 1);

  void _choose() {
    Navigator.of(context).push(fadeRoute(ConfirmScreen(card: catalog[_index]), 'confirm', ms: 750));
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final i0 = _page.floor().clamp(0, catalog.length - 1);
    final i1 = (i0 + 1).clamp(0, catalog.length - 1);
    final glow = Color.lerp(catalog[i0].colors[1], catalog[i1].colors[1], _page - i0)!;
    final card = catalog[_index];
    return Scaffold(
      backgroundColor: BC.paper,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, .05),
                  radius: .8,
                  colors: [glow.withValues(alpha: .22), BC.paper.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
          const Positioned.fill(child: SparkleField(count: 18, seed: 5, maxSize: 6, intensity: .8)),
          Padding(
            padding: EdgeInsets.only(top: pad.top + 8, bottom: pad.bottom + 16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      CircleIconButton(
                          icon: Icons.chevron_left_rounded, onTap: () => Navigator.pop(context), tooltip: 'Retour'),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: BC.line),
                        ),
                        child: Text('${_index + 1} / ${catalog.length}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(height: 92, child: _Titles(page: _page)),
                Expanded(
                  child: PageView.builder(
                    controller: _pc,
                    itemCount: catalog.length,
                    itemBuilder: (_, i) {
                      final d = (i - _page).clamp(-1.5, 1.5);
                      final m = Matrix4.identity()
                        ..setEntry(3, 2, .0013)
                        ..rotateY(-d * .55)
                        ..scaleByDouble(1 - .14 * d.abs(), 1 - .14 * d.abs(), 1, 1);
                      return Opacity(
                        opacity: (1 - .45 * d.abs()).clamp(0, 1),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: m,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              child: AspectRatio(
                                aspectRatio: 1 / kCardRatio,
                                child: GestureDetector(
                                  onTap: i == _index ? _choose : null,
                                  child: CardHero(card: catalog[i], pose: const CardPose(quarter: 1)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                _Dots(page: _page),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: PrimaryButton(
                    label: 'Choisir ${card.networkLabel} ${card.name}',
                    icon: Icons.auto_awesome_rounded,
                    onTap: _choose,
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

class _Titles extends StatelessWidget {
  const _Titles({required this.page});
  final double page;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        for (var i = 0; i < catalog.length; i++)
          if ((i - page).abs() < 1)
            Opacity(
              opacity: (1 - (i - page).abs() * 1.4).clamp(0, 1),
              child: Transform.translate(
                offset: Offset((i - page) * 110, 0),
                child: _Title(card: catalog[i]),
              ),
            ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.card});
  final CardType card;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(card.networkLabel.toUpperCase(),
            style: const TextStyle(color: BC.goldDeep, fontSize: 11, letterSpacing: 2.4, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(card.name, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -.4)),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(children: [
            TextSpan(text: fcfa(card.price), style: const TextStyle(fontWeight: FontWeight.w800, color: BC.ink)),
            const TextSpan(text: ' / an  ·  ', style: TextStyle(color: BC.muted)),
            TextSpan(text: card.material, style: const TextStyle(color: BC.muted)),
          ]),
          style: const TextStyle(fontSize: 13.5),
        ),
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.page});
  final double page;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < catalog.length; i++)
          Builder(builder: (_) {
            final t = (1 - (i - page).abs()).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 7 + 18 * t,
              height: 7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Color.lerp(BC.line, BC.gold, t),
                boxShadow: t > .5 ? [BoxShadow(color: BC.gold.withValues(alpha: .5 * t), blurRadius: 8)] : null,
              ),
            );
          }),
      ],
    );
  }
}

double clampAngle(double a) => math.max(-1, math.min(1, a));
