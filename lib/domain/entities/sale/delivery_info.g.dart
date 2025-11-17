// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeliveryInfoAdapter extends TypeAdapter<DeliveryInfo> {
  @override
  final int typeId = 32;

  @override
  DeliveryInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeliveryInfo(
      method: fields[0] as String,
      customMethod: fields[1] as String?,
      addressId: fields[2] as String?,
      status: fields[3] as String,
      dispatchDate: fields[4] as DateTime?,
      returnReason: fields[5] as String?,
      courierName: fields[6] as String?,
      courierNotes: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DeliveryInfo obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.method)
      ..writeByte(1)
      ..write(obj.customMethod)
      ..writeByte(2)
      ..write(obj.addressId)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.dispatchDate)
      ..writeByte(5)
      ..write(obj.returnReason)
      ..writeByte(6)
      ..write(obj.courierName)
      ..writeByte(7)
      ..write(obj.courierNotes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
