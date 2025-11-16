// lib/presentation/pages/products/form/product_form_viewmodel.dart
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:stock/core/events/event_bus.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/domain/usecases/products/add_product.dart';
import 'package:stock/domain/usecases/products/update_product.dart';
import 'product_form_intent.dart';
import 'product_form_state.dart';

@injectable
class ProductFormViewModel {
  final AddProduct _addProduct;
  final UpdateProduct _updateProduct;
  final EventBus _eventBus;

  final _stateController = StreamController<ProductFormState>.broadcast();
  Stream<ProductFormState> get state => _stateController.stream;

  ProductFormViewModel(this._addProduct, this._updateProduct,  this._eventBus) {
    _stateController.add(ProductFormInitial());
  }

  void handleIntent(ProductFormIntent intent) {
    if (intent is SaveProductIntent) {
      _saveProduct(intent.product);
    } else if (intent is UpdateProductIntent) {
      _updateProductMethod(intent.product);
    }
  }

  Future<void> _saveProduct(Product product) async {
    _stateController.add(ProductFormLoading());
    try {
      await _addProduct(product);
      _stateController.add(ProductFormSuccess());
      _eventBus.fire(ProductEvent());
    } catch (e) {
      _stateController.add(ProductFormError('Erro ao salvar produto: ${e.toString()}'));
    }
  }

  Future<void> _updateProductMethod(Product product) async {
    _stateController.add(ProductFormLoading());
    try {
      await _updateProduct(product);
      _stateController.add(ProductFormSuccess());
      _eventBus.fire(ProductEvent());
    } catch (e) {
      _stateController.add(ProductFormError('Erro ao atualizar produto: ${e.toString()}'));
    }
  }

  void dispose() {
    _stateController.close();
  }
}
