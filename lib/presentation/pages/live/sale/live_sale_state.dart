import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/live/live.dart';
import '../../../../domain/entities/product/product.dart';
import '../../../../domain/entities/customer/customer.dart';

abstract class LiveSaleState {}

class LiveSaleLoading extends LiveSaleState {}

class LiveSaleError extends LiveSaleState {
  final String message;
  LiveSaleError(this.message);
}

class LiveSaleMessage extends LiveSaleLoaded {
  final String message;

  LiveSaleMessage({
    required this.message,
    required LiveSaleLoaded state,
  }) : super(
          live: state.live,
          products: state.products,
          selectedProduct: state.selectedProduct,
          currentCustomers: state.currentCustomers,
          orders: state.orders,
          globalDiscount: state.globalDiscount,
          discountPercent: state.discountPercent, // Revertido
        );
}

class LiveSaleFinished extends LiveSaleState {
  final bool success;
  final bool goalAchieved;

  LiveSaleFinished({required this.success, required this.goalAchieved});
}

class LiveSaleLoaded extends LiveSaleState {
  final Live live;
  final Product? selectedProduct;
  final List<Product> products;
  final List<Customer> currentCustomers;
  final List<LiveOrder> orders;
  final int globalDiscount;
  final int discountPercent; // Revertido para o nome original
  final TextEditingController instagramController;
  final bool clearSelectedProduct;
  final NumberFormat currency; // Adicionado

  LiveSaleLoaded({
    required this.live,
    required this.products,
    this.selectedProduct,
    this.currentCustomers = const [],
    this.orders = const [],
    this.globalDiscount = 0,
    this.discountPercent = 0, // Revertido
    this.clearSelectedProduct = false,
  }) : instagramController = TextEditingController(),
       currency = NumberFormat.simpleCurrency(locale: 'pt_BR'); // Adicionado

  // Adicionado para corrigir erro de compilação
  bool get goalAchieved => live.goalAchieved;

  int get totalItemsSold => orders.fold(0, (sum, order) => sum + order.customers.length);
  double get totalAmount => orders.fold(0.0, (sum, order) => sum + order.total);

  double get totalAmountWithDiscounts {
    return orders.fold(0.0, (sum, order) {
      return sum + order.totalWithGlobalDiscount(globalDiscount);
    });
  }

  LiveSaleLoaded copyWith({
    Live? live,
    Product? selectedProduct,
    bool clearSelectedProduct = false,
    List<Product>? products,
    List<Customer>? currentCustomers,
    List<LiveOrder>? orders,
    int? globalDiscount,
    int? discountPercent, // Revertido
  }) {
    final newState = LiveSaleLoaded(
      live: live ?? this.live,
      selectedProduct: clearSelectedProduct ? null : selectedProduct ?? this.selectedProduct,
      products: products ?? this.products,
      currentCustomers: currentCustomers ?? this.currentCustomers,
      orders: orders ?? this.orders,
      globalDiscount: globalDiscount ?? this.globalDiscount,
      discountPercent: discountPercent ?? this.discountPercent, // Revertido
    );
    newState.instagramController.text = instagramController.text;
    return newState;
  }
}

class LiveOrder {
  final Product product;
  final List<Customer> customers;
  final int discountPercent; // Revertido para o nome original

  LiveOrder({
    required this.product,
    required this.customers,
    this.discountPercent = 0, // Revertido
  });

  double get total => product.salePrice * customers.length;

  double totalWithIndividualDiscount() {
    if (discountPercent == 0) return total;
    return total * (1 - discountPercent / 100);
  }

  double totalWithGlobalDiscount(int globalDiscount) {
    final combinedDiscount = (discountPercent + globalDiscount).clamp(0, 100);
    if (combinedDiscount == 0) return total;
    return total * (1 - combinedDiscount / 100);
  }
}
