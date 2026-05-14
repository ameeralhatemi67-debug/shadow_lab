// lib/colortheme.dart
import 'package:flutter/material.dart';

@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  final Color? mtext; // Main Text
  final Color? stext; // Secondary Text
  final Color? bgc; // Background Color
  final Color? blc; // Bottom Layer Color
  final Color? slc; // Secondary Layer Color

  const CustomColors({this.mtext, this.stext, this.bgc, this.blc, this.slc});

  @override
  CustomColors copyWith({Color? mtext, Color? stext, Color? bgc, Color? blc}) {
    return CustomColors(
      mtext: mtext ?? this.mtext,
      stext: stext ?? this.stext,
      bgc: bgc ?? this.bgc,
      blc: blc ?? this.blc,
      slc: slc ?? this.slc,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      mtext: Color.lerp(mtext, other.mtext, t),
      stext: Color.lerp(stext, other.stext, t),
      bgc: Color.lerp(bgc, other.bgc, t),
      blc: Color.lerp(blc, other.blc, t),
      slc: Color.lerp(slc, other.slc, t),
    );
  }
}

class AppTheme {
  // --- LIGHT MODE ---
  static final light = ThemeData.light().copyWith(
    scaffoldBackgroundColor: const Color.fromRGBO(242, 242, 242, 1),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromRGBO(242, 242, 242, 1),
      foregroundColor: Color.fromRGBO(13, 13, 13, 1),
      elevation: 0,
    ),
    extensions: <ThemeExtension<dynamic>>[
      const CustomColors(
        mtext: Color.fromRGBO(13, 13, 13, 1),
        stext: Color.fromRGBO(66, 66, 66, 1),
        bgc: Color.fromRGBO(242, 242, 242, 1),
        blc: Color.fromRGBO(229, 229, 229, 1),
        slc: Color.fromARGB(255, 52, 52, 52),
      ),
    ],
  );

  // --- DARK MODE ---
  static final dark = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF0D0D0D),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0D0D0D),
      foregroundColor: Color(0xFFF2F2F2),
      elevation: 0,
    ),
    extensions: <ThemeExtension<dynamic>>[
      const CustomColors(
        mtext: Color(0xFFF2F2F2),
        stext: Color(0xFF666666),
        bgc: Color.fromARGB(255, 20, 20, 20),
        blc: Color(0xFF1A1A1A),
        slc: Color(0xFFCBCBCB),
      ),
    ],
  );
}
