// Ficheiro: lib/presentation/pages/lives_sales/session/live_session_viewmodel.dart

import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/entities/live/live.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/presentation/pages/lives_sales/session/live_session_intent.dart';
import 'package:stock/presentation/pages/lives_sales/session/live_session_state.dart';

import 'package:stock/domain/usecases/customers/get_all_customers_use_case.dart';
import 'package:stock/domain/usecases/live/get_live_by_id_use_case.dart';
import 'package:stock/domain/usecases/products/get_all_products_use_case.dart';

/// Use lazySingleton para garantir persistência entre telas quando usar injectable/getIt.
@singleton
class LiveSessionViewModel {
  final GetLiveByIdUseCase _getLiveByIdUseCase;
  final GetAllProductsUseCase _getAllProductsUseCase;
  final GetAllCustomersUseCase _getAllCustomersUseCase;

  final _stateSubject = BehaviorSubject<LiveSessionState>();
  Stream<LiveSessionState> get state => _stateSubject.stream;

  Live? _live;
  List<Product> _availableProducts = [];
  List<Customer> _availableCustomers = [];

  // Itens vendidos persistidos na VM
  final List<LiveSaleItem> _saleItems = [];

  // Estoque por sessão (productId -> quantidade disponível)
  final Map<String, int> _sessionStock = {};

  bool _hasLoaded = false;

  LiveSessionViewModel(
      this._getLiveByIdUseCase,
      this._getAllProductsUseCase,
      this._getAllCustomersUseCase,
      );

  void handleIntent(LiveSessionIntent intent) {
    if (intent is LoadLiveSessionDataIntent) {
      _loadData(intent.liveId, forceReload: intent.forceReload);
    } else if (intent is AddSaleItemIntent) {
      _handleAddSaleItem(intent.customer, intent.product, intent.quantity);
    } else if (intent is UpdateSaleItemQuantityIntent) {
      _handleUpdateQuantity(intent.customer, intent.product, intent.newQuantity);
    } else if (intent is RemoveSaleItemIntent) {
      _handleRemoveSaleItem(intent.customer, intent.product);
    } else if (intent is RemoveCustomerGroupIntent) {
      _handleRemoveCustomerGroup(intent.customer);
    } else if (intent is FinalizeLiveIntent) {
      _handleFinalizeLive();
    }
  }

  Future<void> _loadData(String liveId, {bool forceReload = false}) async {
    if (_hasLoaded && !forceReload) {
      _emitSuccessState();
      return;
    }

    _stateSubject.add(LiveSessionLoadingState());

    try {
      _live = await _getLiveByIdUseCase(liveId);
      if (_live == null) throw Exception('Live não encontrada.');

      _availableCustomers = await _getAllCustomersUseCase();
      _availableProducts = await _getAllProductsUseCase();

      // Inicializa estoque de sessão com cópia dos stockQuantity
      _sessionStock.clear();
      for (final p in _availableProducts) {
        _sessionStock[p.id] = p.stockQuantity;
      }

      _hasLoaded = true;
      _emitSuccessState();
    } catch (e) {
      _stateSubject.add(LiveSessionErrorState(e.toString()));
    }
  }

  void _handleAddSaleItem(Customer customer, Product product, int quantity) {
    if (quantity <= 0) {
      _stateSubject.add(LiveSessionWarningState('Quantidade inválida.'));
      _emitSuccessState(); // mantém os itens na tela

      return;
    }

    final available = _sessionStock[product.id] ?? product.stockQuantity;
    if (quantity > available) {
      _stateSubject.add(LiveSessionWarningState('Estoque insuficiente para ${product.name}.'));
      _emitSuccessState(); // mantém os itens na tela

      return;
    }

    // procura item existente (mesmo cliente + produto)
    final existingIndex = _saleItems.indexWhere((it) =>
    it.customer.id == customer.id && it.product.id == product.id);

    if (existingIndex != -1) {
      final existing = _saleItems[existingIndex];
      final newQty = existing.quantity + quantity;
      if (newQty > product.stockQuantity) {
        _stateSubject.add(LiveSessionWarningState('Quantidade total excede o estoque disponível.'));
        _emitSuccessState(); // mantém os itens na tela

        return;
      }
      existing.quantity = newQty;
      existing.totalValue = existing.product.salePrice * existing.quantity;
    } else {
      final item = LiveSaleItem(
        product: product,
        customer: customer,
        quantity: quantity,
        totalValue: product.salePrice * quantity,
      );
      _saleItems.add(item);
    }

    // reduzir estoque da sessão
    _sessionStock[product.id] = available - quantity;

    _emitSuccessState();
  }

