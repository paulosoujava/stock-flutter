// lib/presentation/pages/categories/category_list_viewmodel.dart

import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:stock/domain/usecases/categories/delete_category.dart';
import 'package:stock/domain/usecases/categories/get_categories.dart';
import 'package:stock/domain/entities/category/category.dart';
import 'category_list_intent.dart';
import 'category_list_state.dart';

@injectable
class CategoryListViewModel {
  // 1. Dependências (Casos de Uso) que serão injetadas pelo GetIt.
  final GetCategories _getCategories;
  final DeleteCategory _deleteCategory;

  // 2. StreamController para emitir os estados para a UI.
  final _stateController = StreamController<CategoryListState>.broadcast();
  Stream<CategoryListState> get state => _stateController.stream;

  // 3. O construtor recebe as dependências (Inversão de Dependência).
  CategoryListViewModel(this._getCategories, this._deleteCategory) {
    // 4. Dispara a busca inicial de dados assim que o ViewModel é criado.
    handleIntent(FetchCategoriesIntent());
  }

  // 5. Método central que processa as intenções vindas da UI.
  void handleIntent(CategoryListIntent intent) {
    // Usa um 'switch' para tratar os diferentes tipos de intenção.
    switch (intent) {
      case FetchCategoriesIntent():
        _loadCategories();
      case DeleteCategoryIntent():
        _deleteCategoryById(intent.categoryId);
    }
  }

  // Lógica para carregar as categorias.
  Future<void> _loadCategories() async {
    _stateController.add(CategoryListLoadingState());
    try {
      final categories = await _getCategories();
      _stateController.add(CategoryListSuccessState(categories));
    } catch (e) {
      _stateController.add(CategoryListErrorState("Falha ao buscar categorias."));
    }
  }

  // Lógica para deletar uma categoria.
  Future<void> _deleteCategoryById(String categoryId) async {
    try {
      await _deleteCategory(categoryId);
      // Após deletar, busca a lista atualizada para refletir a mudança na UI.
      _loadCategories();
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
