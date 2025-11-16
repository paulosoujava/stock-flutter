// sale_item.dart
import 'package:hive/hive.dart';

part 'sale_item.g.dart';

@HiveType(typeId: 5)
class SaleItem extends HiveObject {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final int quantity;

  @HiveField(3)
  final double pricePerUnit;

  @HiveField(4)
  final int discount; // desconto individual (%)

  SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.pricePerUnit,
    this.discount = 0,
  });

  double get totalPrice => (quantity * pricePerUnit) * (1 - discount / 100);

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