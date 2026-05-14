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
