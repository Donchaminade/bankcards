import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'data.dart';
import 'demo.dart';
import 'screens/confirm.dart';
import 'screens/picker.dart';
import 'screens/placed.dart';
import 'screens/receipt.dart';
import 'screens/home.dart';
import 'state.dart';
import 'theme.dart';
import 'widgets/bank_card.dart';
import 'widgets/sparkles.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.load();
  final q = Uri.base.queryParameters;
  Demo.enabled = q['demo'] == '1';
  final slow = double.tryParse(q['slow'] ?? '') ?? 1;
  if (slow > 1) {
    Demo.slow = slow;
    timeDilation = slow;
  }
  runApp(BankCardsApp(chrome: q['frame'] != '0', screen: q['screen'], cardId: q['card']));
  // Arbre d'accessibilité (lecteurs d'écran, tests automatisés) : ?sem=1
  if (q['sem'] == '1') SemanticsBinding.instance.ensureSemantics();
}

class BankCardsApp extends StatelessWidget {
  const BankCardsApp({super.key, this.chrome = true, this.screen, this.cardId});
  final bool chrome;

  /// Ouverture directe d'un écran (?screen=picker|confirm|placed|receipt&card=gold), pratique pour les tests.
  final String? screen;
  final String? cardId;

  Widget _start() {
    final card = catalog.firstWhere((c) => c.id == cardId, orElse: () => catalog[2]);
    switch (screen) {
      case 'picker':
        return const PickerScreen();
      case 'confirm':
        return ConfirmScreen(card: card);
      case 'placed':
        return PlacedScreen(card: card);
      case 'receipt':
        return ReceiptScreen(card: card);
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BankCards',
      debugShowCheckedModeBanner: false,
      theme: BC.theme(),
      navigatorObservers: [ToneObserver()],
      builder: (context, child) {
        final size = MediaQuery.sizeOf(context);
        if (!chrome || size.width < 700) return child!;
        return DeviceShell(child: child!);
      },
      home: AnnotatedRegion<SystemUiOverlayStyle>(value: SystemUiOverlayStyle.light, child: _start()),
    );
  }
}

/// Sur grand écran : l'app est présentée dans un téléphone, sur un fond aux couleurs de la marque.
class DeviceShell extends StatelessWidget {
  const DeviceShell({super.key, required this.child});
  final Widget child;

  static const phone = Size(390, 844);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final portrait = size.height > size.width;
    final phoneWidget = _Phone(child: child);
    final pitch = _Pitch(center: portrait);
    return Material(
      color: BC.ink,
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(.35, -.2),
                  radius: 1.25,
                  colors: [Color(0xFF16357A), BC.navy, BC.ink],
                  stops: [0, .45, 1],
                ),
              ),
            ),
          ),
          const Positioned.fill(child: SparkleField(count: 70, seed: 99, maxSize: 9)),
          Positioned.fill(
            child: portrait
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: size.height * .04, horizontal: 40),
                    child: Column(
                      children: [
                        SizedBox(
                          height: size.height * .2,
                          child: FittedBox(child: pitch),
                        ),
                        SizedBox(height: size.height * .02),
                        Expanded(child: FittedBox(child: phoneWidget)),
                      ],
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(vertical: size.height * .05, horizontal: size.width * .07),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 11,
                          child: FittedBox(alignment: Alignment.centerLeft, child: pitch),
                        ),
                        SizedBox(width: size.width * .04),
                        Expanded(flex: 9, child: FittedBox(child: phoneWidget)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Pitch extends StatelessWidget {
  const _Pitch({required this.center});
  final bool center;
  @override
  Widget build(BuildContext context) {
    final align = center ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    const chips = ['Vol Hero 3D', 'Swipe incliné', 'Paillettes dorées', 'Paiement animé', 'Reçu imprimé'];
    return SizedBox(
      width: 620,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: align,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandMark(size: 46),
              const SizedBox(width: 18),
              ShaderMask(
                shaderCallback: (r) => BC.goldGradient.createShader(r),
                child: const Text(
                  'BankCards',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 84,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -2,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Commandez votre carte premium,\nen quelques gestes.',
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w700, height: 1.2),
          ),
          const SizedBox(height: 14),
          Text(
            'Classic · World · Gold · Platinum · Infinite',
            style: TextStyle(color: Colors.white.withValues(alpha: .6), fontSize: 19, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 26),
          Wrap(
            alignment: center ? WrapAlignment.center : WrapAlignment.start,
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final c in chips)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white.withValues(alpha: .06),
                    border: Border.all(color: BC.gold.withValues(alpha: .5)),
                  ),
                  child: Text(
                    c,
                    style: const TextStyle(color: BC.goldLight, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FlutterLogo(size: 26),
              const SizedBox(width: 10),
              Text(
                'Flutter · Dart · CustomPainter · Hero',
                style: TextStyle(color: Colors.white.withValues(alpha: .75), fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Phone extends StatelessWidget {
  const _Phone({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    const s = DeviceShell.phone;
    return Container(
      width: s.width + 24,
      height: s.height + 24,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF050608),
        borderRadius: BorderRadius.circular(64),
        border: Border.all(color: BC.gold.withValues(alpha: .55), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .6), blurRadius: 60, offset: const Offset(0, 30)),
          BoxShadow(color: BC.gold.withValues(alpha: .12), blurRadius: 40),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(52),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            size: s,
            padding: const EdgeInsets.only(top: 54, bottom: 30),
            viewPadding: const EdgeInsets.only(top: 54, bottom: 30),
          ),
          child: SizedBox.fromSize(
            size: s,
            child: Stack(
              children: [
                Positioned.fill(child: child),
                const Positioned(left: 0, right: 0, top: 0, child: _StatusBar()),
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ValueListenableBuilder(
                      valueListenable: statusDark,
                      builder: (_, dark, _) => Container(
                        width: 134,
                        height: 5,
                        decoration: BoxDecoration(
                          color: (dark ? Colors.white : Colors.black).withValues(alpha: .8),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
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

class _StatusBar extends StatelessWidget {
  const _StatusBar();
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ValueListenableBuilder(
        valueListenable: statusDark,
        builder: (_, dark, _) {
          final c = dark ? Colors.white : BC.ink;
          return SizedBox(
            height: 54,
            child: Stack(
              children: [
                Positioned(
                  left: 44,
                  top: 18,
                  child: Text(
                    '12:03',
                    style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
                Align(
                  alignment: const Alignment(0, .1),
                  child: Container(
                    width: 120,
                    height: 34,
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                Positioned(
                  right: 36,
                  top: 19,
                  child: Row(
                    children: [
                      Icon(Icons.signal_cellular_alt_rounded, size: 17, color: c),
                      const SizedBox(width: 5),
                      Icon(Icons.wifi_rounded, size: 17, color: c),
                      const SizedBox(width: 5),
                      Icon(Icons.battery_full_rounded, size: 19, color: c),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
