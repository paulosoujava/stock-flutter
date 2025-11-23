import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:stock/core/events/event_bus.dart';
import 'package:stock/domain/usecases/products/delete_product.dart';
import 'package:stock/domain/usecases/products/get_products_by_category.dart';
import 'package:stock/presentation/pages/products/list/products/product_list_intent.dart';
import 'package:stock/presentation/pages/products/list/products/product_list_state.dart';

import '../../../../../domain/entities/product/product.dart';

@injectable
class ProductListViewModel {
  final GetProductsByCategory _getProductsByCategory;
  final DeleteProduct _deleteProduct;
  late final StreamSubscription _eventBusSubscription;

  final _stateController = StreamController<ProductListState>.broadcast();
  List<Product> _originalProducts = [];
  Stream<ProductListState> get state => _stateController.stream;
  late String idCategory;

  ProductListViewModel(
    this._getProductsByCategory,
    this._deleteProduct,
  );

  void handleIntent(ProductListIntent intent) async {
    if (intent is LoadProducts) {
      idCategory = intent.categoryId;
      _loadProducts(intent.categoryId);
    } else if (intent is DeleteProductIntent) {
      await _deleteProductById(intent.productId);
    }else if (intent is SearchProducts) {
      final searchTerm = intent.searchTerm.toLowerCase();
      final filteredList = _originalProducts.where((product) {
        return product.name.toLowerCase().contains(searchTerm);
      }).toList();

      _stateController.add(ProductListLoaded(
        allProducts: _originalProducts,
        displayedProducts: filteredList,
      ));
    }
  }



  Future<void> _loadProducts(String categoryId) async {
    _stateController.add(ProductListLoading());
    try {
      final products = await _getProductsByCategory(categoryId);
      _originalProducts = products;
      _stateController.add(ProductListLoaded(
        allProducts: _originalProducts,
        displayedProducts: _originalProducts,
      ));
    } catch (e) {
      _stateController.add(ProductListError("Falha ao carregar produtos."));
    }
  }

  Future<void> _deleteProductById(String productId) async {
    try {
      await _deleteProduct(productId);
    } catch (e) {
      print("Erro ao deletar produto: $e");
      // Re-lança o erro para que a UI possa saber que a operação falhou.
      rethrow;
    }
  }

  void dispose() {
    _stateController.close();
    _eventBusSubscription.cancel();

  }
}
