// lib/utils/color_logic.dart
import 'package:flutter/material.dart';
import 'package:shadow_app/models/labs.dart';
import '../colortheme.dart';

class ColorResolver {
  /// Takes the currently active Lab and the global Theme colors,
  /// and returns a final set of colors to be used by the UI.
  static CustomColors resolve(Lab? activeLab, CustomColors defaultColors) {
    return CustomColors(
      bgc: activeLab?.backgroundColor != null
          ? Color(activeLab!.backgroundColor!)
          : defaultColors.bgc,

      blc: activeLab?.cardColor != null
          ? Color(activeLab!.cardColor!)
          : defaultColors.blc,

      mtext: activeLab?.mainTextColor != null
          ? Color(activeLab!.mainTextColor!)
          : defaultColors.mtext,

      stext: activeLab?.subTextColor != null
          ? Color(activeLab!.subTextColor!)
          : defaultColors.stext,

      // The highlight color (slc) remains tied to the global theme
      // so we always have a consistent highlight/selection color.
      slc: defaultColors.slc,
    );
  }
}
