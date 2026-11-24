import 'package:flutter/material.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/kit.dart';
import '../widgets/ui.dart';
import 'sheets.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});
  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int _filter = 0;
  static const _filters = ['Tout', 'Dépenses', 'Entrées'];

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: BC.paper,
      body: ValueListenableBuilder(
        valueListenable: AppState.txs,
        builder: (_, all, _) {
          final list = all.where((t) => _filter == 0 || (_filter == 1 ? !t.credit : t.credit)).toList();
          final out = all.where((t) => !t.credit).fold<int>(0, (s, t) => s + t.amount);
          final inn = all.where((t) => t.credit).fold<int>(0, (s, t) => s + t.amount);
          return ListView(
            padding: EdgeInsets.fromLTRB(0, pad.top + 8, 0, safeBottom(context) + 8),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    CircleIconButton(
                      icon: Icons.chevron_left_rounded,
                      onTap: () => Navigator.pop(context),
                      tooltip: 'Retour',
                    ),
                    const Expanded(
                      child: Text(
                        'Transactions',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                    CircleIconButton(
                      icon: Icons.search_rounded,
                      onTap: () => showSearchSheet(context),
                      tooltip: 'Rechercher',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _Stat(label: 'Entrées', value: '+${fcfa(inn)}', gold: true),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Stat(label: 'Dépenses', value: '−${fcfa(out)}'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    for (final (i, f) in _filters.indexed) ...[
                      if (i > 0) const SizedBox(width: 8),
                      ChoicePill(label: f, selected: i == _filter, onTap: () => setState(() => _filter = i)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              for (final t in list) TxTile(tx: t),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PrimaryButton(
                  label: 'Exporter le relevé',
                  light: true,
                  icon: Icons.ios_share_rounded,
                  onTap: () => shareOrCopy(
                    context,
                    title: 'Relevé BankCards',
                    text:
                        'Relevé BankCards · $holderName\n${all.map((t) => '${t.time}  ${t.title}  ${t.credit ? '+' : '-'}${fcfa(t.amount)}').join('\n')}',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.gold = false});
  final String label, value;
  final bool gold;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: gold ? BC.navy : Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: gold ? BC.gold.withValues(alpha: .45) : BC.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: gold ? Colors.white.withValues(alpha: .65) : BC.muted, fontSize: 12.5)),
        const SizedBox(height: 4),
        FittedBox(
          child: Text(
            value,
            style: TextStyle(color: gold ? BC.goldLight : BC.ink, fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ),
      ],
    ),
  );
}
