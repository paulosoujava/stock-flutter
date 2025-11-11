import 'package:hive/hive.dart';
import 'package:stock/domain/entities/sale/sale_item.dart';

part 'sale.g.dart';

@HiveType(typeId: 4) // Use um typeId livre
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
  final String sellerId; // ID do vendedor logado (preparado para o futuro)

  @HiveField(7)
  final String sellerName; // Nome do vendedor logado

  Sale({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.saleDate,
    required this.items,
    required this.totalAmount,
    required this.sellerId,
    required this.sellerName,
  });
}
