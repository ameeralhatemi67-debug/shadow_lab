// lib/utils/color_logic.dart
import 'package:flutter/material.dart';
import 'package:shadow_app/models/labs.dart';
import '../colortheme.dart';

class ColorResolver {
  /// Takes the currently active Lab, the Global Profile, the toggle state,
  /// global Theme colors, and active brightness mode.
  static CustomColors resolve(
    Lab? activeLab,
    Lab? globalProfile,
    bool isGlobalEnabled,
    CustomColors defaultColors,
    bool isDark,
  ) {
    // --- THE MAGIC OVERRIDE ---
    // If Global is ON, read from the global profile. If OFF, read from the active lab.
    final targetLab = isGlobalEnabled ? globalProfile : activeLab;

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
        // NEW: Now dynamically reads the Action Button / Highlighter color!
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
        // NEW: Now dynamically reads the Action Button / Highlighter color!
        slc: targetLab?.lightSlcColor != null
            ? Color(targetLab!.lightSlcColor!)
            : defaultColors.slc,
      );
    }
  }
}
