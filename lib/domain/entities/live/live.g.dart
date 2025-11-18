// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LiveAdapter extends TypeAdapter<Live> {
  @override
  final int typeId = 50;

  @override
  Live read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Live(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      scheduledDate: fields[3] as DateTime,
      goalAmount: fields[4] as int,
      startDate: fields[5] as DateTime?,
      endDate: fields[6] as DateTime?,
      achievedAmount: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Live obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.scheduledDate)
      ..writeByte(4)
      ..write(obj.goalAmount)
      ..writeByte(5)
      ..write(obj.startDate)
      ..writeByte(6)
      ..write(obj.endDate)
      ..writeByte(7)
      ..write(obj.achievedAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
