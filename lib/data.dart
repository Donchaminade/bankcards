import 'package:flutter/material.dart';

enum Network { visa, mastercard }

enum Finish { gloss, metal, black }

class CardType {
  const CardType({
    required this.id,
    required this.name,
    required this.tier,
    required this.network,
    required this.finish,
    required this.colors,
    required this.ink,
    required this.accent,
    required this.price,
    required this.material,
    required this.perks,
    required this.last4,
    this.sparkle = 0.5,
  });

  final String id;
  final String name;
  final String tier;
  final Network network;
  final Finish finish;
  final List<Color> colors;
  final Color ink;
  final Color accent;
  final int price;
  final String material;
  final List<String> perks;
  final String last4;
  final double sparkle;

  /// Numéro masqué : seuls les 4 derniers chiffres (fictifs) sont visibles.
  String get masked => '••••  ••••  ••••  $last4';
  String get networkLabel => network == Network.visa ? 'Visa' : 'Mastercard';
}

const holderName = 'CHAMINADE ADJOLOU';
const holderShort = 'Chaminade';
const expiry = '11/30';

const catalog = <CardType>[
  CardType(
    id: 'classic',
    name: 'Classic',
    tier: 'Classic',
    network: Network.visa,
    finish: Finish.gloss,
    colors: [Color(0xFF0A2A72), Color(0xFF1E4FD8), Color(0xFF4F86FF)],
    ink: Colors.white,
    accent: Color(0xFFF5D77A),
    price: 15000,
    material: 'PVC recyclé',
    perks: ['Paiement sans contact', 'Retraits gratuits'],
    last4: '4821',
    sparkle: .35,
  ),
  CardType(
    id: 'world',
    name: 'World',
    tier: 'World',
    network: Network.mastercard,
    finish: Finish.gloss,
    colors: [Color(0xFF040A1C), Color(0xFF0A1F44), Color(0xFF173A7A)],
    ink: Colors.white,
    accent: Color(0xFFD4AF37),
    price: 35000,
    material: 'Polycarbonate',
    perks: ['Assurance voyage', '0 % frais à l\'étranger'],
    last4: '7305',
    sparkle: .45,
  ),
  CardType(
    id: 'gold',
    name: 'Gold',
    tier: 'Gold',
    network: Network.visa,
    finish: Finish.metal,
    colors: [Color(0xFF9C7A1E), Color(0xFFD4AF37), Color(0xFFF3DC8C), Color(0xFFC59B2E)],
    ink: Color(0xFF2E2106),
    accent: Color(0xFF2E2106),
    price: 60000,
    material: 'Métal doré',
    perks: ['Cashback 1 %', 'Accès salons'],
    last4: '0619',
    sparkle: .9,
  ),
  CardType(
    id: 'platinum',
    name: 'Platinum',
    tier: 'Platinum',
    network: Network.visa,
    finish: Finish.metal,
    colors: [Color(0xFF7E8894), Color(0xFFD9DFE6), Color(0xFFF4F6F8), Color(0xFFA9B3BE)],
    ink: Color(0xFF0A1F44),
    accent: Color(0xFF0A1F44),
    price: 120000,
    material: 'Acier brossé',
    perks: ['Conciergerie 24/7', 'Cashback 2 %'],
    last4: '3390',
    sparkle: .7,
  ),
  CardType(
    id: 'infinite',
    name: 'Infinite',
    tier: 'Infinite',
    network: Network.visa,
    finish: Finish.black,
    colors: [Color(0xFF000000), Color(0xFF14161C), Color(0xFF050608)],
    ink: Color(0xFFF5D77A),
    accent: Color(0xFFD4AF37),
    price: 250000,
    material: 'Métal noir & or',
    perks: ['Plafonds illimités', 'Salons VIP monde'],
    last4: '9001',
    sparkle: 1,
  ),
];

class Tx {
  const Tx(this.title, this.time, this.amount, this.icon, {this.credit = false});
  final String title;
  final String time;
  final int amount;
  final IconData icon;
  final bool credit;
}

const transactions = <Tx>[
  Tx('Virement · Kossi A.', '16:07', 125000, Icons.north_east_rounded),
  Tx('Recharge Flooz', '12:40', 300000, Icons.add_rounded, credit: true),
  Tx('Supermarché Ramco', '10:15', 48500, Icons.shopping_bag_outlined),
  Tx('Conversion EUR → XOF', 'Hier', 65600, Icons.swap_horiz_rounded),
  Tx('Salaire novembre', 'Hier', 850000, Icons.account_balance_outlined, credit: true),
  Tx('Abonnement Canal+', '22 nov.', 15000, Icons.tv_rounded),
];
