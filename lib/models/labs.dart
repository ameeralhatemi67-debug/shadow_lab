// lib/models/lab.dart
import 'package:hive_ce/hive_ce.dart';
import 'shadow_pair.dart';

@HiveType(typeId: 2)
class Lab {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<ShadowPair> shadows;

  @HiveField(3)
  bool isPinned;

  // --- NEW: Nullable Colors ---
  // If null, the app will use colortheme.dart (colors.bgc, colors.blc, etc.)
  @HiveField(4)
  int? backgroundColor;

  @HiveField(5)
  int? cardColor;

  @HiveField(6)
  int? mainTextColor;

  @HiveField(7)
  int? subTextColor;

  Lab({
    required this.id,
    required this.name,
    this.shadows = const [],
    this.isPinned = false,
    this.backgroundColor, // Defaults to null (Theme fallback)
    this.cardColor, // Defaults to null (Theme fallback)
    this.mainTextColor, // Defaults to null (Theme fallback)
    this.subTextColor, // Defaults to null (Theme fallback)
  });

  Lab copyWith({
    String? id,
    String? name,
    List<ShadowPair>? shadows,
    bool? isPinned,
    int? backgroundColor,
    int? cardColor,
    int? mainTextColor,
    int? subTextColor,
  }) {
    return Lab(
      id: id ?? this.id,
      name: name ?? this.name,
      shadows: shadows ?? this.shadows,
      isPinned: isPinned ?? this.isPinned,
      // If a new color is passed, use it. Otherwise, keep the current state (custom or null).
      backgroundColor: backgroundColor ?? this.backgroundColor,
      cardColor: cardColor ?? this.cardColor,
      mainTextColor: mainTextColor ?? this.mainTextColor,
      subTextColor: subTextColor ?? this.subTextColor,
    );
  }
}
