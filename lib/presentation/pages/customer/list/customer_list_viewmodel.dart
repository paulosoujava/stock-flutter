import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/usecases/customers/delete_customer.dart';
import 'package:stock/domain/usecases/customers/get_customers.dart';

import 'customer_list_intent.dart';
import 'customer_list_state.dart';

@lazySingleton
class CustomerListViewModel {
  late final GetCustomers _getCustomers;
  late final DeleteCustomer _deleteCustomer;

  // A LINHA QUE RESOLVE TUDO DE UMA VEZ
  final _stateController = BehaviorSubject<CustomerListState>.seeded(CustomerListLoadingState())
    ..distinct((prev, next) => false); // FORÇA EMISSÃO SEMPRE

  Stream<CustomerListState> get state => _stateController.stream;

  CustomerListViewModel(this._getCustomers, this._deleteCustomer) {
    handleIntent( FetchCustomersIntent());
  }

  String? get currentTierFilter {
    final state = _stateController.valueOrNull;
    return state is CustomerListSuccessState ? state.selectedTierKeyword : null;
  }

  void handleIntent(CustomerListIntent intent) async {
    if (intent is FetchCustomersIntent) {
      await _fetchCustomers();
    } else if (intent is DeleteCustomerIntent) {
      await _deleteCustomerById(intent.customerId);
      handleIntent( FetchCustomersIntent());
    } else if (intent is SearchCustomerIntent) {
      _applyFilters(searchTerm: intent.searchTerm);
    } else if (intent is FilterByTierIntent) {
      final current = _stateController.valueOrNull;
      if (current is CustomerListSuccessState) {
        _applyFilters(
          searchTerm: current.searchTerm,
          tierKeyword: intent.tierKeyword,
        );
      } else {
        handleIntent( FetchCustomersIntent());
      }
    }
  }

  Future<void> _fetchCustomers() async {
    _stateController.add(CustomerListLoadingState());
    try {
      final customers = await _getCustomers();
      _stateController.add(CustomerListSuccessState(
        allCustomers: customers,
        filteredCustomers: customers,
        searchTerm: '',
        selectedTierKeyword: null,
      ));
    } catch (e) {
      _stateController.add(CustomerListErrorState('Falha ao carregar clientes.'));
    }
  }

  void _applyFilters({
    String? searchTerm,
    String? tierKeyword,
  }) {
    final current = _stateController.valueOrNull;
    if (current is! CustomerListSuccessState) return;

    final activeSearch = searchTerm ?? current.searchTerm;
    final activeTier = tierKeyword;

    final filtered = current.allCustomers.where((customer) {
      final matchesSearch = activeSearch.isEmpty ||
          customer.name.toLowerCase().contains(activeSearch.toLowerCase()) ||
          customer.cpf.contains(activeSearch) ||
          customer.phone.contains(activeSearch) ||
          customer.whatsapp.contains(activeSearch);

      final notesLower = (customer.notes ?? '').toLowerCase();
      final matchesTier = activeTier == null ||
          notesLower.contains(activeTier);

      return matchesSearch && matchesTier;
    }).toList();

    // FORÇA UM NOVO OBJETO SEMPRE (mesmo com mesmos dados)
    final newState = CustomerListSuccessState(
      allCustomers: current.allCustomers, // referência igual, mas não tem problema
      filteredCustomers: filtered,
      searchTerm: activeSearch,
      selectedTierKeyword: activeTier,
    );

    _stateController.add(newState); // SEM copyWith → novo objeto → sempre emite
  }

  Future<void> _deleteCustomerById(String customerId) async {
    try {
      await _deleteCustomer(customerId);
    } catch (e) {
      _stateController.add(CustomerListErrorState("Erro ao deletar cliente: $e"));
    }
  }

  @disposeMethod
  void dispose() {
    _stateController.close();
  }
}