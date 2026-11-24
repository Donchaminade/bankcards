import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/kit.dart';
import '../widgets/ui.dart';

int _parseAmount(String s) => int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

// ---------------------------------------------------------------- Envoyer

const _contacts = [
  ('Kossi A.', 'KA', '+228 90 45 12 08'),
  ('Afi M.', 'AM', '+228 91 22 07 63'),
  ('Yao D.', 'YD', '+228 99 80 34 11'),
  ('Esso K.', 'EK', '+228 93 61 75 20'),
];

Future<void> showSendSheet(BuildContext context) => showBcSheet(
  context,
  title: 'Envoyer de l’argent',
  subtitle: 'Virement instantané vers un contact BankCards ou Mobile Money.',
  name: 'send',
  builder: (_) => const _SendForm(),
);

class _SendForm extends StatefulWidget {
  const _SendForm();
  @override
  State<_SendForm> createState() => _SendFormState();
}

class _SendFormState extends State<_SendForm> {
  int _who = 0;
  final _amount = TextEditingController();
  final _note = TextEditingController();
  bool _busy = false, _done = false;
  int get _value => _parseAmount(_amount.text);

  Future<void> _send() async {
    setState(() => _busy = true);
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    final c = _contacts[_who];
    AppState.addTx(Tx('Virement · ${c.$1}', 'À l’instant', _value, Icons.north_east_rounded));
    setState(() {
      _busy = false;
      _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return SuccessBlock(
        title: '${fcfa(_value)} envoyés',
        body: 'À ${_contacts[_who].$1} (${_contacts[_who].$3}).\nNouveau solde : ${fcfa(AppState.balance.value)}.',
      );
    }
    final bal = AppState.balance.value;
    final over = _value > bal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Destinataire',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: BC.muted),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final (i, c) in _contacts.indexed)
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _who = i),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: i == _who ? BC.goldGradient : null,
                          color: i == _who ? null : BC.line,
                        ),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: BC.navy,
                          child: Text(
                            c.$2,
                            style: const TextStyle(color: BC.goldLight, fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        c.$1,
                        style: TextStyle(fontSize: 12, fontWeight: i == _who ? FontWeight.w800 : FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        BcField(
          label: 'Montant (FCFA)',
          hint: 'Ex. 25 000',
          controller: _amount,
          keyboard: TextInputType.number,
          prefix: Icons.payments_outlined,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final v in [5000, 10000, 25000, 50000])
              ChoicePill(label: fcfa(v), selected: _value == v, onTap: () => setState(() => _amount.text = '$v')),
          ],
        ),
        const SizedBox(height: 14),
        BcField(label: 'Motif (facultatif)', hint: 'Ex. Participation anniversaire', controller: _note),
        const SizedBox(height: 10),
        Text(
          over ? 'Montant supérieur à votre solde (${fcfa(bal)}).' : 'Solde disponible : ${fcfa(bal)} · Sans frais',
          style: TextStyle(
            color: over ? const Color(0xFFB42318) : BC.muted,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        BusyButton(
          busy: _busy,
          icon: Icons.north_east_rounded,
          label: _value > 0 ? 'Envoyer ${fcfa(_value)}' : 'Saisissez un montant',
          onTap: _value > 0 && !over ? _send : null,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- Recevoir

Future<void> showReceiveSheet(BuildContext context) => showBcSheet(
  context,
  title: 'Recevoir de l’argent',
  subtitle: 'Présentez ce QR code ou partagez vos coordonnées.',
  name: 'receive',
  builder: (ctx) {
    const iban = 'TG53 TG005 01234 00048119248 21';
    const phone = '+228 90 12 34 56';
    final text = 'Mes coordonnées BankCards\nTitulaire : $holderName\nIBAN : $iban\nMobile Money : $phone';
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: BC.paper,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: BC.line),
          ),
          child: Column(
            children: [
              const SizedBox(
                width: 180,
                height: 180,
                child: CustomPaint(painter: QrPainter('BANKCARDS-CHAMINADE-4821')),
              ),
              const SizedBox(height: 12),
              const Text(holderName, style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: .6)),
              const SizedBox(height: 2),
              const Text('@chaminade · BankCards', style: TextStyle(color: BC.muted, fontSize: 12.5)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Panel(
          child: Column(
            children: const [InfoRow('IBAN', 'TG53 ··· 9248 21'), InfoRow('Mobile Money', phone, last: true)],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: 'Copier l’IBAN',
                light: true,
                icon: Icons.content_copy_rounded,
                onTap: () async {
                  await Clipboard.setData(const ClipboardData(text: iban));
                  if (ctx.mounted) toast(ctx, 'IBAN copié dans le presse-papiers', icon: Icons.content_copy_rounded);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PrimaryButton(
                label: 'Partager',
                icon: Icons.ios_share_rounded,
                onTap: () => shareOrCopy(ctx, title: 'Mes coordonnées BankCards', text: text),
              ),
            ),
          ],
        ),
      ],
    );
  },
);

/// QR code décoratif déterministe (démo) avec les trois repères d'angle.
class QrPainter extends CustomPainter {
  const QrPainter(this.seed);
  final String seed;
  @override
  void paint(Canvas canvas, Size size) {
    const n = 25;
    final cell = size.width / n;
    final p = Paint()..color = BC.navy;
    final r = math.Random(seed.hashCode);
    bool finder(int x, int y) => (x < 8 && y < 8) || (x > n - 9 && y < 8) || (x < 8 && y > n - 9);
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (finder(x, y)) continue;
        if (r.nextDouble() < .48) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x * cell + .4, y * cell + .4, cell - .8, cell - .8),
              Radius.circular(cell * .25),
            ),
            p,
          );
        }
      }
    }
    void eye(double ox, double oy) {
      final o = Rect.fromLTWH(ox, oy, cell * 7, cell * 7);
      canvas.drawRRect(RRect.fromRectAndRadius(o, Radius.circular(cell * 1.6)), p);
      canvas.drawRRect(
        RRect.fromRectAndRadius(o.deflate(cell), Radius.circular(cell * 1.1)),
        Paint()..color = BC.paper,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(o.deflate(cell * 2), Radius.circular(cell * .8)),
        Paint()..shader = BC.goldGradient.createShader(o.deflate(cell * 2)),
      );
    }

    eye(0, 0);
    eye(size.width - cell * 7, 0);
    eye(0, size.height - cell * 7);
  }

  @override
  bool shouldRepaint(QrPainter old) => old.seed != seed;
}

