import 'dart:io';

import 'package:bankcards/data.dart';
import 'package:bankcards/main.dart';
import 'package:bankcards/screens/confirm.dart';
import 'package:bankcards/state.dart';
import 'package:bankcards/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> settle(WidgetTester t, [int ms = 1200]) async {
  for (var i = 0; i < ms ~/ 100; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

Future<void> closeSheet(WidgetTester t) async {
  await t.tap(find.byTooltip('Fermer').last);
  await settle(t, 800);
}

Future<void> app(WidgetTester t, Widget home) async {
  t.view.physicalSize = const Size(390, 844);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(home);
  await settle(t, 400);
}

void main() {
  setUpAll(() async {
    Future<void> load(String family, List<String> files) async {
      final l = FontLoader(family);
      for (final f in files) {
        l.addFont(Future.value(ByteData.view(File('assets/fonts/$f').readAsBytesSync().buffer)));
      }
      await l.load();
    }

    await load('Manrope', [
      'Manrope-400.ttf',
      'Manrope-500.ttf',
      'Manrope-600.ttf',
      'Manrope-700.ttf',
      'Manrope-800.ttf',
    ]);
    await load('JetBrainsMono', ['JetBrainsMono-400.ttf', 'JetBrainsMono-700.ttf']);
    await load('Playfair', ['Playfair-Italic.ttf', 'Playfair-700.ttf']);
  });

  testWidgets('accueil : chaque bouton ouvre un écran ou une feuille', (t) async {
    await app(t, const BankCardsApp(chrome: false));
    final b0 = AppState.balance.value;

    // Envoyer : montant rapide puis envoi -> solde débité, transaction ajoutée.
    await t.tap(find.bySemanticsLabel('Envoyer'));
    await settle(t);
    expect(find.text('Envoyer de l’argent'), findsOneWidget);
    await t.tap(find.text('10 000 FCFA'));
    await t.pump();
    await t.tap(find.text('Envoyer 10 000 FCFA'));
    await settle(t, 1600);
    expect(find.text('10 000 FCFA envoyés'), findsOneWidget);
    expect(AppState.balance.value, b0 - 10000);
    await closeSheet(t);

    await t.tap(find.bySemanticsLabel('Recevoir'));
    await settle(t);
    expect(find.text('Copier l’IBAN'), findsOneWidget);
    await closeSheet(t);

    await t.tap(find.bySemanticsLabel('Recharger'));
    await settle(t);
    await t.tap(find.text('Recharger 50 000 FCFA'));
    await settle(t, 1600);
    expect(find.text('+50 000 FCFA'), findsWidgets);
    await closeSheet(t);
    expect(AppState.balance.value, b0 - 10000 + 50000);

    await t.tap(find.bySemanticsLabel('Scanner'));
    await settle(t, 3000);
    expect(find.text('QR code détecté'), findsOneWidget);
    await t.tap(find.text('Payer'));
    await settle(t, 3000);
    expect(AppState.txs.value.first.title, 'Café 228 · Lomé');

    await t.tap(find.byTooltip('Rechercher'));
    await settle(t);
    await t.enterText(find.byType(TextField), 'Ramco');
    await t.pump();
    expect(find.text('Supermarché Ramco'), findsWidgets);
    await closeSheet(t);

    await t.tap(find.byTooltip('Notifications'));
    await settle(t);
    expect(find.text('Votre carte est en préparation'), findsOneWidget);
    await t.tap(find.byTooltip('Tout marquer comme lu'));
    await settle(t, 300);
    expect(AppState.unread, 0);
    await t.tap(find.byTooltip('Retour'));
    await settle(t, 3000);

    await t.tap(find.text('Tout voir'));
    await settle(t);
    expect(find.text('Exporter le relevé'), findsOneWidget);
    await t.tap(find.text('Entrées').last);
    await t.pump();
    await t.tap(find.byTooltip('Retour'));
    await settle(t);

    // Détail d'une transaction.
    await t.tap(find.text('Café 228 · Lomé').first);
    await settle(t);
    expect(find.text('Référence'), findsOneWidget);
    await closeSheet(t);

    await t.tap(find.bySemanticsLabel('Transferts'));
    await settle(t);
    expect(find.text('Envoyer de l’argent'), findsOneWidget);
    await closeSheet(t);
    await settle(t, 3000);
  });

  testWidgets('profil, paramètres de la carte, adresse, PIN', (t) async {
    await app(t, const BankCardsApp(chrome: false));
    await t.tap(find.bySemanticsLabel('Profil'));
    await settle(t);
    expect(find.text('Chaminade Adjolou'), findsOneWidget);

    await t.tap(find.text('Paramètres de la carte'));
    await settle(t);
    await t.tap(find.byType(Switch).first);
    await settle(t, 600);
    expect(AppState.frozen.value, isTrue);
    expect(find.text('Carte gelée'), findsOneWidget);
    await t.tap(find.byType(Switch).first);
    await settle(t, 600);
    expect(AppState.frozen.value, isFalse);
    await t.scrollUntilVisible(find.text('Afficher'), 200, scrollable: find.byType(Scrollable).first);
    await t.tap(find.text('Afficher'));
    await settle(t, 1200);
    expect(find.text('7 3 5 1'), findsOneWidget);
    await settle(t, 5600);
    expect(find.text('• • • •'), findsOneWidget);
    await t.drag(find.byType(ListView).first, const Offset(0, 3000));
    await settle(t, 600);
    await t.tap(find.byTooltip('Retour'));
    await settle(t);

    await t.tap(find.text('Adresse de livraison'));
    await settle(t);
    await t.enterText(find.byType(TextField).first, 'Bè Kpota, rue 112');
    await t.pump();
    await t.tap(find.text('Enregistrer l’adresse'));
    await settle(t);
    expect(AppState.address.value.short, 'Bè Kpota, rue 112 · Lomé, Togo');

    for (final (tile, expected) in [
      ('Cashback', 'Historique'),
      ('Conciergerie 24/7', 'Type de demande'),
      ('Sécurité', 'Face ID / empreinte'),
      ('Langue', 'English'),
      ('Centre d’aide', 'Quand vais-je recevoir ma carte ?'),
    ]) {
      await t.scrollUntilVisible(find.text(tile).first, 200, scrollable: find.byType(Scrollable).first);
      await t.tap(find.text(tile).first);
      await settle(t);
      expect(find.text(expected), findsWidgets, reason: tile);
      await closeSheet(t);
    }
    await settle(t, 3000);
  });

  testWidgets('confirmation : avantages et adresse modifiables', (t) async {
    await app(
      t,
      MaterialApp(
        theme: BC.theme(),
        home: ConfirmScreen(card: catalog[3]),
      ),
    );
    await settle(t, 1000);
    await t.tap(find.bySemanticsLabel('Conciergerie 24/7'));
    await settle(t);
    await t.enterText(find.byType(TextField).last, 'Table pour 4 face à la mer');
    await t.pump();
    await t.tap(find.text('Envoyer la demande'));
    await settle(t, 1600);
    expect(find.textContaining('reçue'), findsOneWidget);
    await closeSheet(t);

    await t.tap(find.bySemanticsLabel('Cashback 2 %'));
    await settle(t);
    await t.scrollUntilVisible(find.textContaining('Transférer'), 200, scrollable: find.byType(Scrollable).last);
    await t.tap(find.textContaining('Transférer'));
    await settle(t, 1400);
    expect(AppState.cashback.value, 0);
    await closeSheet(t);

    await t.tap(find.bySemanticsLabel(RegExp('^Modifier Adresse')));
    await settle(t);
    expect(find.text('Adresse de livraison'), findsOneWidget);
    await closeSheet(t);
    await settle(t, 3000);
  });
}
