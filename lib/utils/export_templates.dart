// lib/utils/export_templates.dart
import 'package:flutter/services.dart';
import '../models/shadow_pair.dart';
import 'trig_math.dart';

// Call this from your copy button
void copyShadowToClipboard(ShadowPair pair) {
  final code = _generateShadowCode(pair);
  Clipboard.setData(ClipboardData(text: code));
}

String _generateShadowCode(ShadowPair pair) {
  // Convert Angle/Distance to Flutter Offsets
  final lightOffset = getOffsetFromAngle(pair.light.angle, pair.light.distance);
  final darkOffset = getOffsetFromAngle(pair.dark.angle, pair.dark.distance);

  // Check if either brother uses the inset feature
  final requiresPackage = pair.light.isInset || pair.dark.isInset;

  StringBuffer buffer = StringBuffer();

  // 1. Inject the Package Guard Notification if needed
  if (requiresPackage) {
    buffer.writeln("/* NOTE: This shadow uses an inner shadow (inset).");
    buffer.writeln("   Add 'flutter_inset_shadow: ^1.0.8' to pubspec.yaml");
    buffer.writeln(
      "   and import 'package:flutter_inset_shadow/flutter_inset_shadow.dart' as inset; */",
    );
    buffer.writeln();
  }

  // 2. Add Developer Guidance Comments
  buffer.writeln("// Token: ${pair.id} | Linked: ${pair.isLinked}");

  // Helper to get hex string (e.g., 0xFF333333)
  String getHex(int val) =>
      "0x${val.toRadixString(16).padLeft(8, '0').toUpperCase()}";

  // Helper for formatting the BoxShadow prefix
  String boxType = requiresPackage ? 'inset.BoxShadow' : 'BoxShadow';

  // 3. Generate Light Brother (lsh)
  buffer.writeln("static const List<$boxType> lsh_${pair.id} = [");
  buffer.writeln("  $boxType(");
  buffer.writeln("    color: Color(${getHex(pair.light.colorValue)}),");
  buffer.writeln("    blurRadius: ${pair.light.blur.toStringAsFixed(1)},");
  buffer.writeln(
    "    offset: Offset(${lightOffset.dx.toStringAsFixed(2)}, ${lightOffset.dy.toStringAsFixed(2)}),",
  );
  if (pair.light.isInset) buffer.writeln("    inset: true,");
  buffer.writeln("  ),");
  buffer.writeln("];");
  buffer.writeln();

  // 4. Generate Dark Brother (dsh)
  buffer.writeln("static const List<$boxType> dsh_${pair.id} = [");
  buffer.writeln("  $boxType(");
  buffer.writeln("    color: Color(${getHex(pair.dark.colorValue)}),");
  buffer.writeln("    blurRadius: ${pair.dark.blur.toStringAsFixed(1)},");
  buffer.writeln(
    "    offset: Offset(${darkOffset.dx.toStringAsFixed(2)}, ${darkOffset.dy.toStringAsFixed(2)}),",
  );
  if (pair.dark.isInset) buffer.writeln("    inset: true,");
  buffer.writeln("  ),");
  buffer.writeln("];");

  return buffer.toString();
}