// ---------------------------------------------------------------- Recharger

Future<void> showTopUpSheet(BuildContext context) => showBcSheet(
  context,
  title: 'Recharger le compte',
  subtitle: 'Les fonds sont disponibles immédiatement.',
  name: 'topup',
  builder: (_) => const _TopUpForm(),
);

class _TopUpForm extends StatefulWidget {
  const _TopUpForm();
  @override
  State<_TopUpForm> createState() => _TopUpFormState();
}

class _TopUpFormState extends State<_TopUpForm> {
  static const _sources = [
    ('Flooz', 'Moov Africa · +228 99 ·· 56', Icons.phone_android_rounded),
    ('T-Money', 'Togocom · +228 90 ·· 56', Icons.smartphone_rounded),
    ('Virement bancaire', 'Depuis un autre compte', Icons.account_balance_outlined),
  ];
  int _src = 0, _amount = 50000;
  bool _busy = false, _done = false;

  Future<void> _go() async {
    setState(() => _busy = true);
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    AppState.addTx(Tx('Recharge ${_sources[_src].$1}', 'À l’instant', _amount, Icons.add_rounded, credit: true));
    setState(() {
      _busy = false;
      _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return SuccessBlock(
        title: '+${fcfa(_amount)}',
        body: 'Recharge via ${_sources[_src].$1} effectuée.\nNouveau solde : ${fcfa(AppState.balance.value)}.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, s) in _sources.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: i == _src ? BC.navy.withValues(alpha: .04) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: i == _src ? BC.gold : BC.line, width: i == _src ? 1.5 : 1),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => _src = i),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      IconBadge(s.$3, gold: i == _src, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(s.$2, style: const TextStyle(color: BC.muted, fontSize: 12.5)),
                          ],
                        ),
                      ),
                      Icon(
                        i == _src ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                        color: i == _src ? BC.goldDeep : BC.muted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        const Text(
          'Montant',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: BC.muted),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final v in [10000, 25000, 50000, 100000, 250000])
              ChoicePill(label: fcfa(v), selected: _amount == v, onTap: () => setState(() => _amount = v)),
          ],
        ),
        const SizedBox(height: 18),
        BusyButton(busy: _busy, icon: Icons.add_card_rounded, label: 'Recharger ${fcfa(_amount)}', onTap: _go),
      ],
    );
  }
}

