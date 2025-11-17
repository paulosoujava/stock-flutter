import 'package:hive/hive.dart';

part 'delivery_info.g.dart';

@HiveType(typeId: 32)
class DeliveryInfo extends HiveObject {
  @HiveField(0)
  final String method;

  @HiveField(1)
  final String? customMethod;

  @HiveField(2)
  final String? addressId;

  @HiveField(3)
  final String status;

  @HiveField(4)
  final DateTime? dispatchDate;

  @HiveField(5)
  final String? returnReason;

  @HiveField(6)
  final String? courierName;

  @HiveField(7)
  final String? courierNotes;

  DeliveryInfo({
    required this.method,
    this.customMethod,
    this.addressId,
    required this.status,
    this.dispatchDate,
    this.returnReason,
    this.courierName,
    this.courierNotes,
  });
}
