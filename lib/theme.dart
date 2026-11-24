import 'package:flutter/material.dart';

/// Charte BankCards : bleu, blanc, noir, touches dorées.
class BC {
  static const navy = Color(0xFF0A1F44);
  static const blue = Color(0xFF1E4FD8);
  static const sky = Color(0xFF5B8CFF);
  static const ink = Color(0xFF07090F);
  static const black = Color(0xFF0B0D12);
  static const white = Color(0xFFFFFFFF);
  static const paper = Color(0xFFF6F7FB);
  static const line = Color(0xFFE6E9F2);
  static const muted = Color(0xFF8A90A2);
  static const gold = Color(0xFFD4AF37);
  static const goldLight = Color(0xFFF5D77A);
  static const goldDeep = Color(0xFF9C7A1E);
  static const green = Color(0xFF16A34A);

  static const goldGradient = LinearGradient(
    colors: [goldDeep, gold, goldLight, gold],
    stops: [0, .35, .6, 1],
  );

  static ThemeData theme() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Manrope',
      scaffoldBackgroundColor: paper,
      colorScheme: ColorScheme.fromSeed(seedColor: blue, primary: navy, secondary: gold),
      splashFactory: InkSparkle.splashFactory,
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(bodyColor: ink, displayColor: ink, fontFamily: 'Manrope'),
    );
  }
}

const kMono = 'JetBrainsMono';
const kSerif = 'Playfair';

String fcfa(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
    b.write(s[i]);
  }
  return '${b.toString()} FCFA';
}