// ---------------------------------------------------------------- Transactions

Future<void> showTxSheet(BuildContext context, Tx tx) {
  final ref = 'TX-${(tx.title.hashCode.abs() % 900000 + 100000)}';
  return showBcSheet(
    context,
    title: tx.title,
    subtitle: tx.credit ? 'Crédit sur votre compte' : 'Débit · carte Visa Classic ·· 4821',
    name: 'tx',
    builder: (ctx) => Column(
      children: [
        Text(
          '${tx.credit ? '+' : '−'}${fcfa(tx.amount)}',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -.5,
            color: tx.credit ? const Color(0xFF15803D) : BC.ink,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E).withValues(alpha: .12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Effectuée',
            style: TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ),
        const SizedBox(height: 16),
        Panel(
          child: Column(
            children: [
              InfoRow('Date', tx.time),
              InfoRow('Catégorie', tx.credit ? 'Entrée d’argent' : _category(tx.title)),
              InfoRow('Référence', ref),
              const InfoRow('Frais', '0 FCFA', last: true),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: 'Signaler',
                light: true,
                icon: Icons.flag_outlined,
                onTap: () {
                  Navigator.pop(ctx);
                  toast(context, 'Signalement envoyé. Réponse sous 24 h.', icon: Icons.support_agent_rounded);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PrimaryButton(
                label: 'Partager',
                icon: Icons.ios_share_rounded,
                onTap: () => shareOrCopy(
                  ctx,
                  title: 'Opération BankCards',
                  text:
                      'Opération BankCards $ref\n${tx.title} · ${tx.time}\n${tx.credit ? '+' : '-'}${fcfa(tx.amount)}',
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

String _category(String t) {
  if (t.contains('Supermarché')) return 'Courses';
  if (t.contains('Abonnement')) return 'Abonnements';
  if (t.contains('Conversion')) return 'Change';
  if (t.contains('Virement')) return 'Virement';
  return 'Paiement';
}

class TxTile extends StatelessWidget {
  const TxTile({super.key, required this.tx, this.inset = 20});
  final Tx tx;
  final double inset;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showTxSheet(context, tx),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: inset, vertical: 7),
        child: Row(
          children: [
            IconBadge(tx.icon, gold: tx.credit),
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
      ),
    );
  }
}

// ---------------------------------------------------------------- Recherche

Future<void> showSearchSheet(BuildContext context) => showBcSheet(
  context,
  title: 'Rechercher',
  subtitle: 'Opérations, marchands, montants.',
  name: 'search',
  builder: (_) => const _Search(),
);

class _Search extends StatefulWidget {
  const _Search();
  @override
  State<_Search> createState() => _SearchState();
}

class _SearchState extends State<_Search> {
  final _q = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final q = _q.text.toLowerCase().trim();
    final all = AppState.txs.value;
    final res = q.isEmpty
        ? all
        : all.where((t) => t.title.toLowerCase().contains(q) || '${t.amount}'.contains(q)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BcField(
          label: 'Recherche',
          hint: 'Ex. Ramco, Flooz, 15000',
          controller: _q,
          prefix: Icons.search_rounded,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            for (final s in ['Virement', 'Recharge', 'Canal+'])
              ChoicePill(label: s, selected: _q.text == s, onTap: () => setState(() => _q.text = s)),
          ],
        ),
        const SizedBox(height: 8),
        if (res.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: Text('Aucune opération trouvée.', style: TextStyle(color: BC.muted)),
            ),
          )
        else
          for (final t in res) TxTile(tx: t, inset: 0),
      ],
    );
  }
}

// ---------------------------------------------------------------- Avantages

class _Perk {
  const _Perk(this.icon, this.text, this.facts);
  final IconData icon;
  final String text;
  final List<String> facts;
}

const _perks = <String, _Perk>{
  'Paiement sans contact': _Perk(
    Icons.contactless_outlined,
    'Payez d’un simple geste, jusqu’à 50 000 FCFA sans code.',
    [
      'Compatible Apple Pay et Google Pay',
      'Plafond réglable dans les paramètres',
      'Notification instantanée à chaque achat',
    ],
  ),
  'Retraits gratuits': _Perk(Icons.atm_rounded, 'Retirez sans frais dans tout le réseau partenaire.', [
    '8 retraits gratuits par mois',
    'Plus de 1 200 distributeurs en UEMOA',
    'Retrait sans carte par code SMS',
  ]),
  'Assurance voyage': _Perk(
    Icons.flight_takeoff_rounded,
    'Une couverture complète dès que vous payez votre voyage avec la carte.',
    ['Frais médicaux jusqu’à 50 M FCFA', 'Retard de vol et perte de bagages', 'Assistance rapatriement 24/7'],
  ),
  '0 % frais à l\'étranger': _Perk(
    Icons.public_rounded,
    'Aucune commission de change sur vos paiements hors zone FCFA.',
    ['Taux de change en temps réel', 'Valable en ligne et en magasin', 'Retraits à l’étranger : 2 gratuits par mois'],
  ),
  'Cashback 1 %': _Perk(Icons.savings_outlined, '', []),
  'Cashback 2 %': _Perk(Icons.savings_outlined, '', []),
  'Accès salons': _Perk(Icons.weekend_outlined, 'Détendez-vous avant le vol dans plus de 1 300 salons d’aéroport.', [
    '4 accès offerts par an',
    'Salon ASKY à Lomé-Tokoin inclus',
    'Carte d’accès numérique dans l’app',
  ]),
  'Conciergerie 24/7': _Perk(Icons.support_agent_rounded, '', []),
  'Plafonds illimités':
      _Perk(Icons.all_inclusive_rounded, 'Aucun plafond de paiement imposé : vous fixez vos propres limites.', [
        'Validation renforcée au-delà de 5 M FCFA',
        'Retraits jusqu’à 3 M FCFA par semaine',
        'Ajustement instantané depuis l’app',
      ]),
  'Salons VIP monde': _Perk(Icons.diamond_outlined, 'Accès illimité aux salons VIP, pour vous et un invité.', [
    'Plus de 1 300 salons dans 140 pays',
    'Fast-track sécurité dans 60 aéroports',
    'Invité supplémentaire offert',
  ]),
};

IconData perkIcon(String perk) => _perks[perk]?.icon ?? Icons.workspace_premium_outlined;

Future<void> showPerkSheet(BuildContext context, String perk) {
  if (perk.startsWith('Cashback')) return showCashbackSheet(context);
  if (perk.startsWith('Conciergerie')) return showConciergeSheet(context);
  final p = _perks[perk] ?? const _Perk(Icons.workspace_premium_outlined, 'Un avantage inclus avec votre carte.', []);
  return showBcSheet(
    context,
    title: perk,
    subtitle: 'Inclus avec votre carte',
    name: 'perk',
    builder: (ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconBadge(p.icon, gold: true, size: 52),
            const SizedBox(width: 14),
            Expanded(
              child: Text(p.text, style: const TextStyle(fontSize: 14.5, height: 1.45, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (final f in p.facts)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, size: 18, color: BC.gold),
                const SizedBox(width: 10),
                Expanded(child: Text(f, style: const TextStyle(fontSize: 14))),
              ],
            ),
          ),
        const SizedBox(height: 10),
        PrimaryButton(label: 'Compris', onTap: () => Navigator.pop(ctx)),
      ],
    ),
  );
}

// ---------------------------------------------------------------- Cashback

Future<void> showCashbackSheet(BuildContext context) => showBcSheet(
  context,
  title: 'Cashback',
  subtitle: 'Une partie de chaque achat vous revient.',
  name: 'cashback',
  builder: (_) => const _Cashback(),
);

class _Cashback extends StatefulWidget {
  const _Cashback();
  @override
  State<_Cashback> createState() => _CashbackState();
}

class _CashbackState extends State<_Cashback> {
  bool _busy = false;
  Future<void> _transfer() async {
    setState(() => _busy = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final v = AppState.cashback.value;
    AppState.addTx(Tx('Cashback novembre', 'À l’instant', v, Icons.savings_outlined, credit: true));
    AppState.cashback.value = 0;
    setState(() => _busy = false);
    toast(context, '${fcfa(v)} transférés sur votre solde');
  }

  @override
  Widget build(BuildContext context) {
    final v = AppState.cashback.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(colors: [Color(0xFF0E2A63), BC.navy, BC.ink]),
            border: Border.all(color: BC.gold.withValues(alpha: .45)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Disponible ce mois-ci', style: TextStyle(color: Colors.white.withValues(alpha: .65), fontSize: 13)),
              const SizedBox(height: 4),
              Text(
                fcfa(v),
                style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Taux actuel : 2 % · Gagné en 2026 : 164 300 FCFA',
                style: TextStyle(color: BC.goldLight, fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Historique', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 4),
        for (final e in AppState.cashbackHistory)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: BC.line)),
            ),
            child: Row(
              children: [
                const IconBadge(Icons.savings_outlined, gold: true, size: 38),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.merchant, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text('${e.date} · achat ${fcfa(e.spent)}', style: const TextStyle(color: BC.muted, fontSize: 12)),
                    ],
                  ),
                ),
                Text(
                  '+${fcfa(e.earned)}',
                  style: const TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.w800, fontSize: 13.5),
                ),
              ],
            ),
          ),
        const SizedBox(height: 18),
        BusyButton(
          busy: _busy,
          icon: Icons.south_west_rounded,
          label: v > 0 ? 'Transférer ${fcfa(v)} sur mon solde' : 'Cashback déjà transféré',
          onTap: v > 0 ? _transfer : null,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- Conciergerie

Future<void> showConciergeSheet(BuildContext context) => showBcSheet(
  context,
  title: 'Conciergerie 24/7',
  subtitle: 'Un concierge dédié s’occupe de tout, jour et nuit.',
  name: 'concierge',
  builder: (_) => const _Concierge(),
);

class _Concierge extends StatefulWidget {
  const _Concierge();
  @override
  State<_Concierge> createState() => _ConciergeState();
}

class _ConciergeState extends State<_Concierge> {
  static const _kinds = [
    ('Restaurant', Icons.restaurant_rounded),
    ('Voyage', Icons.flight_rounded),
    ('Événement', Icons.confirmation_number_outlined),
    ('Cadeau', Icons.card_giftcard_rounded),
  ];
  int _kind = 0;
  final _when = TextEditingController(text: 'Samedi 28 nov., 20 h');
  final _details = TextEditingController();
  bool _busy = false;
  ConciergeRequest? _sent;

  Future<void> _submit() async {
    setState(() => _busy = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    final r = ConciergeRequest(
      'CG-${2400 + AppState.requests.value.length + 17}',
      _kinds[_kind].$1,
      _when.text,
      _details.text.trim(),
    );
    AppState.requests.value = [r, ...AppState.requests.value];
    setState(() {
      _busy = false;
      _sent = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = _sent;
    if (s != null) {
      return SuccessBlock(
        title: 'Demande ${s.id} reçue',
        body: '${s.kind} · ${s.when}\nVotre concierge Ama vous rappelle sous 15 minutes au +228 90 ·· 56.',
      );
    }
    final ok = _details.text.trim().length >= 4;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: BC.navy,
              child: Text(
                'AK',
                style: TextStyle(color: BC.goldLight, fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ama K., votre concierge', style: TextStyle(fontWeight: FontWeight.w700)),
                  Text(
                    'En ligne · répond en 3 min en moyenne',
                    style: TextStyle(color: Color(0xFF15803D), fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Type de demande',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: BC.muted),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (i, k) in _kinds.indexed)
              ChoicePill(label: k.$1, icon: k.$2, selected: i == _kind, onTap: () => setState(() => _kind = i)),
          ],
        ),
        const SizedBox(height: 14),
        BcField(label: 'Date et heure souhaitées', controller: _when, prefix: Icons.event_outlined),
        const SizedBox(height: 12),
        BcField(
          label: 'Votre demande',
          hint: 'Ex. Une table pour 4 avec vue sur la mer',
          controller: _details,
          maxLines: 3,
          onChanged: (_) => setState(() {}),
        ),
        if (AppState.requests.value.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Demandes en cours : ${AppState.requests.value.map((r) => r.id).join(', ')}',
            style: const TextStyle(color: BC.muted, fontSize: 12.5),
          ),
        ],
        const SizedBox(height: 16),
        BusyButton(
          busy: _busy,
          icon: Icons.send_rounded,
          label: ok ? 'Envoyer la demande' : 'Décrivez votre demande',
          onTap: ok ? _submit : null,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- Adresse

Future<void> showAddressSheet(BuildContext context) => showBcSheet(
  context,
  title: 'Adresse de livraison',
  subtitle: 'Votre carte sera livrée à cette adresse.',
  name: 'address',
  builder: (_) => const _AddressForm(),
);

class _AddressForm extends StatefulWidget {
  const _AddressForm();
  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  late final a = AppState.address.value;
  late final _street = TextEditingController(text: a.street);
  late final _city = TextEditingController(text: a.city);
  late final _country = TextEditingController(text: a.country);
  late final _phone = TextEditingController(text: a.phone);
  late final _note = TextEditingController(text: a.note);

  void _save() {
    AppState.address.value = Address(
      street: _street.text.trim(),
      city: _city.text.trim(),
      country: _country.text.trim(),
      phone: _phone.text.trim(),
      note: _note.text.trim(),
    );
    AppState.save();
    Navigator.pop(context);
    toast(context, 'Adresse mise à jour', icon: Icons.location_on_outlined);
  }

  @override
  Widget build(BuildContext context) {
    final ok = _street.text.trim().isNotEmpty && _city.text.trim().isNotEmpty;
    return Column(
      children: [
        BcField(
          label: 'Quartier, rue',
          controller: _street,
          prefix: Icons.location_on_outlined,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: BcField(label: 'Ville', controller: _city, onChanged: (_) => setState(() {})),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: BcField(label: 'Pays', controller: _country),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BcField(
          label: 'Téléphone du livreur',
          controller: _phone,
          keyboard: TextInputType.phone,
          prefix: Icons.call_outlined,
        ),
        const SizedBox(height: 12),
        BcField(label: 'Consignes (facultatif)', hint: 'Ex. Portail bleu, sonner deux fois', controller: _note),
        const SizedBox(height: 18),
        PrimaryButton(label: 'Enregistrer l’adresse', icon: Icons.check_rounded, onTap: ok ? _save : null),
      ],
    );
  }
}

// ---------------------------------------------------------------- Préférences

Future<void> showLanguageSheet(BuildContext context) => showBcSheet(
  context,
  title: 'Langue',
  name: 'language',
  builder: (ctx) => ValueListenableBuilder(
    valueListenable: AppState.language,
    builder: (_, lang, _) => Column(
      children: [
        for (final (code, label, sub) in [
          ('fr', 'Français', 'Langue actuelle de l’app'),
          ('en', 'English', 'Interface en anglais (bientôt)'),
          ('ee', 'Èʋegbe', 'Ewe, interface en préparation'),
        ])
          MenuTile(
            icon: Icons.translate_rounded,
            title: label,
            subtitle: sub,
            gold: lang == code,
            trailing: Icon(
              lang == code ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: lang == code ? BC.goldDeep : BC.muted,
            ),
            onTap: () {
              AppState.language.value = code;
              AppState.save();
              toast(
                ctx,
                'Langue : $label${code == 'fr' ? '' : ' (enregistrée, traduction à venir)'}',
                icon: Icons.translate_rounded,
              );
            },
          ),
      ],
    ),
  ),
);

Future<void> showSecuritySheet(BuildContext context) => showBcSheet(
  context,
  title: 'Sécurité',
  subtitle: 'Protégez l’accès à votre compte.',
  name: 'security',
  builder: (ctx) => ValueListenableBuilder(
    valueListenable: AppState.security,
    builder: (_, s, _) {
      void set(String k, bool v, String msg) {
        AppState.security.value = {...s, k: v};
        AppState.save();
        toast(ctx, msg, icon: Icons.shield_outlined);
      }

      return Column(
        children: [
          MenuTile(
            icon: Icons.fingerprint_rounded,
            title: 'Face ID / empreinte',
            subtitle: 'Déverrouiller l’app sans mot de passe',
            trailing: BcSwitch(
              value: s['bio']!,
              onChanged: (v) => set('bio', v, v ? 'Biométrie activée' : 'Biométrie désactivée'),
            ),
          ),
          MenuTile(
            icon: Icons.sms_outlined,
            title: 'Code par SMS',
            subtitle: 'Double validation des paiements en ligne',
            trailing: BcSwitch(
              value: s['otp']!,
              onChanged: (v) => set('otp', v, v ? 'Double validation activée' : 'Double validation désactivée'),
            ),
          ),
          MenuTile(
            icon: Icons.notifications_active_outlined,
            title: 'Alertes de connexion',
            subtitle: 'Être prévenu de chaque nouvel appareil',
            trailing: BcSwitch(
              value: s['alerts']!,
              onChanged: (v) => set('alerts', v, v ? 'Alertes activées' : 'Alertes désactivées'),
            ),
          ),
          MenuTile(
            icon: Icons.devices_rounded,
            title: 'Appareils connectés',
            subtitle: 'iPhone 15 · Lomé (cet appareil)',
            onTap: () => toast(ctx, 'Un seul appareil connecté : celui-ci', icon: Icons.devices_rounded),
          ),
        ],
      );
    },
  ),
);

Future<void> showHelpSheet(BuildContext context) => showBcSheet(
  context,
  title: 'Centre d’aide',
  subtitle: 'Les réponses aux questions les plus fréquentes.',
  name: 'help',
  builder: (ctx) => Column(
    children: [
      for (final (q, a) in const [
        (
          'Quand vais-je recevoir ma carte ?',
          'Sous 5 à 7 jours ouvrés. Vous êtes notifié à l’expédition et à la livraison.',
        ),
        ('Comment geler ma carte ?', 'Profil › Paramètres de la carte › Geler la carte. Le dégel est instantané.'),
        ('Mon code PIN est-il visible ?', 'Il est masqué par défaut et ne s’affiche que 5 secondes après validation.'),
        ('Comment contacter un conseiller ?', 'Par la conciergerie 24/7 ou au +228 22 00 00 00.'),
      ])
        Theme(
          data: Theme.of(ctx).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 12),
            iconColor: BC.goldDeep,
            title: Text(q, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(a, style: const TextStyle(color: BC.muted, height: 1.45)),
              ),
            ],
          ),
        ),
      const SizedBox(height: 10),
      PrimaryButton(
        label: 'Parler à un concierge',
        icon: Icons.support_agent_rounded,
        onTap: () {
          Navigator.pop(ctx);
          showConciergeSheet(context);
        },
      ),
    ],
  ),
);
