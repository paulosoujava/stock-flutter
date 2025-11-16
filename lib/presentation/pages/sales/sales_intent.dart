// sales_intent.dart
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/entities/product/product.dart';

abstract class SalesIntent {}

class SelectCustomerIntent extends SalesIntent {
  final Customer customer;
  SelectCustomerIntent(this.customer);
}

class SearchProductsIntent extends SalesIntent {
  final String query;
  SearchProductsIntent(this.query);
}

class AddProductToCartIntent extends SalesIntent {
  final Product product;
  final int quantity;
  final int discount;
  AddProductToCartIntent(this.product, this.quantity, this.discount);
}

class RemoveProductFromCartIntent extends SalesIntent {
  final String productId;
  RemoveProductFromCartIntent(this.productId);
}

class FinalizeSaleIntent extends SalesIntent {}

class IncrementCartItemIntent extends SalesIntent {
  final String productId;
  IncrementCartItemIntent(this.productId);
}

class DecrementCartItemIntent extends SalesIntent {
  final String productId;
  DecrementCartItemIntent(this.productId);
}

class SetGlobalDiscountIntent extends SalesIntent {
  final int discount;
  final String description;
  SetGlobalDiscountIntent(this.discount, this.description);
}