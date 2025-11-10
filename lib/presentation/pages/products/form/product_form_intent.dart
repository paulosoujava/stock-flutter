// lib/presentation/pages/products/form/product_form_intent.dart
import 'package:stock/domain/entities/product/product.dart';

abstract class ProductFormIntent {}

class SaveProductIntent extends ProductFormIntent {
  final Product product;
  SaveProductIntent(this.product);
}

class UpdateProductIntent extends ProductFormIntent {
  final Product product;
  UpdateProductIntent(this.product);
}
