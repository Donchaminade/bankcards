import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../share/share_stub.dart' if (dart.library.js_interop) '../share/share_web.dart';
import '../theme.dart';
import 'ui.dart';

/// Retour visuel discret, dans la charte (encre, filet or). Affiché dans l'overlay
/// le plus haut : visible aussi au-dessus d'une bottom sheet.
OverlayEntry? _toastEntry;

void toast(BuildContext context, String message, {IconData icon = Icons.check_circle_rounded}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  _toastEntry?.remove();
  _toastEntry = null;
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _Toast(
      message: message,
      icon: icon,
      onEnd: () {
        if (_toastEntry == entry) {
          entry.remove();
          _toastEntry = null;
        }
      },
    ),
  );
  _toastEntry = entry;
  overlay.insert(entry);
}

class _Toast extends StatefulWidget {
  const _Toast({required this.message, required this.icon, required this.onEnd});
  final String message;
  final IconData icon;
  final VoidCallback onEnd;
  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 320))
    ..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2600), () async {
      if (!mounted) return;
      await _c.reverse();
      widget.onEnd();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final a = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    return Positioned(
      left: 16,
      right: 16,
      top: top + 12,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: a,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, -.6), end: Offset.zero).animate(a),
            child: Material(
              color: Colors.transparent,
              child: Semantics(
                liveRegion: true,
                label: widget.message,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: BC.ink,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: BC.gold.withValues(alpha: .5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .25),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(widget.icon, color: BC.goldLight, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Partage réel (Web Share API sur le web, feuille de partage native sur mobile),
/// avec repli : copie dans le presse-papiers.
Future<void> shareOrCopy(BuildContext context, {required String title, required String text}) async {
  bool? shared;
  try {
    shared = await platformShare(title, text);
  } catch (_) {
    shared = null;
  }
  if (!context.mounted) return;
  if (shared == true) {
    toast(context, 'Partagé avec succès', icon: Icons.ios_share_rounded);
  } else if (shared == null) {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) toast(context, 'Copié dans le presse-papiers', icon: Icons.content_copy_rounded);
  }
}

/// Bottom sheet BankCards : coins arrondis, poignée, titre, bouton fermer, zone de sécurité.
Future<T?> showBcSheet<T>(
  BuildContext context, {
  required String title,
  String? subtitle,
  required WidgetBuilder builder,
  String name = 'sheet',
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: BC.ink.withValues(alpha: .45),
    routeSettings: RouteSettings(name: name),
    builder: (ctx) => _Sheet(title: title, subtitle: subtitle, builder: builder),
  );
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.title, this.subtitle, required this.builder});
  final String title;
  final String? subtitle;
  final WidgetBuilder builder;
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: mq.size.height * .9),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: BC.line, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 14, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, letterSpacing: -.3),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(subtitle!, style: const TextStyle(color: BC.muted, fontSize: 13.5, height: 1.35)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleIconButton(icon: Icons.close_rounded, onTap: () => Navigator.pop(context), tooltip: 'Fermer'),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 12, 20, safeBottom(context)),
                child: Builder(builder: builder),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pastille d'icône carrée arrondie (navy ou or).
class IconBadge extends StatelessWidget {
  const IconBadge(this.icon, {super.key, this.gold = false, this.size = 44});
  final IconData icon;
  final bool gold;
  final double size;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: gold ? BC.gold.withValues(alpha: .14) : BC.blue.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(size * .32),
      ),
      child: Icon(icon, size: size * .46, color: gold ? BC.goldDeep : BC.navy),
    );
  }
}

/// Ligne de réglage / menu : icône, titre, sous-titre, chevron ou interrupteur.
class MenuTile extends StatelessWidget {
  const MenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.gold = false,
    this.danger = false,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool gold, danger;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              IconBadge(icon, gold: gold, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: danger ? const Color(0xFFB42318) : BC.ink,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: const TextStyle(color: BC.muted, fontSize: 12.5)),
                    ],
                  ],
                ),
              ),
              trailing ?? const Icon(Icons.chevron_right_rounded, color: BC.muted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Interrupteur aux couleurs de la marque.
class BcSwitch extends StatelessWidget {
  const BcSwitch({super.key, required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => Switch(
    value: value,
    onChanged: onChanged,
    activeThumbColor: Colors.white,
    activeTrackColor: BC.navy,
    inactiveThumbColor: Colors.white,
    inactiveTrackColor: BC.line,
    trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
  );
}

/// Champ de saisie sobre.
class BcField extends StatelessWidget {
  const BcField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboard,
    this.maxLines = 1,
    this.onChanged,
    this.autofocus = false,
    this.prefix,
  });
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType? keyboard;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final IconData? prefix;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: BC.muted),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          maxLines: maxLines,
          autofocus: autofocus,
          onChanged: onChanged,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: BC.muted, fontWeight: FontWeight.w500),
            prefixIcon: prefix == null ? null : Icon(prefix, size: 20, color: BC.muted),
            filled: true,
            fillColor: BC.paper,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: BC.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: BC.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: BC.gold, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}

/// Puce sélectionnable.
class ChoicePill extends StatelessWidget {
  const ChoicePill({super.key, required this.label, required this.selected, required this.onTap, this.icon});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? BC.navy : Colors.white,
      shape: StadiumBorder(side: BorderSide(color: selected ? BC.gold.withValues(alpha: .7) : BC.line)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: selected ? BC.goldLight : BC.navy),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: selected ? Colors.white : BC.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bouton principal avec état « en cours ».
class BusyButton extends StatelessWidget {
  const BusyButton({super.key, required this.label, required this.onTap, this.busy = false, this.icon});
  final String label;
  final VoidCallback? onTap;
  final bool busy;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: onTap == null && !busy ? .45 : 1,
      child: busy
          ? Container(
              height: 56,
              decoration: ShapeDecoration(
                color: BC.ink,
                shape: StadiumBorder(side: BorderSide(color: BC.gold.withValues(alpha: .55))),
              ),
              alignment: Alignment.center,
              child: const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: BC.goldLight),
              ),
            )
          : PrimaryButton(label: label, icon: icon, onTap: onTap),
    );
  }
}

/// Écran de succès dans une feuille.
class SuccessBlock extends StatelessWidget {
  const SuccessBlock({super.key, required this.title, required this.body, this.onDone, this.doneLabel = 'Terminé'});
  final String title, body;
  final VoidCallback? onDone;
  final String doneLabel;
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (_, t, c) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.scale(scale: .9 + .1 * t, child: c),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: BC.goldGradient),
            child: const Icon(Icons.check_rounded, color: BC.ink, size: 38),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(color: BC.muted, fontSize: 14, height: 1.45),
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: doneLabel, onTap: onDone ?? () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
