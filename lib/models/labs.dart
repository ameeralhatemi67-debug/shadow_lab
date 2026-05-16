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

  // --- NEW: Separate Mode-Specific Configuration Slots ---
  @HiveField(8)
  int? lightBgColor;
  @HiveField(9)
  int? lightCardColor;
  @HiveField(10)
  int? lightMainTextColor;
  @HiveField(11)
  int? lightSubTextColor;

  @HiveField(12)
  int? darkBgColor;
  @HiveField(13)
  int? darkCardColor;
  @HiveField(14)
  int? darkMainTextColor;
  @HiveField(15)
  int? darkSubTextColor;

  @HiveField(16)
  int? slcColor;
  @HiveField(17)
  int? lightSlcColor;
  @HiveField(18)
  int? darkSlcColor;

  Lab({
    required this.id,
    required this.name,
    this.shadows = const [],
    this.isPinned = false,
    this.backgroundColor, // Defaults to null (Theme fallback)
    this.cardColor, // Defaults to null (Theme fallback)
    this.mainTextColor, // Defaults to null (Theme fallback)
    this.subTextColor, // Defaults to null (Theme fallback)
    this.lightBgColor,
    this.lightCardColor,
    this.lightMainTextColor,
    this.lightSubTextColor,
    this.darkBgColor,
    this.darkCardColor,
    this.darkMainTextColor,
    this.darkSubTextColor,
    this.slcColor,
    this.lightSlcColor,
    this.darkSlcColor,
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
    int? slcColor,
    int? Function()? lightBgColor,
    int? Function()? lightCardColor,
    int? Function()? lightMainTextColor,
    int? Function()? lightSubTextColor,
    int? Function()? darkBgColor,
    int? Function()? darkCardColor,
    int? Function()? darkMainTextColor,
    int? Function()? darkSubTextColor,
    int? Function()? lightSlcColor,
    int? Function()? darkSlcColor,
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
      slcColor: slcColor ?? this.slcColor,
      lightBgColor: lightBgColor != null ? lightBgColor() : this.lightBgColor,
      lightCardColor: lightCardColor != null
          ? lightCardColor()
          : this.lightCardColor,
      lightMainTextColor: lightMainTextColor != null
          ? lightMainTextColor()
          : this.lightMainTextColor,
      lightSubTextColor: lightSubTextColor != null
          ? lightSubTextColor()
          : this.lightSubTextColor,
      darkBgColor: darkBgColor != null ? darkBgColor() : this.darkBgColor,
      darkCardColor: darkCardColor != null
          ? darkCardColor()
          : this.darkCardColor,
      darkMainTextColor: darkMainTextColor != null
          ? darkMainTextColor()
          : this.darkMainTextColor,
      darkSubTextColor: darkSubTextColor != null
          ? darkSubTextColor()
          : this.darkSubTextColor,
      lightSlcColor: lightSlcColor != null
          ? lightSlcColor()
          : this.lightSlcColor,
      darkSlcColor: darkSlcColor != null ? darkSlcColor() : this.darkSlcColor,
    );
  }
}
