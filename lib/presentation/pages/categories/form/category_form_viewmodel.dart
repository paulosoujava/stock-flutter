import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/category/category.dart';
import 'package:stock/domain/usecases/categories/add_category.dart';
import 'package:stock/domain/usecases/categories/update_category.dart';


import 'category_form_intent.dart';
import 'category_form_state.dart';

@injectable
class CategoryCreateViewModel {
  final AddCategory _addCategory;
  final UpdateCategory _updateCategory;

  final _stateController = StreamController<CategoryFormState>.broadcast();

  Stream<CategoryFormState> get state => _stateController.stream;

  CategoryCreateViewModel(this._addCategory, this._updateCategory) {
    _stateController.add(CategoryCreateInitialState());
  }

  void handleIntent(CategoryFormIntent intent) {
    if (intent is SaveCategoryIntent) {
      _save(intent.category);
    } else if (intent is UpdateCategoryIntent) {
      _update(intent.category);
    }
  }

  Future<void> _save(Category category) async {
    _stateController.add(CategoryCreateLoadingState());
    try {
      await _addCategory(category);
      _stateController.add(CategoryCreateSuccessState());
    } catch (e) {
      _stateController
          .add(CategoryCreateErrorState('Erro ao salvar: ${e.toString()}'));
    }
  }

  Future<void> _update(Category category) async {
    _stateController.add(CategoryCreateLoadingState());
    try {
      await _updateCategory(category);
      _stateController.add(CategoryCreateSuccessState());
    } catch (e) {
      _stateController
          .add(CategoryCreateErrorState('Erro ao atualizar: ${e.toString()}'));
    }
  }

  void dispose() {
    _stateController.close();
  }
}
