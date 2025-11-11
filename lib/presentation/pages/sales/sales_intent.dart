import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/entities/product/product.dart';

abstract class SalesIntent {}

class SelectCustomerIntent extends SalesIntent {final Customer customer;
SelectCustomerIntent(this.customer);
}

class ClearCustomerIntent extends SalesIntent {}

class SearchProductsIntent extends SalesIntent {
  final String query;
  SearchProductsIntent(this.query);
}

class AddProductToCartIntent extends SalesIntent {
  final Product product;
  final int quantity;
  AddProductToCartIntent(this.product, this.quantity);
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
