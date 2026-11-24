import 'dart:async';

import 'package:flutter/material.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/kit.dart';
import '../widgets/sparkles.dart';
import '../widgets/ui.dart';

/// Scanner de QR (simulé) : un code marchand est « détecté » puis payé.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _line = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
    ..repeat(reverse: true);
  bool _torch = false, _found = false, _paying = false;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _scan();
  }

  void _scan() {
    _t?.cancel();
    setState(() => _found = false);
    _t = Timer(const Duration(milliseconds: 2400), () {
      if (mounted) setState(() => _found = true);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    _line.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    setState(() => _paying = true);
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    AppState.addTx(const Tx('Café 228 · Lomé', 'À l’instant', 3500, Icons.local_cafe_outlined));
    toast(context, '3 500 FCFA payés à Café 228');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: BC.ink,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -.25),
                  radius: 1,
                  colors: [_torch ? const Color(0xFF3A4A70) : const Color(0xFF13285A), BC.ink],
                ),
              ),
            ),
          ),
          const Positioned.fill(child: SparkleField(count: 16, seed: 41, maxSize: 5, intensity: .7)),
          Padding(
            padding: EdgeInsets.fromLTRB(20, pad.top + 8, 20, safeBottom(context)),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleIconButton(
                      icon: Icons.close_rounded,
                      dark: true,
                      onTap: () => Navigator.pop(context),
                      tooltip: 'Fermer',
                    ),
                    const Expanded(
                      child: Text(
                        'Scanner un QR code',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ),
                    CircleIconButton(
                      icon: _torch ? Icons.flashlight_on_rounded : Icons.flashlight_off_rounded,
                      dark: true,
                      tooltip: 'Lampe',
                      onTap: () => setState(() => _torch = !_torch),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: 250,
                  height: 250,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(painter: _Corners(found: _found)),
                      ),
                      if (!_found)
                        AnimatedBuilder(
                          animation: _line,
                          builder: (_, _) => Positioned(
                            left: 18,
                            right: 18,
                            top: 18 + 210 * Curves.easeInOut.transform(_line.value),
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.transparent, BC.goldLight, Colors.transparent],
                                ),
                                boxShadow: [BoxShadow(color: BC.gold.withValues(alpha: .6), blurRadius: 12)],
                              ),
                            ),
                          ),
                        )
                      else
                        const Center(child: Icon(Icons.check_circle_rounded, color: BC.goldLight, size: 64)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _found ? 'QR code détecté' : 'Placez le QR code du marchand dans le cadre',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 14),
                ),
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: _found
                      ? Container(
                          key: const ValueKey('found'),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                          child: Column(
                            children: [
                              const Row(
                                children: [
                                  IconBadge(Icons.local_cafe_outlined, gold: true),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Café 228', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                        Text(
                                          'Boulevard du 13 Janvier · Lomé',
                                          style: TextStyle(color: BC.muted, fontSize: 12.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text('3 500 FCFA', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: PrimaryButton(label: 'Rescanner', light: true, onTap: _scan),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: BusyButton(
                                      busy: _paying,
                                      label: 'Payer',
                                      icon: Icons.lock_outline_rounded,
                                      onTap: _pay,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : SizedBox(
                          key: const ValueKey('wait'),
                          height: 56,
                          child: Center(
                            child: Text(
                              'Recherche en cours…',
                              style: TextStyle(color: Colors.white.withValues(alpha: .55), fontSize: 13),
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

class _Corners extends CustomPainter {
  const _Corners({required this.found});
  final bool found;
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = found ? BC.goldLight : Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    const l = 38.0, r = 22.0;
    for (final (x, y, dx, dy) in [
      (0.0, 0.0, 1.0, 1.0),
      (s.width, 0.0, -1.0, 1.0),
      (0.0, s.height, 1.0, -1.0),
      (s.width, s.height, -1.0, -1.0),
    ]) {
      final path = Path()
        ..moveTo(x, y + dy * l)
        ..lineTo(x, y + dy * r)
        ..quadraticBezierTo(x, y, x + dx * r, y)
        ..lineTo(x + dx * l, y);
      canvas.drawPath(path, p);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & s, const Radius.circular(22)),
      Paint()..color = Colors.white.withValues(alpha: .04),
    );
  }

  @override
  bool shouldRepaint(_Corners o) => o.found != found;
}
