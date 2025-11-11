import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stock/domain/usecases/customers/get_customers.dart';
import 'customer_selection_intent.dart';
import 'customer_selection_state.dart';

@lazySingleton
class CustomerSelectionViewModel {
  final GetCustomers _getCustomers;

  final _stateController = BehaviorSubject<CustomerSelectionState>();
  Stream<CustomerSelectionState> get state => _stateController.stream;

  CustomerSelectionViewModel(this._getCustomers);

  void handleIntent(CustomerSelectionIntent intent) {
    switch (intent) {
      case LoadAllCustomersIntent():
        _loadCustomers();
      case FilterCustomersIntent():
        _filterCustomers(intent.query);
    }
  }

  Future<void> _loadCustomers() async {
    _stateController.add(CustomerSelectionLoading());
    try {
      final customers = await _getCustomers();
      _stateController.add(CustomerSelectionLoaded(
        allCustomers: customers,
        filteredCustomers: customers,
      ));
    } catch (e) {
      _stateController.add(CustomerSelectionError("Erro ao carregar clientes."));
    }
  }

  void _filterCustomers(String query) {
    final currentState = _stateController.value;
    if (currentState is CustomerSelectionLoaded) {
      final filtered = currentState.allCustomers.where((customer) {
        final lowerCaseQuery = query.toLowerCase();
        return customer.name.toLowerCase().contains(lowerCaseQuery) ||
            customer.phone.contains(lowerCaseQuery);
      }).toList();
      _stateController.add(CustomerSelectionLoaded(
        allCustomers: currentState.allCustomers,
        filteredCustomers: filtered,
      ));
    }
  }
  @disposeMethod
  void dispose() {
    _stateController.close();
  }
}
