// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleAdapter extends TypeAdapter<Sale> {
  @override
  final int typeId = 5;

  @override
  Sale read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sale(
      id: fields[0] as String,
      customerId: fields[1] as String,
      customerName: fields[2] as String,
      saleDate: fields[3] as DateTime,
      items: (fields[4] as List).cast<SaleItem>(),
      totalAmount: fields[5] as double,
      sellerId: fields[6] as String,
      sellerName: fields[7] as String,
      globalDiscount: fields[8] as int?,
      globalDescription: fields[9] as String?,
      isCanceled: fields[10] as bool?,
      cancelReason: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Sale obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.customerName)
      ..writeByte(3)
      ..write(obj.saleDate)
      ..writeByte(4)
      ..write(obj.items)
      ..writeByte(5)
      ..write(obj.totalAmount)
      ..writeByte(6)
      ..write(obj.sellerId)
      ..writeByte(7)
      ..write(obj.sellerName)
      ..writeByte(8)
      ..write(obj.globalDiscount)
      ..writeByte(9)
      ..write(obj.globalDescription)
      ..writeByte(10)
      ..write(obj.isCanceled)
      ..writeByte(11)
      ..write(obj.cancelReason);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
