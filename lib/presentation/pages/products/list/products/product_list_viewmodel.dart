import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:stock/domain/usecases/products/delete_product.dart';
import 'package:stock/domain/usecases/products/get_products_by_category.dart';
import 'package:stock/presentation/pages/products/list/products/product_list_intent.dart';
import 'package:stock/presentation/pages/products/list/products/product_list_state.dart';

@injectable
class ProductListViewModel {
  final GetProductsByCategory _getProductsByCategory;
  final DeleteProduct _deleteProduct;


  final _stateController = StreamController<ProductListState>.broadcast();
  Stream<ProductListState> get state => _stateController.stream;

  ProductListViewModel(this._getProductsByCategory, this._deleteProduct);


  void handleIntent(ProductListIntent intent) async {
    if (intent is LoadProducts) {
      _loadProducts(intent.categoryId);
    }else if (intent is DeleteProductIntent) {
      await _deleteProductById(intent.productId);
    }
  }

  Future<void> _loadProducts(String categoryId) async {
    _stateController.add(ProductListLoading());
    try {
      final products = await _getProductsByCategory(categoryId);
      _stateController.add(ProductListLoaded(products));
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
  }
}
