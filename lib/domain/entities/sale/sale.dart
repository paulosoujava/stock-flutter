// sale.dart (nova classe ou atualize se existir)
import 'package:hive/hive.dart';
import 'package:stock/domain/entities/sale/delivery_info.dart';
import 'package:stock/domain/entities/sale/sale_item.dart';

part 'sale.g.dart';

@HiveType(typeId: 5)
class Sale extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String customerId;
  @HiveField(2)
  final String customerName;
  @HiveField(3)
  final DateTime saleDate;
  @HiveField(4)
  final List<SaleItem> items;
  @HiveField(5)
  final double totalAmount;
  @HiveField(6)
  final String sellerId;
  @HiveField(7)
  final String sellerName;
  @HiveField(8)
  final int? globalDiscount;
  @HiveField(9)
  final String? globalDescription;
  @HiveField(10)
  final bool? isCanceled;
  @HiveField(11)
  final String? cancelReason;

  @HiveField(12)
  DeliveryInfo? delivery;

  @HiveField(13)
  final String? liveId;

  Sale({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.saleDate,
    required this.items,
    required this.totalAmount,
    required this.sellerId,
    required this.sellerName,
    this.globalDiscount,
    this.delivery,
    this.globalDescription,
    this.isCanceled,
    this.cancelReason,
    this.liveId,
  });

  Sale copyWith({
    String? id,
    String? liveId,
    String? customerId,
    String? customerName,
    DateTime? saleDate,
    List<SaleItem>? items,
    double? totalAmount,
    String? sellerId,
    String? sellerName,
    int? globalDiscount,
    String? globalDescription,
    bool? isCanceled,
    String? cancelReason,
    DeliveryInfo? delivery,
  }) {
    return Sale(
      id: id ?? this.id,
      liveId: liveId ?? this.liveId,
      customerId: customerId ?? this.customerId,
      delivery: delivery ?? this.delivery,
      customerName: customerName ?? this.customerName,
      saleDate: saleDate ?? this.saleDate,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      globalDiscount: globalDiscount ?? this.globalDiscount,
      globalDescription: globalDescription ?? this.globalDescription,
      isCanceled: isCanceled ?? this.isCanceled,
      cancelReason: cancelReason ?? this.cancelReason,
    );
  }

  // Para debug
  @override
  String toString() {
    return 'Sale(id: $id, '
        'liveId: $liveId,'
        'customer: $customerName,'
        ' total: $totalAmount,'
        ' discount: $globalDiscount,'
        ' desc: "$globalDescription'
        ', canceled: $isCanceled,'
        ' cancelReason: $cancelReason'
        ', delivery: $delivery")';
  }
}
