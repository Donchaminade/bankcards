import 'package:bankcards/data.dart';
import 'package:bankcards/main.dart';
import 'package:bankcards/screens/confirm.dart';
import 'package:bankcards/screens/receipt.dart';
import 'package:bankcards/theme.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> settle(WidgetTester t, [int ms = 1200]) async {
  for (var i = 0; i < ms ~/ 100; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(() async {
    // Charge les vraies polices pour des mesures de texte réalistes.
    Future<void> load(String family, List<String> files) async {
      final l = FontLoader(family);
      for (final f in files) {
        final bytes = File('assets/fonts/$f').readAsBytesSync();
        l.addFont(Future.value(ByteData.view(bytes.buffer)));
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

  test('catalogue : 5 cartes aux finitions et couleurs distinctes', () {
    expect(catalog.length, 5);
    expect(catalog.map((c) => c.id).toSet().length, 5);
    expect(catalog.map((c) => c.colors.first.toARGB32()).toSet().length, 5);
    expect(catalog.where((c) => c.network == Network.mastercard), isNotEmpty);
    expect(catalog.map((c) => c.finish).toSet(), containsAll(Finish.values));
  });

  test('numéros masqués : seuls 4 chiffres fictifs visibles', () {
    for (final c in catalog) {
      expect(c.masked.replaceAll(RegExp(r'[^0-9]'), '').length, 4);
      expect(c.masked.endsWith(c.last4), isTrue);
    }
  });

  testWidgets('accueil → choix de carte → confirmation', (t) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(const BankCardsApp(chrome: false));
    await settle(t, 300);
    expect(find.text('Chaminade'), findsOneWidget);
    expect(find.text('Transactions récentes'), findsOneWidget);

    await t.tap(find.byTooltip('Nouvelle carte'));
    await settle(t);
    expect(find.text('Choisir Visa Classic'), findsOneWidget);
    expect(find.text('1 / 5'), findsOneWidget);

    await t.drag(find.byType(PageView), const Offset(-260, 0));
    await settle(t);
    expect(find.text('Choisir Mastercard World'), findsOneWidget);

    await t.tap(find.text('Choisir Mastercard World'));
    await settle(t);
    expect(find.byType(ConfirmScreen), findsOneWidget);
    expect(find.text('Confirmer la commande'), findsOneWidget);
    expect(find.text('Commander · 35 000 FCFA'), findsOneWidget);
  });

  testWidgets('commande → validée → reçu imprimé avec tampon', (t) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        theme: BC.theme(),
        home: ConfirmScreen(card: catalog[2]),
      ),
    );
    await settle(t, 1000);
    await t.tap(find.text('Commander · 60 000 FCFA'));
    await settle(t, 300);
    expect(find.text('Confirmation de votre paiement…'), findsOneWidget);
    await settle(t, 6000);
    expect(find.text('Commande validée'), findsOneWidget);
    await t.tap(find.text('Voir le reçu'));
    await settle(t, 6000);
    expect(find.byType(ReceiptScreen), findsOneWidget);
    expect(find.text('PAYÉ'), findsOneWidget);
    expect(find.text('Terminé'), findsOneWidget);
  });

  for (final h in [664.0, 844.0]) {
    testWidgets('confirmation 390x${h.toInt()} : CTA visible et contenu défilable jusqu\'en bas', (t) async {
      t.view.physicalSize = Size(390, h);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(
        MaterialApp(
          theme: BC.theme(),
          home: ConfirmScreen(card: catalog[3]),
        ),
      );
      await settle(t, 1200);
      final cta = t.getRect(find.text('Commander · 120 000 FCFA'));
      expect(cta.bottom, lessThan(h - 24), reason: 'le bouton doit rester au-dessus du bas de l\'écran');
      await t.drag(find.byType(SingleChildScrollView), const Offset(0, -800));
      await settle(t, 600);
      final perk = t.getRect(find.text('Cashback 2 %'));
      final bar = t.getRect(find.text('Commander · 120 000 FCFA'));
      expect(perk.bottom, lessThan(bar.top), reason: 'les avantages ne doivent pas être cachés par la barre du bas');
    });
  }
}
