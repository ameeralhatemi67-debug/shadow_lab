// lib/models/shadow_pair.dart
import 'package:hive_ce/hive_ce.dart';

@HiveType(typeId: 0)
class ShadowSettings {
  @HiveField(0)
  double blur;

  @HiveField(1)
  double distance;

  @HiveField(2)
  double angle;

  @HiveField(3)
  int colorValue;

  @HiveField(4)
  bool isInset;

  @HiveField(5)
  double size;

  @HiveField(6)
  bool isVisible;

  ShadowSettings({
    required this.blur,
    required this.distance,
    required this.angle,
    required this.colorValue,
    this.isInset = false,
    this.size = 0.0,
    this.isVisible = true,
  });

  ShadowSettings copyWith({
    double? blur,
    double? distance,
    double? angle,
    int? colorValue,
    bool? isInset,
    double? size,
    bool? isVisible,
  }) {
    return ShadowSettings(
      blur: blur ?? this.blur,
      distance: distance ?? this.distance,
      angle: angle ?? this.angle,
      colorValue: colorValue ?? this.colorValue,
      isInset: isInset ?? this.isInset,
      size: size ?? this.size,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

@HiveType(typeId: 1)
class ShadowPair {
  @HiveField(0)
  final String id;

  // --- LAYER 1 ---
  @HiveField(1)
  ShadowSettings light;
  @HiveField(2)
  ShadowSettings dark;

  @HiveField(3)
  bool isLinked;

  // --- LAYER 2 ---
  @HiveField(4)
  ShadowSettings light2;
  @HiveField(5)
  ShadowSettings dark2;

  // --- CONTAINER TEXT ---
  @HiveField(6)
  String mainText;

  @HiveField(7)
  String subText;

  ShadowPair({
    required this.id,
    required this.light,
    required this.dark,
    required this.light2,
    required this.dark2,
    this.isLinked = true,
    this.mainText = "Text", // Default value as requested
    this.subText = "text", // Default value as requested
  });
}
