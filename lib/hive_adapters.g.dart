// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class ShadowSettingsAdapter extends TypeAdapter<ShadowSettings> {
  @override
  final typeId = 0;

  @override
  ShadowSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShadowSettings(
      blur: (fields[0] as num).toDouble(),
      distance: (fields[1] as num).toDouble(),
      angle: (fields[2] as num).toDouble(),
      colorValue: (fields[3] as num).toInt(),
      isInset: fields[4] == null ? false : fields[4] as bool,
      size: fields[5] == null ? 0.0 : (fields[5] as num).toDouble(),
      isVisible: fields[6] == null ? true : fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ShadowSettings obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.blur)
      ..writeByte(1)
      ..write(obj.distance)
      ..writeByte(2)
      ..write(obj.angle)
      ..writeByte(3)
      ..write(obj.colorValue)
      ..writeByte(4)
      ..write(obj.isInset)
      ..writeByte(5)
      ..write(obj.size)
      ..writeByte(6)
      ..write(obj.isVisible);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShadowSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ShadowPairAdapter extends TypeAdapter<ShadowPair> {
  @override
  final typeId = 1;

  @override
  ShadowPair read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShadowPair(
      id: fields[0] as String,
      light: fields[1] as ShadowSettings,
      dark: fields[2] as ShadowSettings,
      light2: fields[4] as ShadowSettings,
      dark2: fields[5] as ShadowSettings,
      isLinked: fields[3] == null ? true : fields[3] as bool,
      mainText: fields[6] == null ? "Text" : fields[6] as String,
      subText: fields[7] == null ? "text" : fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ShadowPair obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.light)
      ..writeByte(2)
      ..write(obj.dark)
      ..writeByte(3)
      ..write(obj.isLinked)
      ..writeByte(4)
      ..write(obj.light2)
      ..writeByte(5)
      ..write(obj.dark2)
      ..writeByte(6)
      ..write(obj.mainText)
      ..writeByte(7)
      ..write(obj.subText);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShadowPairAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LabAdapter extends TypeAdapter<Lab> {
  @override
  final typeId = 2;

  @override
  Lab read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Lab(
      id: fields[0] as String,
      name: fields[1] as String,
      shadows: fields[2] == null
          ? const []
          : (fields[2] as List).cast<ShadowPair>(),
      isPinned: fields[3] == null ? false : fields[3] as bool,
      backgroundColor: (fields[4] as num?)?.toInt(),
      cardColor: (fields[5] as num?)?.toInt(),
      mainTextColor: (fields[6] as num?)?.toInt(),
      subTextColor: (fields[7] as num?)?.toInt(),
      lightBgColor: (fields[8] as num?)?.toInt(),
      lightCardColor: (fields[9] as num?)?.toInt(),
      lightMainTextColor: (fields[10] as num?)?.toInt(),
      lightSubTextColor: (fields[11] as num?)?.toInt(),
      darkBgColor: (fields[12] as num?)?.toInt(),
      darkCardColor: (fields[13] as num?)?.toInt(),
      darkMainTextColor: (fields[14] as num?)?.toInt(),
      darkSubTextColor: (fields[15] as num?)?.toInt(),
      slcColor: (fields[16] as num?)?.toInt(),
      lightSlcColor: (fields[17] as num?)?.toInt(),
      darkSlcColor: (fields[18] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Lab obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.shadows)
      ..writeByte(3)
      ..write(obj.isPinned)
      ..writeByte(4)
      ..write(obj.backgroundColor)
      ..writeByte(5)
      ..write(obj.cardColor)
      ..writeByte(6)
      ..write(obj.mainTextColor)
      ..writeByte(7)
      ..write(obj.subTextColor)
      ..writeByte(8)
      ..write(obj.lightBgColor)
      ..writeByte(9)
      ..write(obj.lightCardColor)
      ..writeByte(10)
      ..write(obj.lightMainTextColor)
      ..writeByte(11)
      ..write(obj.lightSubTextColor)
      ..writeByte(12)
      ..write(obj.darkBgColor)
      ..writeByte(13)
      ..write(obj.darkCardColor)
      ..writeByte(14)
      ..write(obj.darkMainTextColor)
      ..writeByte(15)
      ..write(obj.darkSubTextColor)
      ..writeByte(16)
      ..write(obj.slcColor)
      ..writeByte(17)
      ..write(obj.lightSlcColor)
      ..writeByte(18)
      ..write(obj.darkSlcColor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
