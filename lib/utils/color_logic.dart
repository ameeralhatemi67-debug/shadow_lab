// lib/utils/color_logic.dart
import 'package:flutter/material.dart';
import 'package:shadow_app/models/labs.dart';
import '../colortheme.dart';

class ColorResolver {
  /// Resolves colors with Mode-Isolated Global Override tracking and strict safety fallbacks.
  static CustomColors resolve(
    Lab? activeLab,
    List<Lab> allLabs,
    String? globalLightId,
    String? globalDarkId,
    CustomColors defaultColors,
    bool isDark,
  ) {
    try {
      // --- THE MAGIC MODE-ISOLATED OVERRIDE ---
      // Determine the exact source folder for the current mode
      Lab? targetLab = activeLab;

      if (isDark && globalDarkId != null) {
        // If dark mode has a global source, find it. If missing, fallback to active lab.
        targetLab =
            allLabs.where((l) => l.id == globalDarkId).firstOrNull ?? activeLab;
      } else if (!isDark && globalLightId != null) {
        // If light mode has a global source, find it. If missing, fallback to active lab.
        targetLab =
            allLabs.where((l) => l.id == globalLightId).firstOrNull ??
            activeLab;
      }

      // --- DARK MODE COLOR RESOLUTION ---
      if (isDark) {
        return CustomColors(
          bgc: targetLab?.darkBgColor != null
              ? Color(targetLab!.darkBgColor!)
              : defaultColors.bgc,
          blc: targetLab?.darkCardColor != null
              ? Color(targetLab!.darkCardColor!)
              : defaultColors.blc,
          mtext: targetLab?.darkMainTextColor != null
              ? Color(targetLab!.darkMainTextColor!)
              : defaultColors.mtext,
          stext: targetLab?.darkSubTextColor != null
              ? Color(targetLab!.darkSubTextColor!)
              : defaultColors.stext,
          slc: targetLab?.darkSlcColor != null
              ? Color(targetLab!.darkSlcColor!)
              : defaultColors.slc,
        );
      }
      // --- LIGHT MODE COLOR RESOLUTION ---
      else {
        return CustomColors(
          bgc: targetLab?.lightBgColor != null
              ? Color(targetLab!.lightBgColor!)
              : defaultColors.bgc,
          blc: targetLab?.lightCardColor != null
              ? Color(targetLab!.lightCardColor!)
              : defaultColors.blc,
          mtext: targetLab?.lightMainTextColor != null
              ? Color(targetLab!.lightMainTextColor!)
              : defaultColors.mtext,
          stext: targetLab?.lightSubTextColor != null
              ? Color(targetLab!.lightSubTextColor!)
              : defaultColors.stext,
          slc: targetLab?.lightSlcColor != null
              ? Color(targetLab!.lightSlcColor!)
              : defaultColors.slc,
        );
      }
    } catch (e) {
      // --- THE SAFETY NET ---
      // If any database mapping fails, fallback safely to default theme colors
      debugPrint("Color Engine Error: $e");
      return defaultColors;
    }
  }
}
