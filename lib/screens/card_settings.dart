import 'dart:async';

import 'package:flutter/material.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/bank_card.dart';
import '../widgets/kit.dart';
import '../widgets/ui.dart';

/// Paramètres de la carte : gel, plafonds, options de paiement, code PIN masqué, opposition.
class CardSettingsScreen extends StatefulWidget {
  const CardSettingsScreen({super.key});
  @override
  State<CardSettingsScreen> createState() => _CardSettingsScreenState();
}

class _CardSettingsScreenState extends State<CardSettingsScreen> {
  final card = catalog.first;
  static const _pin = '7351';
  bool _pinVisible = false, _checking = false;
  int _left = 0;
  Timer? _t;

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  Future<void> _revealPin() async {
    if (_pinVisible) {
      _t?.cancel();
      setState(() => _pinVisible = false);
      return;
    }
    setState(() => _checking = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _checking = false;
      _pinVisible = true;
      _left = 5;
    });
    _t?.cancel();
    _t = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _left--);
      if (_left <= 0) {
        t.cancel();
        setState(() => _pinVisible = false);
      }
    });
  }

  void _toggle(String k, bool v, String on, String off) {
    AppState.toggles.value = {...AppState.toggles.value, k: v};
    AppState.save();
    toast(context, v ? on : off, icon: Icons.tune_rounded);
  }

  Future<void> _oppose() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Faire opposition ?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
          'La carte ·· 4821 sera bloquée définitivement et une nouvelle carte vous sera envoyée gratuitement.',
          style: TextStyle(color: BC.muted, height: 1.45),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Confirmer',
              style: TextStyle(color: Color(0xFFB42318), fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    AppState.frozen.value = true;
    AppState.save();
    toast(context, 'Opposition enregistrée. Nouvelle carte en préparation.', icon: Icons.block_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: BC.paper,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, pad.top + 8, 20, safeBottom(context) + 8),
        children: [
          Row(
            children: [
              CircleIconButton(
                icon: Icons.chevron_left_rounded,
                onTap: () => Navigator.pop(context),
                tooltip: 'Retour',
              ),
              const Expanded(
                child: Text(
                  'Paramètres de la carte',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              const SizedBox(width: 42),
            ],
          ),
          const SizedBox(height: 18),
          ValueListenableBuilder(
            valueListenable: AppState.frozen,
            builder: (_, frozen, _) => Column(
              children: [
                AspectRatio(
                  aspectRatio: kCardRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 400),
                        opacity: frozen ? .55 : 1,
                        child: ColorFiltered(
                          colorFilter: frozen
                              ? const ColorFilter.matrix([
                                  .33,
                                  .33,
                                  .33,
                                  0,
                                  10,
                                  .33,
                                  .33,
                                  .33,
                                  0,
                                  18,
                                  .33,
                                  .33,
                                  .33,
                                  0,
                                  34,
                                  0,
                                  0,
                                  0,
                                  1,
                                  0,
                                ])
                              : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                          child: BankCardView(card: card),
                        ),
                      ),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 400),
                        opacity: frozen ? 1 : 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: BC.ink.withValues(alpha: .85),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: BC.gold.withValues(alpha: .6)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.ac_unit_rounded, color: BC.goldLight, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Carte gelée',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _Group(
                  children: [
                    MenuTile(
                      icon: Icons.ac_unit_rounded,
                      gold: frozen,
                      title: 'Geler la carte',
                      subtitle: frozen ? 'Tous les paiements sont suspendus' : 'Suspendre temporairement les paiements',
                      trailing: BcSwitch(
                        value: frozen,
                        onChanged: (v) {
                          AppState.frozen.value = v;
                          AppState.save();
                          toast(
                            context,
                            v ? 'Carte gelée. Dégel possible à tout moment.' : 'Carte réactivée',
                            icon: Icons.ac_unit_rounded,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const _Title('Plafonds'),
          _Group(
            children: [
              _LimitSlider(label: 'Paiements par mois', value: AppState.payLimit, max: 3000000),
              const Divider(color: BC.line, height: 1),
              _LimitSlider(label: 'Retraits par semaine', value: AppState.cashLimit, max: 1000000),
            ],
          ),
          const _Title('Options de paiement'),
          ValueListenableBuilder(
            valueListenable: AppState.toggles,
            builder: (_, t, _) => _Group(
              children: [
                MenuTile(
                  icon: Icons.contactless_outlined,
                  title: 'Sans contact',
                  subtitle: 'Jusqu’à 50 000 FCFA sans code',
                  trailing: BcSwitch(
                    value: t['contactless']!,
                    onChanged: (v) => _toggle('contactless', v, 'Sans contact activé', 'Sans contact désactivé'),
                  ),
                ),
                MenuTile(
                  icon: Icons.language_rounded,
                  title: 'Paiements en ligne',
                  subtitle: 'Sites marchands et abonnements',
                  trailing: BcSwitch(
                    value: t['online']!,
                    onChanged: (v) =>
                        _toggle('online', v, 'Paiements en ligne activés', 'Paiements en ligne désactivés'),
                  ),
                ),
                MenuTile(
                  icon: Icons.public_rounded,
                  title: 'Paiements à l’étranger',
                  subtitle: 'Hors zone UEMOA',
                  trailing: BcSwitch(
                    value: t['abroad']!,
                    onChanged: (v) =>
                        _toggle('abroad', v, 'Paiements à l’étranger activés', 'Paiements à l’étranger désactivés'),
                  ),
                ),
              ],
            ),
          ),
          const _Title('Code PIN'),
          _Group(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Row(
                  children: [
                    const IconBadge(Icons.pin_outlined, size: 42),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              _pinVisible ? _pin.split('').join(' ') : '• • • •',
                              key: ValueKey(_pinVisible),
                              maxLines: 1,
                              softWrap: false,
                              style: const TextStyle(
                                fontFamily: kMono,
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                          Text(
                            _checking
                                ? 'Vérification biométrique…'
                                : _pinVisible
                                ? 'Masqué dans $_left s'
                                : 'Masqué par sécurité',
                            style: const TextStyle(color: BC.muted, fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 104,
                      height: 42,
                      child: Material(
                        color: BC.ink,
                        shape: StadiumBorder(side: BorderSide(color: BC.gold.withValues(alpha: .55))),
                        child: InkWell(
                          customBorder: const StadiumBorder(),
                          onTap: _checking ? null : _revealPin,
                          child: Center(
                            child: _checking
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: BC.goldLight),
                                  )
                                : Text(
                                    _pinVisible ? 'Masquer' : 'Afficher',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _Group(
            children: [
              MenuTile(
                icon: Icons.block_rounded,
                danger: true,
                title: 'Faire opposition',
                subtitle: 'Carte perdue ou volée',
                onTap: _oppose,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
  );
}

class _Group extends StatelessWidget {
  const _Group({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Panel(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(children: children),
    ),
  );
}

class _LimitSlider extends StatelessWidget {
  const _LimitSlider({required this.label, required this.value, required this.max});
  final String label;
  final ValueNotifier<double> value;
  final double max;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: value,
      builder: (_, v, _) => Padding(
        padding: const EdgeInsets.only(top: 14, left: 4, right: 4, bottom: 4),
        child: Column(
          children: [
            Row(
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const Spacer(),
                Text(fcfa(v.round()), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: BC.navy,
                inactiveTrackColor: BC.line,
                thumbColor: BC.gold,
                overlayColor: BC.gold.withValues(alpha: .15),
                trackHeight: 4,
              ),
              child: Slider(
                value: v,
                min: 0,
                max: max,
                divisions: (max / 50000).round(),
                label: fcfa(v.round()),
                onChanged: (x) => value.value = x,
                onChangeEnd: (x) {
                  AppState.save();
                  toast(context, '$label : ${fcfa(x.round())}', icon: Icons.speed_rounded);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
