// sales_state.dart
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/domain/entities/sale/sale_item.dart';

abstract class SalesState {}

class SalesInitialState extends SalesState {}

class SalesLoadingState extends SalesState {}

class SalesSaleSuccessfulState extends SalesState {}

class SalesErrorState extends SalesState {
  final String message;
  SalesErrorState(this.message);
}

class SalesReadyState extends SalesState {
  final Customer? selectedCustomer;
  final List<Product> searchResults;
  final String currentSearchQuery;
  final List<SaleItem> cart;
  final bool isSearching;
  final List<Product> originalProducts;
  final int globalDiscount;
  final String globalDescription;

  SalesReadyState({
    this.selectedCustomer,
    this.searchResults = const [],
    this.currentSearchQuery = '',
    this.cart = const [],
    this.isSearching = false,
    this.originalProducts = const [],
    this.globalDiscount = 0,
    this.globalDescription = '',
  });

  double get cartTotal => cart.fold(0.0, (sum, item) => sum + item.totalPrice);

  SalesReadyState copyWith({
    Customer? selectedCustomer,
    List<Product>? searchResults,
    String? currentSearchQuery,
    List<SaleItem>? cart,
    bool? isSearching,
    List<Product>? originalProducts,
    int? globalDiscount,
    String? globalDescription,
  }) {
    return SalesReadyState(
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      searchResults: searchResults ?? this.searchResults,
      currentSearchQuery: currentSearchQuery ?? this.currentSearchQuery,
      cart: cart ?? this.cart,
      isSearching: isSearching ?? this.isSearching,
      originalProducts: originalProducts ?? this.originalProducts,
      globalDiscount: globalDiscount ?? this.globalDiscount,
      globalDescription: globalDescription ?? this.globalDescription,
    );
  }
}