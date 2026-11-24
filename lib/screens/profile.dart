import 'package:flutter/material.dart';

import '../data.dart';
import '../demo.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets/kit.dart';
import '../widgets/sparkles.dart';
import '../widgets/ui.dart';
import 'card_settings.dart';
import 'notifications.dart';
import 'sheets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Se déconnecter ?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Vous devrez saisir votre code pour revenir.', style: TextStyle(color: BC.muted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Se déconnecter', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
    toast(context, 'Session de démo : vous restez connecté', icon: Icons.logout_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: BC.paper,
      body: ListView(
        padding: EdgeInsets.only(bottom: safeBottom(context) + 8),
        children: [
          Container(
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
                const Positioned.fill(child: SparkleField(count: 18, seed: 31, maxSize: 6)),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, pad.top + 8, 20, 26),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleIconButton(
                            icon: Icons.chevron_left_rounded,
                            dark: true,
                            onTap: () => Navigator.pop(context),
                            tooltip: 'Retour',
                          ),
                          const Expanded(
                            child: Text(
                              'Profil',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                          ),
                          CircleIconButton(
                            icon: Icons.notifications_none_rounded,
                            dark: true,
                            tooltip: 'Notifications',
                            onTap: () =>
                                Navigator.of(context).push(fadeRoute(const NotificationsScreen(), 'notifications')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(shape: BoxShape.circle, gradient: BC.goldGradient),
                        child: const CircleAvatar(
                          radius: 38,
                          backgroundColor: BC.navy,
                          child: Text(
                            'CA',
                            style: TextStyle(color: BC.goldLight, fontWeight: FontWeight.w800, fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Chaminade Adjolou',
                        style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Client Premium depuis 2021 · Lomé',
                        style: TextStyle(color: Colors.white.withValues(alpha: .6), fontSize: 13),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: BC.gold.withValues(alpha: .6)),
                          color: Colors.white.withValues(alpha: .05),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.workspace_premium_rounded, size: 16, color: BC.goldLight),
                            SizedBox(width: 6),
                            Text(
                              'Statut Gold · 2 450 points',
                              style: TextStyle(color: BC.goldLight, fontWeight: FontWeight.w700, fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Section('Ma carte'),
                Panel(
                  child: Column(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: AppState.frozen,
                        builder: (_, f, _) => MenuTile(
                          icon: Icons.credit_card_rounded,
                          gold: true,
                          title: 'Paramètres de la carte',
                          subtitle: f ? 'Visa Classic ·· 4821 · gelée' : 'Visa Classic ·· 4821 · active',
                          onTap: () =>
                              Navigator.of(context).push(fadeRoute(const CardSettingsScreen(), 'card-settings')),
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: AppState.cashback,
                        builder: (_, v, _) => MenuTile(
                          icon: Icons.savings_outlined,
                          title: 'Cashback',
                          subtitle: '${fcfa(v)} disponibles',
                          onTap: () => showCashbackSheet(context),
                        ),
                      ),
                      MenuTile(
                        icon: Icons.support_agent_rounded,
                        title: 'Conciergerie 24/7',
                        subtitle: 'Restaurants, voyages, événements',
                        onTap: () => showConciergeSheet(context),
                      ),
                    ],
                  ),
                ),
                const _Section('Compte'),
                Panel(
                  child: Column(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: AppState.address,
                        builder: (_, a, _) => MenuTile(
                          icon: Icons.location_on_outlined,
                          title: 'Adresse de livraison',
                          subtitle: a.short,
                          onTap: () => showAddressSheet(context),
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: AppState.notifs,
                        builder: (_, _, _) => MenuTile(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notifications',
                          subtitle: AppState.unread == 0 ? 'Tout est lu' : '${AppState.unread} non lues',
                          onTap: () =>
                              Navigator.of(context).push(fadeRoute(const NotificationsScreen(), 'notifications')),
                        ),
                      ),
                      MenuTile(
                        icon: Icons.shield_outlined,
                        title: 'Sécurité',
                        subtitle: 'Biométrie, double validation',
                        onTap: () => showSecuritySheet(context),
                      ),
                      ValueListenableBuilder(
                        valueListenable: AppState.language,
                        builder: (_, l, _) => MenuTile(
                          icon: Icons.translate_rounded,
                          title: 'Langue',
                          subtitle: {'fr': 'Français', 'en': 'English', 'ee': 'Èʋegbe'}[l],
                          onTap: () => showLanguageSheet(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const _Section('Aide'),
                Panel(
                  child: Column(
                    children: [
                      MenuTile(
                        icon: Icons.help_outline_rounded,
                        title: 'Centre d’aide',
                        subtitle: 'Questions fréquentes',
                        onTap: () => showHelpSheet(context),
                      ),
                      MenuTile(
                        icon: Icons.ios_share_rounded,
                        title: 'Inviter un proche',
                        subtitle: '5 000 FCFA offerts à chacun',
                        onTap: () => shareOrCopy(
                          context,
                          title: 'BankCards',
                          text:
                              'Rejoins-moi sur BankCards avec le code CHAMI5000 : https://bankcards-flutter.vercel.app',
                        ),
                      ),
                      MenuTile(
                        icon: Icons.logout_rounded,
                        danger: true,
                        title: 'Se déconnecter',
                        onTap: () => _logout(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text('BankCards 1.0.1 · $holderName', style: TextStyle(color: BC.muted, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
  );
}
