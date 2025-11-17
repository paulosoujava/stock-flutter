import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:stock/core/events/event_bus.dart';
import 'package:stock/domain/entities/category/category.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/domain/usecases/auth/sign_out_use_case.dart';
import 'package:stock/domain/usecases/categories/get_categories.dart';
import 'package:stock/domain/usecases/products/get_all_products_use_case.dart';
import 'package:stock/presentation/pages/home/home_intent.dart';
import 'package:stock/presentation/pages/home/home_state.dart';
import 'package:stock/presentation/widgets/LowStockInfo.dart';

@injectable
class HomeViewModel {
  final GetAllProductsUseCase _getAllProductsUseCase;
  final GetCategories _getCategoriesUseCase;
  final SignOutUseCase _signOutUseCase;
  final EventBus _eventBus;

  final _stateController = StreamController<HomeState>.broadcast();
  late final StreamSubscription _eventBusSubscription;

  Stream<HomeState> get state => _stateController.stream;

  HomeViewModel(this._getAllProductsUseCase,
      this._getCategoriesUseCase,
      this._eventBus,
      this._signOutUseCase,) {
    _stateController.add(HomeInitialState());
    _listenToEvents();
  }

  void _listenToEvents() {
    _eventBusSubscription = _eventBus.stream.listen((event) {
      if (event is ProductEvent) {
        _loadInitialData();
      }
    });
  }

  void handleIntent(HomeIntent intent) {
    if (intent is LoadInitialDataIntent) {
      _loadInitialData();
    } else if (intent is SignOutIntent) {
      _signOut();
    }
  }

  Future<void> _signOut() async {
    try {
      print("Fazendo logout no ViewModel...");
      await _signOutUseCase();
      _stateController.add(HomeLogoutSuccessState());
    } catch (e) {
      print("Erro ao fazer logout no ViewModel: $e");
      _stateController.add(HomeErrorState(
          errorMessage: "Erro ao fazer logout no ViewModel: $e"));
    }
  }

    Future<void> _loadInitialData() async {
      _stateController.add(HomeLoadingState());
      try {
        final results = await Future.wait([
          _getAllProductsUseCase(),
          _getCategoriesUseCase(),
        ]);

        final allProducts = results[0] as List<Product>;
        final allCategories = results[1] as List<Category>;

        final categoriesMap = {for (var c in allCategories) c.id: c};

        final List<LowStockInfo> lowStockInfoList = [];

        for (final product in allProducts) {
          if (product.stockQuantity <= product.lowStockThreshold) {
            final category = categoriesMap[product.categoryId];
            if (category != null) {
              lowStockInfoList.add(LowStockInfo(product, category));
            }
          }
        }

        _stateController.add(HomeSuccessState(lowStockInfo: lowStockInfoList));
      } catch (e) {
        _stateController.add(HomeErrorState(
            errorMessage: 'Falha ao carregar dados: ${e.toString()}'));
      }
    }


    void dispose() {
      _eventBusSubscription.cancel();
      _stateController.close();
    }
  }
