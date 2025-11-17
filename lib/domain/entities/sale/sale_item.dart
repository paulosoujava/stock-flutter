// sale_item.dart
import 'package:hive/hive.dart';

part 'sale_item.g.dart';

@HiveType(typeId: 3)
class SaleItem extends HiveObject {
  @HiveField(0) final String productId;
  @HiveField(1) final String productName;
  @HiveField(2) final int quantity;
  @HiveField(3) final double pricePerUnit;

  // MUDE DE int → int?
  @HiveField(4) final int? discount;

  SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.pricePerUnit,
    this.discount,
  });
  double get totalPrice {
    final discountValue = (discount ?? 0) / 100.0;
    final discountedPrice = pricePerUnit * (1 - discountValue);
    return quantity * discountedPrice;
  }
  // Adicione copyWith
  SaleItem copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? pricePerUnit,
    int? discount,
  }) {
    return SaleItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      discount: discount ?? this.discount,
    );
  }
}