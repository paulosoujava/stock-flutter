// lib/presentation/pages/categories/category_list_viewmodel.dart

import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:stock/domain/usecases/categories/delete_category.dart';
import 'package:stock/domain/usecases/categories/get_categories.dart';
import 'package:stock/domain/entities/category/category.dart';
import 'package:stock/domain/usecases/products/get_product_count_by_category.dart';
import 'category_list_intent.dart';
import 'category_list_state.dart';

@injectable
class CategoryListViewModel {
  final GetCategories _getCategories;
  final DeleteCategory _deleteCategory;
  final GetProductCountByCategory _getProductCountByCategory;

  final _stateController = StreamController<CategoryListState>.broadcast();
  Stream<CategoryListState> get state => _stateController.stream;


  CategoryListViewModel(
      this._getCategories,
      this._deleteCategory,
      this._getProductCountByCategory,
      ) {
    handleIntent(FetchCategoriesAndCountIntent());  }

  void handleIntent(CategoryListIntent intent) async {
    if (intent is FetchCategoriesAndCountIntent) {
      await _loadData();
    } else if (intent is DeleteCategoryIntent) {
      await _deleteCategoryById(intent.categoryId);
    }
  }
  Future<void> _loadData() async {
    _stateController.add(CategoryListLoadingState());
    try {
      final categories = await _getCategories();
      if (categories.isEmpty) {
        // Se não há categorias, emite um estado de sucesso com um mapa vazio
        _stateController.add(CategoryListSuccessState(const {}));
        return;
      }

      // Cria um mapa para armazenar a categoria e a contagem de produtos
      final Map<Category, int> categoriesWithCount = {};
      for (final category in categories) {
        // Para cada categoria, usa o novo superpoder para contar os produtos
        final count = await _getProductCountByCategory(category.id);
        categoriesWithCount[category] = count;
      }

      // Emite o estado de sucesso com os dados completos
      _stateController.add(CategoryListSuccessState(categoriesWithCount));
    } catch (e) {
      _stateController.add(CategoryListErrorState("Falha ao carregar categorias."));
    }
  }
  // Lógica para deletar uma categoria.
  Future<void> _deleteCategoryById(String categoryId) async {
    try {
      await _deleteCategory(categoryId);
      // Após deletar, busca a lista atualizada para refletir a mudança na UI.
      await _loadData();
    } catch (e) {
      // Em um cenário real, poderíamos emitir um estado de erro
      // para mostrar um snackbar de falha na exclusão.
      print("Erro ao deletar categoria: $e");
    }
  }

  // 6. Método dispose para limpar o StreamController e evitar memory leaks.
  void dispose() {
    _stateController.close();
  }
}
