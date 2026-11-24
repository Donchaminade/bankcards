import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';

class Address {
  const Address({required this.street, required this.city, required this.country, required this.phone, this.note = ''});
  final String street, city, country, phone, note;

  String get short => '$street · $city, $country';

  Map<String, String> toJson() => {'street': street, 'city': city, 'country': country, 'phone': phone, 'note': note};
  static Address fromJson(Map<String, dynamic> j) => Address(
    street: j['street'] ?? '',
    city: j['city'] ?? '',
    country: j['country'] ?? '',
    phone: j['phone'] ?? '',
    note: j['note'] ?? '',
  );
}

class Notif {
  Notif(this.title, this.body, this.time, this.icon, {this.read = false});
  final String title, body, time;
  final IconData icon;
  bool read;
}

class ConciergeRequest {
  const ConciergeRequest(this.id, this.kind, this.when, this.details);
  final String id, kind, when, details;
}

class CashbackEntry {
  const CashbackEntry(this.merchant, this.date, this.spent, this.earned);
  final String merchant, date;
  final int spent, earned;
}

/// État de l'app (démo) : solde, transactions, adresse, réglages de la carte.
/// L'adresse et les réglages sont conservés sur l'appareil (shared_preferences).
class AppState {
  static final balance = ValueNotifier<int>(2450000);
  static final txs = ValueNotifier<List<Tx>>(List.of(transactions));
  static final address = ValueNotifier<Address>(
    const Address(street: 'Adidogomé', city: 'Lomé', country: 'Togo', phone: '+228 90 12 34 56'),
  );
  static final frozen = ValueNotifier<bool>(false);
  static final toggles = ValueNotifier<Map<String, bool>>({'contactless': true, 'online': true, 'abroad': false});
  static final payLimit = ValueNotifier<double>(1500000);
  static final cashLimit = ValueNotifier<double>(400000);
  static final cashback = ValueNotifier<int>(18450);
  static final language = ValueNotifier<String>('fr');
  static final security = ValueNotifier<Map<String, bool>>({'bio': true, 'otp': true, 'alerts': true});
  static final requests = ValueNotifier<List<ConciergeRequest>>([]);
  static final notifs = ValueNotifier<List<Notif>>([
    Notif(
      'Votre carte est en préparation',
      'Visa Gold ·· 0619 : expédition prévue sous 48 h.',
      'Il y a 5 min',
      Icons.local_shipping_outlined,
    ),
    Notif('Cashback crédité', '+970 FCFA sur votre achat Supermarché Ramco.', '10:16', Icons.savings_outlined),
    Notif('Nouvelle connexion', 'Connexion depuis un iPhone à Lomé. C’est bien vous ?', '09:02', Icons.shield_outlined),
    Notif('Salaire reçu', '+850 000 FCFA de votre employeur.', 'Hier', Icons.account_balance_outlined, read: true),
    Notif(
      'Relevé de novembre',
      'Votre relevé mensuel est disponible.',
      '22 nov.',
      Icons.description_outlined,
      read: true,
    ),
  ]);

  static const cashbackHistory = <CashbackEntry>[
    CashbackEntry('Supermarché Ramco', "Aujourd'hui", 48500, 970),
    CashbackEntry('Station Total Bè', '23 nov.', 32000, 640),
    CashbackEntry('Café 228', '22 nov.', 7500, 150),
    CashbackEntry('Air Côte d’Ivoire', '18 nov.', 412000, 8240),
    CashbackEntry('Pharmacie du Boulevard', '15 nov.', 18200, 364),
    CashbackEntry('Canal+', '12 nov.', 15000, 300),
    CashbackEntry('Restaurant Le Galion', '9 nov.', 89300, 7786),
  ];

  static int get unread => notifs.value.where((n) => !n.read).length;

  static void markAllRead() {
    for (final n in notifs.value) {
      n.read = true;
    }
    notifs.value = List.of(notifs.value);
  }

  static void addTx(Tx tx) {
    txs.value = [tx, ...txs.value];
    balance.value += tx.credit ? tx.amount : -tx.amount;
  }

  static SharedPreferences? _prefs;

  static Future<void> load() async {
    try {
      final p = _prefs = await SharedPreferences.getInstance();
      final a = p.getString('address');
      if (a != null) address.value = Address.fromJson(jsonDecode(a) as Map<String, dynamic>);
      frozen.value = p.getBool('frozen') ?? frozen.value;
      payLimit.value = p.getDouble('payLimit') ?? payLimit.value;
      cashLimit.value = p.getDouble('cashLimit') ?? cashLimit.value;
      language.value = p.getString('language') ?? language.value;
      final t = p.getString('toggles');
      if (t != null) toggles.value = Map<String, bool>.from(jsonDecode(t) as Map);
      final s = p.getString('security');
      if (s != null) security.value = Map<String, bool>.from(jsonDecode(s) as Map);
    } catch (_) {
      // Pas de stockage disponible (tests) : on garde les valeurs par défaut.
    }
  }

  static void save() {
    final p = _prefs;
    if (p == null) return;
    p.setString('address', jsonEncode(address.value.toJson()));
    p.setBool('frozen', frozen.value);
    p.setDouble('payLimit', payLimit.value);
    p.setDouble('cashLimit', cashLimit.value);
    p.setString('language', language.value);
    p.setString('toggles', jsonEncode(toggles.value));
    p.setString('security', jsonEncode(security.value));
  }
}
