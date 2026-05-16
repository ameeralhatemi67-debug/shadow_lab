// lib/utils/export_templates.dart
import '../models/shadow_pair.dart';
import 'trig_math.dart';

class ExportTemplates {
  /// Generates the fully commented Flutter/CSS code for the clipboard
  static String generateFlutterCode(ShadowPair pair) {
    // Convert Angle/Distance to Flutter Offsets for both layers
    final lightOffset1 = getOffsetFromAngle(
      pair.light.angle,
      pair.light.distance,
    );
    final darkOffset1 = getOffsetFromAngle(pair.dark.angle, pair.dark.distance);

    final lightOffset2 = getOffsetFromAngle(
      pair.light2.angle,
      pair.light2.distance,
    );
    final darkOffset2 = getOffsetFromAngle(
      pair.dark2.angle,
      pair.dark2.distance,
    );

    // Check if ANY layer uses the inset feature
    final requiresPackage =
        pair.light.isInset ||
        pair.dark.isInset ||
        pair.light2.isInset ||
        pair.dark2.isInset;

    StringBuffer buffer = StringBuffer();

    // =========================================================================
    // 1. GENERATE THE INSTRUCTION & GUIDANCE HEADER
    // =========================================================================
    buffer.writeln(
      "/* ==========================================================",
    );
    buffer.writeln(" * SHADOW LAB EXPORT: ${pair.id}");
    buffer.writeln(
      " * ==========================================================",
    );
    buffer.writeln(" *");
    buffer.writeln(" * 🛠️ HOW TO INTEGRATE THIS SHADOW:");
    buffer.writeln(
      " * 1. Copy this code into your Flutter theme or constants file.",
    );
    buffer.writeln(" * 2. Apply it to a container's decoration like this:");
    buffer.writeln(" * Container(");
    buffer.writeln(" * decoration: BoxDecoration(");
    buffer.writeln(
      " * // Swap between lsh (light) and dsh (dark) based on theme",
    );
    buffer.writeln(
      " * boxShadow: isDarkMode ? dsh_${pair.id.replaceAll(' ', '_')} : lsh_${pair.id.replaceAll(' ', '_')},",
    );
    buffer.writeln(" * ),");
    buffer.writeln(" * )");
    buffer.writeln(" *");
    buffer.writeln(" * 🎨 HOW TO EDIT IN CODE:");
    buffer.writeln(
      " * - Angle & Distance : Handled by 'Offset(X, Y)'. Tweak these numbers to move the shadow's direction.",
    );
    buffer.writeln(
      " * - Blur             : Change 'blurRadius' to make it softer or sharper.",
    );
    buffer.writeln(
      " * - Size             : Change 'spreadRadius' to make the shadow grow or shrink.",
    );
    buffer.writeln(
      " * - Color & Opacity  : Change 'Color(0x...)' to adjust the hue and transparency.",
    );
    buffer.writeln(" *");

    if (requiresPackage) {
      buffer.writeln(" * 📦 REQUIRED PACKAGE (INNER SHADOWS DETECTED):");
      buffer.writeln(
        " * This shadow uses 'inset: true'. Flutter doesn't support this natively yet.",
      );
      buffer.writeln(
        " * 1. Add this to your pubspec.yaml ->  flutter_inset_shadow: ^1.0.8",
      );
      buffer.writeln(
        " * 2. Add this import ->  import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset;",
      );
      buffer.writeln(
        " * 3. Change your Container's 'BoxDecoration' to 'inset.BoxDecoration'.",
      );
      buffer.writeln(" *");
    }
    buffer.writeln(
      " * ========================================================== */",
    );
    buffer.writeln();

    // =========================================================================
    // 2. GENERATE THE FLUTTER CODE
    // =========================================================================

    // Helper to get hex string (e.g., 0xFF333333)
    String getHex(int val) =>
        "0x${val.toRadixString(16).padLeft(8, '0').toUpperCase()}";

    // Helper for formatting the BoxShadow prefix
    String boxType = requiresPackage ? 'inset.BoxShadow' : 'BoxShadow';
    String safeId = pair.id.replaceAll(
      ' ',
      '_',
    ); // Ensures variable name is valid in dart

    // --- Generate Light Brother (lsh) ---
    buffer.writeln("static const List<$boxType> lsh_$safeId = [");

    // Layer 1
    if (pair.light.isVisible) {
      buffer.writeln("  $boxType(");
      buffer.writeln("    color: Color(${getHex(pair.light.colorValue)}),");
      buffer.writeln("    blurRadius: ${pair.light.blur.toStringAsFixed(1)},");
      buffer.writeln(
        "    spreadRadius: ${pair.light.size.toStringAsFixed(1)},",
      );
      buffer.writeln(
        "    offset: Offset(${lightOffset1.dx.toStringAsFixed(2)}, ${lightOffset1.dy.toStringAsFixed(2)}),",
      );
      if (pair.light.isInset) buffer.writeln("    inset: true,");
      buffer.writeln("  ),");
    }

    // Layer 2
    if (pair.light2.isVisible) {
      buffer.writeln("  $boxType(");
      buffer.writeln("    color: Color(${getHex(pair.light2.colorValue)}),");
      buffer.writeln("    blurRadius: ${pair.light2.blur.toStringAsFixed(1)},");
      buffer.writeln(
        "    spreadRadius: ${pair.light2.size.toStringAsFixed(1)},",
      );
      buffer.writeln(
        "    offset: Offset(${lightOffset2.dx.toStringAsFixed(2)}, ${lightOffset2.dy.toStringAsFixed(2)}),",
      );
      if (pair.light2.isInset) buffer.writeln("    inset: true,");
      buffer.writeln("  ),");
    }
    buffer.writeln("];");
    buffer.writeln();

    // --- Generate Dark Brother (dsh) ---
    buffer.writeln("static const List<$boxType> dsh_$safeId = [");

    // Layer 1
    if (pair.dark.isVisible) {
      buffer.writeln("  $boxType(");
      buffer.writeln("    color: Color(${getHex(pair.dark.colorValue)}),");
      buffer.writeln("    blurRadius: ${pair.dark.blur.toStringAsFixed(1)},");
      buffer.writeln("    spreadRadius: ${pair.dark.size.toStringAsFixed(1)},");
      buffer.writeln(
        "    offset: Offset(${darkOffset1.dx.toStringAsFixed(2)}, ${darkOffset1.dy.toStringAsFixed(2)}),",
      );
      if (pair.dark.isInset) buffer.writeln("    inset: true,");
      buffer.writeln("  ),");
    }

    // Layer 2
    if (pair.dark2.isVisible) {
      buffer.writeln("  $boxType(");
      buffer.writeln("    color: Color(${getHex(pair.dark2.colorValue)}),");
      buffer.writeln("    blurRadius: ${pair.dark2.blur.toStringAsFixed(1)},");
      buffer.writeln(
        "    spreadRadius: ${pair.dark2.size.toStringAsFixed(1)},",
      );
      buffer.writeln(
        "    offset: Offset(${darkOffset2.dx.toStringAsFixed(2)}, ${darkOffset2.dy.toStringAsFixed(2)}),",
      );
      if (pair.dark2.isInset) buffer.writeln("    inset: true,");
      buffer.writeln("  ),");
    }
    buffer.writeln("];");

    return buffer.toString();
  }
}
