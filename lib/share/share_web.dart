import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

/// Web Share API. Renvoie true si partagé, false si annulé, null si l'API est absente.
Future<bool?> platformShare(String title, String text) async {
  final nav = web.window.navigator;
  if (!(nav as JSObject).has('share')) return null;
  try {
    await nav.share(web.ShareData(title: title, text: text)).toDart;
    return true;
  } catch (e) {
    if (e.toString().contains('AbortError')) return false;
    return null;
  }
}
