import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../theme.dart';

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({super.key, required this.icon, this.onTap, this.dark = false, this.tooltip});
  final IconData icon;
  final VoidCallback? onTap;
  final bool dark;
  final String? tooltip;
  @override
  Widget build(BuildContext context) {
    final w = Material(
      color: dark ? Colors.white.withValues(alpha: .08) : Colors.white,
      shape: CircleBorder(side: BorderSide(color: dark ? Colors.white.withValues(alpha: .14) : BC.line)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 42, height: 42, child: Icon(icon, size: 20, color: dark ? Colors.white : BC.ink)),
      ),
    );
    return tooltip == null ? w : Tooltip(message: tooltip!, child: w);
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, this.onTap, this.light = false, this.icon});
  final String label;
  final VoidCallback? onTap;
  final bool light;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: Material(
        color: light ? Colors.white : BC.ink,
        shape: StadiumBorder(side: BorderSide(color: light ? BC.line : BC.gold.withValues(alpha: .55))),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: light ? BC.ink : BC.goldLight),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(color: light ? BC.ink : Colors.white, fontWeight: FontWeight.w700, fontSize: 15.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Apparition décalée (fondu + glissement) pilotée par un contrôleur.
class Reveal extends StatelessWidget {
  const Reveal({
    super.key,
    required this.anim,
    required this.start,
    required this.end,
    required this.child,
    this.dy = 18,
  });
  final Animation<double> anim;
  final double start, end, dy;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final a = CurvedAnimation(
      parent: anim,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: a,
      builder: (_, c) => Opacity(
        opacity: a.value,
        child: Transform.translate(offset: Offset(0, dy * (1 - a.value)), child: c),
      ),
      child: child,
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow(this.label, this.value, {super.key, this.bold = false, this.last = false, this.onTap});
  final String label, value;
  final bool bold, last;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final row = Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: BC.line)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: bold ? BC.ink : BC.muted,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: BC.ink,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                fontSize: bold ? 16 : 14,
              ),
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 6),
            const Icon(Icons.edit_outlined, size: 16, color: BC.goldDeep),
          ],
        ],
      ),
    );
    if (onTap == null) return row;
    return Semantics(
      button: true,
      label: 'Modifier $label : $value',
      excludeSemantics: true,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BC.line),
        boxShadow: [BoxShadow(color: BC.navy.withValues(alpha: .04), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: child,
    );
  }
}

/// Marge basse sûre : zone de sécurité (encoche, barre d'accueil) + marge généreuse.
/// Sur le web mobile (Safari, viewport-fit=cover), Flutter ne reçoit pas l'encart de la barre
/// d'accueil : on réserve alors 44 px pour garder les boutons bien au-dessus.
double safeBottom(BuildContext context) {
  final mq = MediaQuery.of(context);
  final inset = math.max(mq.viewPadding.bottom, mq.padding.bottom);
  if (inset > 0) return inset + 14;
  return kIsWeb ? 44 : 24;
}
