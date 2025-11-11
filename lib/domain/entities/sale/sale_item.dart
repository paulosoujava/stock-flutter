import 'package:hive/hive.dart';

part 'sale_item.g.dart';

@HiveType(typeId: 5) // Use um typeId livre
class SaleItem extends HiveObject {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final int quantity;

  @HiveField(3)
  final double pricePerUnit; // Preço no momento da venda

  SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.pricePerUnit,
  });

  double get totalPrice => quantity * pricePerUnit;

  SaleItem copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? pricePerUnit,
  }) {
    return SaleItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
    );
  }
}
