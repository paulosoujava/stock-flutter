import 'package:stock/domain/entities/category/category.dart';
import 'package:stock/domain/entities/product/product.dart';

class LowStockInfo {
  final Product product;
  final Category category;
  LowStockInfo(this.product, this.category);
}