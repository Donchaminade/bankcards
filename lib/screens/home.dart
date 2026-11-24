import 'package:flutter/material.dart';

import '../data.dart';
import '../demo.dart';
import '../theme.dart';
import '../widgets/bank_card.dart';
import '../widgets/sparkles.dart';
import '../state.dart';
import '../widgets/ui.dart';
import 'notifications.dart';
import 'picker.dart';
import 'profile.dart';
import 'scanner.dart';
import 'sheets.dart';
import 'transactions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final current = catalog.first;
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Demo.restartHome = () => Demo.after(this, 1800, _openPicker);
    Demo.after(this, 1600, _openPicker);
  }

  void _openPicker() {
    Navigator.of(context).push(fadeRoute(const PickerScreen(), 'picker', ms: 700));
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: BC.paper,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverToBoxAdapter(
                child: _Header(card: current, top: pad.top, onCard: _openPicker),
              ),
              const SliverToBoxAdapter(child: _QuickActions()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
                  child: Row(
                    children: [
                      const Text('Transactions récentes', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                      const Spacer(),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).push(fadeRoute(const TransactionsScreen(), 'transactions')),
                        style: TextButton.styleFrom(
                          foregroundColor: BC.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text('Tout voir', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: AppState.txs,
                builder: (_, txs, _) => SliverList.builder(
                  itemCount: txs.length.clamp(0, 6),
                  itemBuilder: (_, i) => TxTile(tx: txs[i]),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 96 + safeBottom(context))),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: safeBottom(context),
            child: Center(
              child: _NavPill(
                onHome: () =>
                    _scroll.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic),
                onTransfers: () => showSendSheet(context),
                onCards: _openPicker,
                onProfile: () => Navigator.of(context).push(fadeRoute(const ProfileScreen(), 'profile')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.card, required this.top, required this.onCard});
  final CardType card;
  final double top;
  final VoidCallback onCard;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0E2A63), BC.navy, BC.ink],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: SparkleField(count: 26, seed: 11, maxSize: 6)),
          Padding(
            padding: EdgeInsets.fromLTRB(20, top + 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Semantics(
                      button: true,
                      label: 'Mon profil',
                      excludeSemantics: true,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(fadeRoute(const ProfileScreen(), 'profile')),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(shape: BoxShape.circle, gradient: BC.goldGradient),
                          child: const CircleAvatar(
                            radius: 19,
                            backgroundColor: BC.navy,
                            child: Text(
                              'CA',
                              style: TextStyle(color: BC.goldLight, fontWeight: FontWeight.w800, fontSize: 13),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bonjour,', style: TextStyle(color: Colors.white.withValues(alpha: .6), fontSize: 13)),
                          const Text(
                            holderShort,
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    CircleIconButton(
                      icon: Icons.search_rounded,
                      dark: true,
                      tooltip: 'Rechercher',
                      onTap: () => showSearchSheet(context),
                    ),
                    const SizedBox(width: 8),
                    ValueListenableBuilder(
                      valueListenable: AppState.notifs,
                      builder: (_, _, _) => Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleIconButton(
                            icon: Icons.notifications_none_rounded,
                            dark: true,
                            tooltip: 'Notifications',
                            onTap: () =>
                                Navigator.of(context).push(fadeRoute(const NotificationsScreen(), 'notifications')),
                          ),
                          if (AppState.unread > 0)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: IgnorePointer(
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: BC.goldGradient,
                                    border: Border.all(color: BC.navy, width: 2),
                                  ),
                                  child: Text(
                                    '${AppState.unread}',
                                    style: const TextStyle(color: BC.ink, fontSize: 9.5, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleIconButton(icon: Icons.add_rounded, dark: true, onTap: onCard, tooltip: 'Nouvelle carte'),
                  ],
                ),
                const SizedBox(height: 22),
                Text('Solde disponible', style: TextStyle(color: Colors.white.withValues(alpha: .6), fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    ValueListenableBuilder(
                      valueListenable: AppState.balance,
                      builder: (_, b, _) => TweenAnimationBuilder<double>(
                        tween: Tween(end: b.toDouble()),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, _) => Text(
                          fcfa(v.round()).replaceAll(' FCFA', ''),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ShaderMask(
                      shaderCallback: (r) => BC.goldGradient.createShader(r),
                      child: const Text(
                        'FCFA',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withValues(alpha: .16),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '+12,4 %',
                        style: TextStyle(color: Color(0xFF4ADE80), fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Semantics(
                  button: true,
                  label: 'Ma carte Visa Classic, choisir une nouvelle carte',
                  excludeSemantics: true,
                  child: GestureDetector(
                    onTap: onCard,
                    child: AspectRatio(
                      aspectRatio: kCardRatio,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CardHero(card: card),
                          ValueListenableBuilder(
                            valueListenable: AppState.frozen,
                            builder: (_, f, _) => IgnorePointer(
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: f ? 1 : 0,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: BC.ink.withValues(alpha: .85),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(color: BC.gold.withValues(alpha: .6)),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.ac_unit_rounded, color: BC.goldLight, size: 16),
                                        SizedBox(width: 6),
                                        Text(
                                          'Carte gelée',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();
  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.north_east_rounded, 'Envoyer', () => showSendSheet(context)),
      (Icons.south_west_rounded, 'Recevoir', () => showReceiveSheet(context)),
      (Icons.add_card_rounded, 'Recharger', () => showTopUpSheet(context)),
      (
        Icons.qr_code_scanner_rounded,
        'Scanner',
        () => Navigator.of(context).push(fadeRoute(const ScannerScreen(), 'scanner')),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Row(
        children: [
          for (final (icon, label, onTap) in items)
            Expanded(
              child: Semantics(
                button: true,
                label: label,
                excludeSemantics: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: BC.line),
                          ),
                          child: Icon(icon, color: BC.navy, size: 22),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: BC.ink),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavPill extends StatelessWidget {
  const _NavPill({required this.onHome, required this.onTransfers, required this.onCards, required this.onProfile});
  final VoidCallback onHome, onTransfers, onCards, onProfile;
  @override
  Widget build(BuildContext context) {
    Widget item(IconData i, {bool active = false, VoidCallback? onTap, required String label}) => Tooltip(
      message: label,
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        label: label,
        selected: active,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 52,
            height: 52,
            decoration: active ? const BoxDecoration(shape: BoxShape.circle, gradient: BC.goldGradient) : null,
            child: Icon(i, color: active ? BC.ink : Colors.white.withValues(alpha: .7), size: 22),
          ),
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: BC.ink,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: BC.gold.withValues(alpha: .35)),
        boxShadow: [BoxShadow(color: BC.navy.withValues(alpha: .35), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          item(Icons.home_rounded, active: true, onTap: onHome, label: 'Accueil'),
          const SizedBox(width: 10),
          item(Icons.swap_horiz_rounded, onTap: onTransfers, label: 'Transferts'),
          const SizedBox(width: 10),
          item(Icons.credit_card_rounded, onTap: onCards, label: 'Cartes'),
          const SizedBox(width: 10),
          item(Icons.person_outline_rounded, onTap: onProfile, label: 'Profil'),
        ],
      ),
    );
  }
}
