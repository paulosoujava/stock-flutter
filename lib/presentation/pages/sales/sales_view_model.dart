// sales_view_model.dart
import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/domain/entities/sale/sale.dart';
import 'package:stock/domain/entities/sale/sale_item.dart';
import 'package:stock/domain/usecases/auth/get_current_user_use_case.dart';
import 'package:stock/domain/usecases/products/get_all_products_use_case.dart';
import 'package:stock/domain/usecases/products/update_product.dart';
import 'package:stock/domain/usecases/sales/save_sale_use_case.dart';
import 'package:uuid/uuid.dart';
import 'sales_intent.dart';
import 'sales_state.dart';

@lazySingleton
class SalesViewModel {
  final GetAllProductsUseCase _getAllProductsUseCase;
  final SaveSaleUseCase _saveSaleUseCase;
  final UpdateProduct _updateProductUseCase;
  final GetCurrentUserUseCase _getCurrentUser;
  final Uuid _uuid;

  final _stateController = BehaviorSubject<SalesState>();

  Stream<SalesState> get state => _stateController.stream;

  int get globalDiscount =>
      (_stateController.value as SalesReadyState?)?.globalDiscount ?? 0;

  String get globalDescription =>
      (_stateController.value as SalesReadyState?)?.globalDescription ?? '';

  SalesViewModel(
    this._getAllProductsUseCase,
    this._saveSaleUseCase,
    this._updateProductUseCase,
    this._getCurrentUser,
    this._uuid,
  ) {
    _stateController.add(SalesReadyState());
  }

  void handleIntent(SalesIntent intent) {
    switch (intent) {
      case SelectCustomerIntent():
        _selectCustomer(intent.customer);
      case SearchProductsIntent():
        _searchProducts(intent.query);
      case AddProductToCartIntent():
        _addProductToCart(intent.product, intent.quantity, intent.discount);
      case RemoveProductFromCartIntent():
        _removeProductFromCart(intent.productId);
      case IncrementCartItemIntent():
        _incrementCartItem(intent.productId);
      case DecrementCartItemIntent():
        _decrementCartItem(intent.productId);
      case FinalizeSaleIntent():
        _finalizeSale();
      case SetGlobalDiscountIntent():
        _setGlobalDiscount(intent.discount, intent.description);
    }
  }

  void reset() {
    _stateController.add(SalesReadyState());
  }

  void _selectCustomer(Customer customer) {
    final currentState = _stateController.value;
    if (currentState is SalesReadyState) {
      _stateController.add(currentState.copyWith(selectedCustomer: customer));
    }
  }

  Future<void> _searchProducts(String query) async {
    final currentState = _stateController.value;
    if (currentState is! SalesReadyState) return;

    // LIMPEZA IMEDIATA SE QUERY VAZIA
    if (query.isEmpty) {
      _stateController.add(SalesReadyState(
        selectedCustomer: currentState.selectedCustomer,
        cart: currentState.cart,
        originalProducts: currentState.originalProducts,
        searchResults: [],
        currentSearchQuery: '',
        isSearching: false,
        globalDiscount: currentState.globalDiscount,
        globalDescription: currentState.globalDescription,
      ));
      return;
    }

    // Inicia a busca
    _stateController.add(currentState.copyWith(
      isSearching: true,
      currentSearchQuery: query,
    ));

    try {
      final allProducts = await _getAllProductsUseCase();
      List<Product> results = allProducts.where((product) {
        final searchLower = query.toLowerCase();
        return product.name.toLowerCase().contains(searchLower) ||
            product.id.toLowerCase().contains(searchLower) ||
            product.salePrice.toString().contains(searchLower);
      }).toList();

      // Ajusta estoque com base no carrinho
      for (final cartItem in currentState.cart) {
        final index = results.indexWhere((p) => p.id == cartItem.productId);
        if (index != -1) {
          results[index] = results[index].copyWith(
            stockQuantity: results[index].stockQuantity - cartItem.quantity,
          );
        }
      }

      // Emite o novo estado com resultados
      final newState = currentState.copyWith(
        searchResults: results,
        isSearching: false,
        originalProducts: allProducts,
      );
      _stateController.add(newState);
    } catch (e) {
      _stateController
          .add(SalesErrorState("Erro ao buscar produtos: ${e.toString()}"));
    }
  }

  void _addProductToCart(Product product, int quantity, int discount) {
    final currentState = _stateController.value;
    if (currentState is! SalesReadyState) return;

    final List<SaleItem> updatedCart = List.from(currentState.cart);

    final effectiveDiscount = currentState.globalDiscount > 0 ? 0 : discount;

    final newItem = SaleItem(
      productId: product.id,
      productName: product.name,
      quantity: quantity,
      pricePerUnit: product.salePrice,
      discount: effectiveDiscount,
    );

    final existingIndex =
        updatedCart.indexWhere((item) => item.productId == product.id);

    if (existingIndex != -1) {
      updatedCart[existingIndex] = updatedCart[existingIndex].copyWith(
        quantity: quantity,
        discount: effectiveDiscount,
      );
    } else {
      updatedCart.add(newItem);
    }

    _stateController.add(currentState.copyWith(cart: updatedCart));
    _stateController.add(currentState.copyWith(cart: updatedCart));
  }

