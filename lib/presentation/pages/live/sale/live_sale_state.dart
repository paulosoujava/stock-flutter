// presentation/viewmodels/live/sale/live_sale_state.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/entities/live/live.dart';
import 'package:stock/domain/entities/product/product.dart';

abstract class LiveSaleState {}

class LiveSaleLoading extends LiveSaleState {}

class LiveSaleError extends LiveSaleState {
  final String message;

  LiveSaleError(this.message);
}

class LiveSaleLoaded extends LiveSaleState {
  final Live live;
  final List<Product> products;
  final Product? selectedProduct;
  final List<Customer> currentCustomers;
  final List<LiveOrder> orders;
  final int globalDiscount;
  final int individualDiscount;
  final TextEditingController instagramController = TextEditingController();
  final NumberFormat currency =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  double get progress =>
      live.achievedAmount / live.goalAmount.clamp(1, double.infinity);

  bool get goalAchieved {
    final currentTotalCents = live.achievedAmount +
        (orders.fold<int>(0, (sum, o) => sum + (o.totalWithGlobalDiscount(globalDiscount) * 100).toInt()));
    return currentTotalCents >= live.goalAmount;
  }

  String get formattedAchieved => currency.format(live.achievedAmount / 100);

  String get formattedSessionTotal => currency.format(_sessionTotal);

  double get _sessionTotal => orders.fold(
      0.0, (sum, o) => sum + o.totalWithGlobalDiscount(globalDiscount));

  LiveSaleLoaded({
    required this.live,
    required this.products,
    this.selectedProduct,
    this.currentCustomers = const [],
    this.orders = const [],
    this.globalDiscount = 0,
    this.individualDiscount = 0,
  });


  LiveSaleLoaded copyWith({
    Live? live,
    List<Product>? products,
    Product? selectedProduct,
    bool clearSelectedProduct = false,
    List<Customer>? currentCustomers,
    List<LiveOrder>? orders,
    int? individualDiscount,
    int? globalDiscount,
  }) {
    return LiveSaleLoaded(
      live: live ?? this.live,
      products: products ?? this.products,
      selectedProduct: clearSelectedProduct ? null : (selectedProduct ?? this.selectedProduct),
      currentCustomers: currentCustomers ?? this.currentCustomers,
      orders: orders ?? this.orders,
      globalDiscount: globalDiscount ?? this.globalDiscount,
      individualDiscount: individualDiscount  ?? this.individualDiscount,
    );
  }
}

class LiveOrder {
  final Product product;
  final List<Customer> customers;
  final int individualDiscount;

  LiveOrder(
      {required this.product,
      required this.customers,
      this.individualDiscount = 0});

  int get discountPercent => individualDiscount;

  double get total {
    final disc = (individualDiscount + 0) / 100;
    return product.salePrice * customers.length * (1 - disc);
  }

  double totalWithGlobalDiscount(int globalDiscount) {
    final totalDiscount = individualDiscount + globalDiscount;
    return product.salePrice * customers.length * (1 - totalDiscount / 100);
  }
}

class LiveSaleFinished extends LiveSaleState {
  final bool success;
  final bool goalAchieved;

  LiveSaleFinished({required this.success, required this.goalAchieved});
}
