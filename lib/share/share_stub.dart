import 'package:share_plus/share_plus.dart';

/// Partage natif (Android / iOS). Renvoie true si partagé, false si annulé, null si indisponible.
Future<bool?> platformShare(String title, String text) async {
  final r = await SharePlus.instance.share(ShareParams(text: text, subject: title, title: title));
  switch (r.status) {
    case ShareResultStatus.success:
      return true;
    case ShareResultStatus.dismissed:
      return false;
    case ShareResultStatus.unavailable:
      return null;
  }
}
