import 'package:flutter/material.dart';

import '../data.dart';
import '../demo.dart';
import '../theme.dart';
import '../widgets/bank_card.dart';
import '../widgets/sparkles.dart';
import '../widgets/ui.dart';
import 'picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final current = catalog.first;

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
                      Text(
                        'Tout voir',
                        style: TextStyle(
                          color: BC.blue.withValues(alpha: .9),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList.builder(
                itemCount: transactions.length,
                itemBuilder: (_, i) => _TxTile(tx: transactions[i]),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 96 + safeBottom(context))),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: safeBottom(context),
            child: Center(child: _NavPill(onCards: _openPicker)),
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
                    Container(
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
                    const CircleIconButton(icon: Icons.search_rounded, dark: true, tooltip: 'Rechercher'),
                    const SizedBox(width: 10),
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
                    const Text(
                      '2 450 000',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.5,
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
                GestureDetector(
                  onTap: onCard,
                  child: AspectRatio(
                    aspectRatio: kCardRatio,
                    child: CardHero(card: card),
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
    const items = [
      (Icons.north_east_rounded, 'Envoyer'),
      (Icons.south_west_rounded, 'Recevoir'),
      (Icons.add_card_rounded, 'Recharger'),
      (Icons.qr_code_scanner_rounded, 'Scanner'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Row(
        children: [
          for (final (icon, label) in items)
            Expanded(
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
        ],
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  const _TxTile({required this.tx});
  final Tx tx;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tx.credit ? BC.gold.withValues(alpha: .14) : BC.blue.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(tx.icon, size: 20, color: tx.credit ? BC.goldDeep : BC.navy),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                const SizedBox(height: 2),
                Text(tx.time, style: const TextStyle(color: BC.muted, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${tx.credit ? '+' : '−'}${fcfa(tx.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: tx.credit ? const Color(0xFF15803D) : BC.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavPill extends StatelessWidget {
  const _NavPill({required this.onCards});
  final VoidCallback onCards;
  @override
  Widget build(BuildContext context) {
    Widget item(IconData i, {bool active = false, VoidCallback? onTap, required String label}) => Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: active ? const BoxDecoration(shape: BoxShape.circle, gradient: BC.goldGradient) : null,
          child: Icon(i, color: active ? BC.ink : Colors.white.withValues(alpha: .7), size: 22),
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
          item(Icons.home_rounded, active: true, label: 'Accueil'),
          const SizedBox(width: 10),
          item(Icons.swap_horiz_rounded, label: 'Transferts'),
          const SizedBox(width: 10),
          item(Icons.credit_card_rounded, onTap: onCards, label: 'Cartes'),
          const SizedBox(width: 10),
          item(Icons.person_outline_rounded, label: 'Profil'),
        ],
      ),
    );
  }
}
