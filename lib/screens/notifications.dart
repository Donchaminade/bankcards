import 'package:flutter/material.dart';

import '../state.dart';
import '../theme.dart';
import '../widgets/kit.dart';
import '../widgets/ui.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: BC.paper,
      body: ValueListenableBuilder(
        valueListenable: AppState.notifs,
        builder: (_, list, _) => ListView(
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
                    'Notifications',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
                CircleIconButton(
                  icon: Icons.done_all_rounded,
                  tooltip: 'Tout marquer comme lu',
                  onTap: () {
                    final n = AppState.unread;
                    AppState.markAllRead();
                    toast(
                      context,
                      n == 0 ? 'Tout était déjà lu' : '$n notifications marquées comme lues',
                      icon: Icons.done_all_rounded,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              AppState.unread == 0 ? 'Vous êtes à jour.' : '${AppState.unread} nouvelles notifications',
              style: const TextStyle(color: BC.muted, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            for (final n in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: n.read ? Colors.white : BC.navy.withValues(alpha: .04),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(color: n.read ? BC.line : BC.gold.withValues(alpha: .55)),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      n.read = true;
                      AppState.notifs.value = List.of(list);
                      showBcSheet(
                        context,
                        title: n.title,
                        subtitle: n.time,
                        name: 'notif',
                        builder: (ctx) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(n.body, style: const TextStyle(fontSize: 15, height: 1.5)),
                            const SizedBox(height: 18),
                            PrimaryButton(label: 'Compris', onTap: () => Navigator.pop(ctx)),
                          ],
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconBadge(n.icon, gold: !n.read, size: 42),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        n.title,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                                      ),
                                    ),
                                    if (!n.read)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(color: BC.gold, shape: BoxShape.circle),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(n.body, style: const TextStyle(color: BC.muted, fontSize: 13, height: 1.4)),
                                const SizedBox(height: 4),
                                Text(
                                  n.time,
                                  style: const TextStyle(color: BC.muted, fontSize: 11.5, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
