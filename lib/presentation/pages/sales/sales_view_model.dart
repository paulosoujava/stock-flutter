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
      case ClearCustomerIntent():
        _clearCustomer();
      case SearchProductsIntent():
        _searchProducts(intent.query);
      case AddProductToCartIntent():
        _addProductToCart(intent.product, intent.quantity);
      case RemoveProductFromCartIntent():
        _removeProductFromCart(intent.productId);
      case IncrementCartItemIntent():
        _incrementCartItem(intent.productId);
      case DecrementCartItemIntent():
        _decrementCartItem(intent.productId);
      case FinalizeSaleIntent():
        _finalizeSale();
    }
  }

  void _incrementCartItem(String productId) async {
    final currentState = _stateController.value;
    if (currentState is! SalesReadyState) return;

    // Precisamos do produto original para saber o estoque máximo
    final allProducts = await _getAllProductsUseCase();
    final originalProduct = allProducts.firstWhere((p) => p.id == productId);

    final updatedCart = List<SaleItem>.from(currentState.cart);
    final itemIndex =
        updatedCart.indexWhere((item) => item.productId == productId);

    if (itemIndex != -1) {
      final currentItem = updatedCart[itemIndex];
      // Só incrementa se a nova quantidade não exceder o estoque
      if (currentItem.quantity < originalProduct.stockQuantity) {
        updatedCart[itemIndex] =
            currentItem.copyWith(quantity: currentItem.quantity + 1);
        _stateController.add(currentState.copyWith(cart: updatedCart));
        _searchProducts(currentState.currentSearchQuery); // Atualiza a busca
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
      // Se a quantidade for maior que 1, apenas decrementa
      if (currentItem.quantity > 1) {
        updatedCart[itemIndex] =
            currentItem.copyWith(quantity: currentItem.quantity - 1);
      } else {
        // Se for 1, remove o item do carrinho
        updatedCart.removeAt(itemIndex);
      }
      _stateController.add(currentState.copyWith(cart: updatedCart));
      _searchProducts(currentState.currentSearchQuery); // Atualiza a busca
    }
  }

  void _selectCustomer(Customer customer) {
    final currentState = _stateController.value;
    if (currentState is SalesReadyState) {
      _stateController.add(currentState.copyWith(selectedCustomer: customer));
    }
  }

  void _clearCustomer() {
    _stateController.add(SalesReadyState());
  }

  Future<void> _searchProducts(String query) async {
    final currentState = _stateController.value;
    if (currentState is! SalesReadyState) return;

    _stateController.add(currentState.copyWith(
      isSearching: true,
      currentSearchQuery: query,
    ));

    if (query.isEmpty) {
      _stateController.add(currentState.copyWith(
        searchResults: [],
        isSearching: false,
      ));
      return;
    }

    try {
      final allProducts = await _getAllProductsUseCase();
      final lowerCaseQuery = query.toLowerCase();

      var results = allProducts.where((product) {
        return product.name.toLowerCase().contains(lowerCaseQuery) ||
            product.id.toLowerCase().contains(lowerCaseQuery) ||
            product.salePrice.toString().contains(lowerCaseQuery);
      }).toList();

      final cart = currentState.cart;
      results = results.map((product) {
        final itemInCart = cart.where((item) => item.productId == product.id);
        if (itemInCart.isNotEmpty) {
          final quantityInCart = itemInCart.first.quantity;
          // Retorna uma cópia do produto com o estoque restante real
          return product.copyWith(
              stockQuantity: product.stockQuantity - quantityInCart);
        }
        // Se não está no carrinho, retorna o produto como está
        return product;
      }).toList();

      final newState = _stateController.value;
      if (newState is SalesReadyState) {
        _stateController.add(newState.copyWith(
          searchResults: results,
          isSearching: false,
          originalProducts: allProducts,
        ));
      }
    } catch (e) {
      _stateController
          .add(SalesErrorState("Erro ao buscar produtos: ${e.toString()}"));
    }
  }

  void _addProductToCart(Product product, int quantity) {
    final currentState = _stateController.value;
    if (currentState is! SalesReadyState) return;

    final List<SaleItem> updatedCart = List.from(currentState.cart);

    // O preço de venda é o do produto original, não o do produto "ajustado" da busca.
    final newItem = SaleItem(
      productId: product.id,
      productName: product.name,
      quantity: quantity,
      pricePerUnit: product.salePrice,
    );

    final existingIndex =
        updatedCart.indexWhere((item) => item.productId == product.id);

    if (existingIndex != -1) {
      // Se o item já existe, apenas atualiza a quantidade
      updatedCart[existingIndex] =
          updatedCart[existingIndex].copyWith(quantity: quantity);
    } else {
      updatedCart.add(newItem);
    }

    // Emite o novo estado com o carrinho atualizado
    _stateController.add(currentState.copyWith(cart: updatedCart));

    _searchProducts(currentState.currentSearchQuery);
  }

  void _removeProductFromCart(String productId) {
    final currentState = _stateController.value;
    if (currentState is! SalesReadyState) return;

    final updatedCart =
        currentState.cart.where((item) => item.productId != productId).toList();
    _stateController.add(currentState.copyWith(cart: updatedCart));
    _searchProducts(currentState.currentSearchQuery);
  }

  Future<void> _finalizeSale() async {
    final currentState = _stateController.value;
    if (currentState is! SalesReadyState) return;
    if (currentState.selectedCustomer == null || currentState.cart.isEmpty) {
      _stateController.add(SalesErrorState(
          "Selecione um cliente e adicione produtos ao carrinho."));
      await Future.delayed(const Duration(seconds: 2));
      _stateController.add(currentState);
      return;
    }
    // PEGAR O USUÁRIO
    final currentUser = _getCurrentUser();
    if (currentUser == null) {
      _stateController.add(SalesErrorState("Erro: Nenhum vendedor autenticado. Faça login novamente."));
        return;
    }
    _stateController.add(SalesLoadingState());

    try {
      //  Busca os produtos do banco de dados para garantir o estoque real
      final productsInDb = await _getAllProductsUseCase();

      //  Itera sobre cada item do carrinho para validar estoque e preparar atualização
      for (final cartItem in currentState.cart) {
        final productToUpdate =
            productsInDb.firstWhere((p) => p.id == cartItem.productId);

        if (productToUpdate.stockQuantity < cartItem.quantity) {
          throw Exception(
              'Estoque de "${productToUpdate.name}" é insuficiente. Restam: ${productToUpdate.stockQuantity}');
        }

        final newStock = productToUpdate.stockQuantity - cartItem.quantity;

        //  ATUALIZA O ESTOQUE DO PRODUTO USANDO O USECASE EXISTENTE
        await _updateProductUseCase(
            productToUpdate.copyWith(stockQuantity: newStock));
      }

      //  Se tudo deu certo, cria e salva o registro da venda
      final newSale = Sale(
        id: _uuid.v4(),
        customerId: currentState.selectedCustomer!.id,
        customerName: currentState.selectedCustomer!.name,
        saleDate: DateTime.now(),
        items: currentState.cart,
        totalAmount: currentState.cartTotal,
        sellerId: currentUser.uid,
        sellerName: currentUser.displayName ?? currentUser.email ?? 'Vendedor Desconhecido',
      );

      await _saveSaleUseCase(newSale);

      //  Sucesso
      _stateController.add(SalesSaleSuccessfulState());
      await Future.delayed(const Duration(milliseconds: 500));
      _stateController.add(SalesReadyState());
    } catch (e) {
      _stateController
          .add(SalesErrorState("Erro ao finalizar a venda: ${e.toString()}"));
      // Garante que a tela não fique presa no loading
      await Future.delayed(const Duration(seconds: 3));
      if (_stateController.value is SalesErrorState) {
        _stateController.add(currentState);
      }
    }
  }

  @disposeMethod
  void dispose() {
    _stateController.close();
  }
}
