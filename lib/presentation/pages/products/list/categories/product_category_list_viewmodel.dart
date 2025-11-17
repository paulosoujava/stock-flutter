import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/category/category.dart';
import 'package:stock/domain/usecases/categories/get_categories.dart';
import 'package:stock/domain/usecases/products/get_products_by_category.dart';
import 'package:stock/domain/usecases/products/get_product_count_by_category.dart';
import '../../../../../core/events/event_bus.dart';
import 'product_category_list_intent.dart';
import 'product_category_list_state.dart';

@injectable
class ProductCategoryListViewModel {
  final GetCategories _getCategories;
  final GetProductCountByCategory _getProductCountByCategory;
  final EventBus _eventBus;


  final _stateController = StreamController<
      ProductCategoryListState>.broadcast();

  Stream<ProductCategoryListState> get state => _stateController.stream;

  ProductCategoryListViewModel(this._getCategories,
      this._getProductCountByCategory, this._eventBus,) {
    handleIntent(LoadCategoriesWithProductCount());
    _listenToEvents();
  }



  void handleIntent(ProductCategoryListIntent intent) {
    if (intent is LoadCategoriesWithProductCount) {
      _loadData();
    }
  }

  void _listenToEvents() {
    _eventBus.stream.listen((event) {
      if (event is ProductEvent) {
        print("Evento recebido: $event");
        handleIntent(LoadCategoriesWithProductCount());
      }
    });
  }

  Future<void> _loadData() async {
   // _stateController.add(ProductCategoryListLoading());
    try {
      final categories = await _getCategories();
      if (categories.isEmpty) {
        _stateController.add(NoCategoriesFound());
        return;
      }

      final Map<Category, int> categoriesWithCount = {};
      for (final category in categories) {
        final count = await _getProductCountByCategory(category.id);
        categoriesWithCount[category] = count;
      }

      _stateController.add(
          CategoriesWithProductsCountLoaded(categoriesWithCount));
    } catch (e) {
      _stateController.add(
          ProductCategoryListError("Falha ao carregar dados."));
    }
  }

  void dispose() {
    _stateController.close();
  }
}
