import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/category/category.dart';
import 'package:stock/domain/usecases/categories/add_category.dart';
import 'package:stock/domain/usecases/categories/update_category.dart';


import 'category_form_intent.dart';
import 'category_form_state.dart';

@injectable
class CategoryFormViewModel {
  final AddCategory _addCategory;
  final UpdateCategory _updateCategory;

  final _stateController = StreamController<CategoryFormState>.broadcast();

  Stream<CategoryFormState> get state => _stateController.stream;

  CategoryFormViewModel(this._addCategory, this._updateCategory) {
    _stateController.add(CategoryFormInitialState());
  }

  void handleIntent(CategoryFormIntent intent) {
    if (intent is SaveCategoryIntent) {
      _save(intent.category);
    } else if (intent is UpdateCategoryIntent) {
      _update(intent.category);
    }
  }

  Future<void> _save(Category category) async {
    _stateController.add(CategoryFormLoadingState());
    try {
      await _addCategory(category);
      _stateController.add(CategoryFormSuccessState());
    } catch (e) {
      _stateController
          .add(CategoryFormErrorState('Erro ao salvar: ${e.toString()}'));
    }
  }

  Future<void> _update(Category category) async {
    _stateController.add(CategoryFormLoadingState());
    try {
      await _updateCategory(category);
      _stateController.add(CategoryFormSuccessState());
    } catch (e) {
      _stateController
          .add(CategoryFormErrorState('Erro ao atualizar: ${e.toString()}'));
    }
  }

  void dispose() {
    _stateController.close();
  }
}
