// Ficheiro: lib/presentation/pages/lives_sales/form/live_form_viewmodel.dart

import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/live/live.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/domain/usecases/live/save_live_use_case.dart';
import 'package:stock/domain/usecases/products/get_all_products_use_case.dart';
import 'package:stock/presentation/pages/lives_sales/form/live_form_intent.dart';
import 'package:stock/presentation/pages/lives_sales/form/live_form_state.dart';

@injectable
class LiveFormViewModel {
  final SaveLiveUseCase _saveLiveUseCase;
  final GetAllProductsUseCase _getAllProductsUseCase;

  final StreamController<LiveFormState> _stateController = StreamController.broadcast();
  Stream<LiveFormState> get state => _stateController.stream;

  LiveFormReadyState _currentState = LiveFormReadyState(allAvailableProducts: []);
  LiveFormState get currentState => _currentState;

  LiveFormViewModel(this._saveLiveUseCase, this._getAllProductsUseCase);

  void handleIntent(LiveFormIntent intent) {
    if (intent is LoadInitialDataIntent) {
      _loadInitialData();
    } else if (intent is AddProductToLiveIntent) {
      _addProduct(intent.product);
    } else if (intent is RemoveProductFromLiveIntent) {
      _removeProduct(intent.product);
    } else if (intent is SaveLiveIntent) {
      _saveLive(intent);
    }
  }

  Future<void> _loadInitialData() async {
    _stateController.add(LiveFormLoadingState());
    try {
      final products = await _getAllProductsUseCase();
      _currentState = LiveFormReadyState(allAvailableProducts: products, tempProductsInLive: []);
      _stateController.add(_currentState);
    } catch (e) {
      _stateController.add(LiveFormErrorState('Falha ao carregar produtos: $e'));
    }
  }

  void _addProduct(Product product) {
    if (currentState is! LiveFormReadyState) return;
    final currentProducts = List<Product>.from((currentState as LiveFormReadyState).tempProductsInLive);

    if (!currentProducts.any((p) => p.id == product.id)) {
      currentProducts.add(product);
      _currentState = (currentState as LiveFormReadyState).copyWith(tempProductsInLive: currentProducts);
      _stateController.add(_currentState);
    }
  }

  void _removeProduct(Product product) {
    if (currentState is! LiveFormReadyState) return;
    final currentProducts = List<Product>.from((currentState as LiveFormReadyState).tempProductsInLive);
    currentProducts.removeWhere((p) => p.id == product.id);
    _currentState = (currentState as LiveFormReadyState).copyWith(tempProductsInLive: currentProducts);
    _stateController.add(_currentState);
  }

  Future<void> _saveLive(SaveLiveIntent intent) async {
    try {
      final liveToSave = Live(
        title: intent.title,
        description: intent.description,
      );
      await _saveLiveUseCase(liveToSave, intent.productsInLive);
      _stateController.add(LiveFormSaveSuccessState());
    } catch (e) {
      print('Erro ao salvar a live: $e');
      _stateController.add(LiveFormErrorState('Falha ao salvar a live: ${e.toString()}'));
    }
  }

  void dispose() {
    _stateController.close();
  }
}