  void _handleUpdateQuantity(Customer customer, Product product, int newQuantity) {
    if (newQuantity <= 0) {
      _stateSubject.add(LiveSessionWarningState('Quantidade inválida.'));
      _emitSuccessState(); // mantém os itens na tela

      return;
    }

    final index = _saleItems.indexWhere((it) =>
    it.customer.id == customer.id && it.product.id == product.id);

    if (index == -1) {
      _stateSubject.add(LiveSessionWarningState('Item não encontrado.'));
      _emitSuccessState(); // mantém os itens na tela

      return;
    }

    final item = _saleItems[index];
    final currentQty = item.quantity;
    final diff = newQuantity - currentQty;

    final available = _sessionStock[product.id] ?? product.stockQuantity;

    if (diff > 0) {
      // precisa reduzir estoque adicional
      if (diff > available) {
        _stateSubject.add(LiveSessionWarningState('Estoque insuficiente para aumentar a quantidade.'));
        _emitSuccessState(); // mantém os itens na tela

        return;
      }
      _sessionStock[product.id] = available - diff;
    } else if (diff < 0) {
      // devolver parte do estoque
      _sessionStock[product.id] = available + (-diff);
    }

    item.quantity = newQuantity;
    item.totalValue = item.product.salePrice * newQuantity;

    _emitSuccessState();
  }

  void _handleRemoveSaleItem(Customer customer, Product product) {
    final index = _saleItems.indexWhere((it) =>
    it.customer.id == customer.id && it.product.id == product.id);

    if (index == -1) {
      _stateSubject.add(LiveSessionWarningState('Item não encontrado para remoção.'));
      _emitSuccessState(); // mantém os itens na tela

      return;
    }

    final item = _saleItems.removeAt(index);
    // restituir estoque na sessão
    final available = _sessionStock[product.id] ?? product.stockQuantity;
    _sessionStock[product.id] = available + item.quantity;

    _emitSuccessState();
  }

  void _handleRemoveCustomerGroup(Customer customer) {
    final toRemove = _saleItems.where((it) => it.customer.id == customer.id).toList();
    if (toRemove.isEmpty) {
      _stateSubject.add(LiveSessionWarningState('Nenhum item encontrado para o comprador.'));
      _emitSuccessState(); // mantém os itens na tela

      return;
    }

    for (final item in toRemove) {
      final available = _sessionStock[item.product.id] ?? item.product.stockQuantity;
      _sessionStock[item.product.id] = available + item.quantity;
      _saleItems.remove(item);
    }

    _emitSuccessState();
  }

  void _handleFinalizeLive() {
    _stateSubject.add(LiveSessionFinalizeState(List.unmodifiable(_saleItems)));
  }

  void _emitSuccessState() {
    if (_live == null) {
      _stateSubject.add(LiveSessionErrorState('Live não carregada.'));
      return;
    }

    _stateSubject.add(LiveSessionSuccessState(
      live: _live!,
      availableProducts: List.unmodifiable(_availableProducts),
      availableCustomers: List.unmodifiable(_availableCustomers),
      saleItems: List.unmodifiable(_saleItems),
      sessionStock: Map.unmodifiable(_sessionStock),
    ));
  }

  void dispose() {
    _stateSubject.close();
  }
}

// Modelo de item de venda usado no ViewModel / State
class LiveSaleItem {
  final Product product;
  final Customer customer;
  int quantity;
  double totalValue;

  LiveSaleItem({
    required this.product,
    required this.customer,
    required this.quantity,
    required this.totalValue,
  });
}
