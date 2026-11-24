import 'dart:async';

import 'package:flutter/widgets.dart';

/// Mode démo (?demo=1) : le parcours se joue tout seul (utile pour l'enregistrement vidéo).
class Demo {
  static bool enabled = false;
  static bool loop = true;
  static VoidCallback? restartHome;

  /// Facteur de ralenti (enregistrement vidéo) : appliqué aussi aux minuteries.
  static double slow = 1;
  static Duration d(int ms) => Duration(milliseconds: (ms * slow).round());

  static void after(State s, int ms, VoidCallback fn) {
    if (!enabled) return;
    Timer(d(ms), () {
      if (s.mounted) fn();
    });
  }
}

/// Ton de la barre d'état simulée (cadre téléphone sur grand écran).
final statusDark = ValueNotifier<bool>(true);

class ToneObserver extends NavigatorObserver {
  static const dark = {'/', 'home', 'receipt', 'profile', 'scanner'};
  void _set(Route<dynamic>? r) {
    if (r == null) return;
    statusDark.value = dark.contains(r.settings.name ?? '/');
  }

  @override
  void didPush(Route route, Route? previousRoute) => _set(route);
  @override
  void didPop(Route route, Route? previousRoute) => _set(previousRoute);
  @override
  void didReplace({Route? newRoute, Route? oldRoute}) => _set(newRoute);
}

Route<T> fadeRoute<T>(Widget page, String name, {int ms = 650}) => PageRouteBuilder<T>(
  settings: RouteSettings(name: name),
  transitionDuration: Duration(milliseconds: ms),
  reverseTransitionDuration: Duration(milliseconds: ms),
  pageBuilder: (_, _, _) => page,
  transitionsBuilder: (_, a, _, child) => FadeTransition(
    opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
    child: child,
  ),
);
