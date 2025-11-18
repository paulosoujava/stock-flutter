import 'package:hive/hive.dart';

part 'product.g.dart';

/// Representa um produto no sistema de estoque.
@HiveType(typeId: 2) // ID de tipo único para o Hive (Customer=0, Category=1)
class Product  extends HiveObject{
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  /// Preço que a loja paga pelo produto (preço de custo).
  @HiveField(3)
  final double costPrice;

  /// Preço que a loja vende o produto para o cliente (preço de venda).
  @HiveField(4)
  final double salePrice;

  /// Quantidade atual do produto em estoque.
  @HiveField(5)
  final int stockQuantity;

  /// Nível de estoque que dispara um alerta de "baixo estoque".
  @HiveField(6)
  final int lowStockThreshold;

  /// ID da Categoria à qual este produto pertence.
  @HiveField(7)
  final String categoryId;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.costPrice,
    required this.salePrice,
    required this.stockQuantity,
    required this.lowStockThreshold,
    required this.categoryId,
  });

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? costPrice,
    double? salePrice,
    int? stockQuantity,
    int? lowStockThreshold,
    String? categoryId,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      costPrice: costPrice ?? this.costPrice,
      salePrice: salePrice ?? this.salePrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  static Future<dynamic> get(String productId) async {}
}
