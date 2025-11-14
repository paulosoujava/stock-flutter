// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LiveAdapter extends TypeAdapter<Live> {
  @override
  final int typeId = 11;

  @override
  Live read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Live(
      title: fields[1] as String,
      description: fields[2] as String?,
      startDateTime: fields[3] as DateTime?,
      endDateTime: fields[4] as DateTime?,
    )
      ..id = fields[0] as String
      ..status = fields[5] as LiveStatus
      ..products = (fields[6] as HiveList).castHiveList();
  }

  @override
  void write(BinaryWriter writer, Live obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.startDateTime)
      ..writeByte(4)
      ..write(obj.endDateTime)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.products);
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

class LiveStatusAdapter extends TypeAdapter<LiveStatus> {
  @override
  final int typeId = 10;

  @override
  LiveStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LiveStatus.scheduled;
      case 1:
        return LiveStatus.live;
      case 2:
        return LiveStatus.finished;
      default:
        return LiveStatus.scheduled;
    }
  }

  @override
  void write(BinaryWriter writer, LiveStatus obj) {
    switch (obj) {
      case LiveStatus.scheduled:
        writer.writeByte(0);
        break;
      case LiveStatus.live:
        writer.writeByte(1);
        break;
      case LiveStatus.finished:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiveStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