  void _removeProductFromCart(String productId) {
    final currentState = _stateController.value;
    if (currentState is! SalesReadyState) return;

    final updatedCart =
        currentState.cart.where((item) => item.productId != productId).toList();
    _stateController.add(currentState.copyWith(cart: updatedCart));
    _searchProducts(currentState.currentSearchQuery);
  }

  void _incrementCartItem(String productId) async {
    final currentState = _stateController.value;
    if (currentState is! SalesReadyState) return;

    final allProducts = await _getAllProductsUseCase();
    final originalProduct = allProducts.firstWhere((p) => p.id == productId);

    final updatedCart = List<SaleItem>.from(currentState.cart);
    final itemIndex =
        updatedCart.indexWhere((item) => item.productId == productId);

    if (itemIndex != -1) {
      final currentItem = updatedCart[itemIndex];
      if (currentItem.quantity < originalProduct.stockQuantity) {
        updatedCart[itemIndex] =
            currentItem.copyWith(quantity: currentItem.quantity + 1);
        _stateController.add(currentState.copyWith(cart: updatedCart));
        _searchProducts(currentState.currentSearchQuery);
      }
    }
  }

  void _decrementCartItem(String productId) {
    final currentState = _stateController.value;
    if (currentState is! SalesReadyState) return;

    final updatedCart = List<SaleItem>.from(currentState.cart);
    final itemIndex =
        updatedCart.indexWhere((item) => item.productId == productId);

    if (itemIndex != -1) {
      final currentItem = updatedCart[itemIndex];
      if (currentItem.quantity > 1) {
        updatedCart[itemIndex] =
            currentItem.copyWith(quantity: currentItem.quantity - 1);
      } else {
        updatedCart.removeAt(itemIndex);
      }
      _stateController.add(currentState.copyWith(cart: updatedCart));
      _searchProducts(currentState.currentSearchQuery);
    }
  }

  void _setGlobalDiscount(int discount, String description) {
    final currentState = _stateController.value;
    if (currentState is SalesReadyState) {
      final updatedCart = currentState.cart.map((item) {
        return item.copyWith(discount: 0); // limpa descontos individuais
      }).toList();

      _stateController.add(currentState.copyWith(
        cart: updatedCart,
        globalDiscount: discount,
        globalDescription: description,
      ));
    }
  }

  Future<void> _finalizeSale() async {
    // 1. PEGA O ESTADO ATUAL
    final currentState = _stateController.value;
    if (currentState is! SalesReadyState) return;

    // 2. VALIDAÇÕES
    if (currentState.selectedCustomer == null || currentState.cart.isEmpty) {
      _stateController.add(SalesErrorState("Selecione cliente e produtos."));
      return;
    }

    final currentUser = _getCurrentUser();
    if (currentUser == null) {
      _stateController.add(SalesErrorState("Vendedor não autenticado."));
      return;
    }

    // 3. EMITE LOADING UMA VEZ SÓ
    _stateController.add(SalesLoadingState());
    // GARANTE QUE O STREAM ATUALIZE
    await Future.microtask(() => null);

    try {
      // 4. ESTOQUE
      final productsInDb = await _getAllProductsUseCase();
      for (final cartItem in currentState.cart) {
        final product = productsInDb.firstWhere((p) => p.id == cartItem.productId);
        if (product.stockQuantity < cartItem.quantity) {
          throw Exception('Estoque insuficiente: ${product.name}');
        }
        await _updateProductUseCase(
          product.copyWith(stockQuantity: product.stockQuantity - cartItem.quantity),
        );
      }

      // 5. TOTAL COM DESCONTO
      final totalWithDiscount = currentState.cartTotal * (1 - currentState.globalDiscount / 100);

      // 6. CRIA VENDA
      final sale = Sale(
        id: _uuid.v4(),
        customerId: currentState.selectedCustomer!.id,
        customerName: currentState.selectedCustomer!.name,
        saleDate: DateTime.now(),
        items: currentState.cart,
        totalAmount: currentState.globalDiscount > 0 ? totalWithDiscount : currentState.cartTotal,
        sellerId: currentUser.uid,
        sellerName: currentUser.displayName ?? 'Vendedor',
        globalDiscount: currentState.globalDiscount,
        globalDescription: currentState.globalDescription,
      );

      // 7. SALVA
      await _saveSaleUseCase(sale);

      // 8. SUCESSO
      _stateController.add(SalesSaleSuccessfulState());
      await Future.delayed(const Duration(milliseconds: 800));
      _stateController.add(SalesReadyState());

    } catch (e) {
      _stateController.add(SalesErrorState(e.toString()));
      await Future.delayed(const Duration(seconds: 3));
      _stateController.add(currentState); // volta ao estado anterior
    }
  }

  @disposeMethod
  void dispose() {
    _stateController.close();
  }
}
