// sale.dart (nova classe ou atualize se existir)
import 'package:hive/hive.dart';
import 'package:stock/domain/entities/sale/sale_item.dart';

part 'sale.g.dart';

@HiveType(typeId: 5)
class Sale extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final String customerId;
  @HiveField(2) final String customerName;
  @HiveField(3) final DateTime saleDate;
  @HiveField(4) final List<SaleItem> items;
  @HiveField(5) final double totalAmount;
  @HiveField(6) final String sellerId;
  @HiveField(7) final String sellerName;

  // CAMPOS NOVOS: devem ser OPCIONAIS
  @HiveField(8) final int? globalDiscount;
  @HiveField(9) final String? globalDescription;
  @HiveField(10) final bool? isCanceled;
  @HiveField(11) final String? cancelReason;

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
    this.globalDescription,
    this.isCanceled,
    this.cancelReason,
  });

  Sale copyWith({
    String? id,
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
  }) {
    return Sale(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
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
    return 'Sale(id: $id, customer: $customerName, total: $totalAmount, discount: $globalDiscount, desc: "$globalDescription")';
  }
}