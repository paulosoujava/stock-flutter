import 'dart:async';

import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/usecases/customers/delete_customer.dart';
import 'package:stock/domain/usecases/customers/get_customers.dart';
import 'package:injectable/injectable.dart';

import 'customer_list_intent.dart';
import 'customer_list_state.dart';
import 'package:rxdart/rxdart.dart';

@lazySingleton
class CustomerListViewModel {
  late final GetCustomers _getCustomers;
  late final DeleteCustomer _deleteCustomer;

  final _stateController = BehaviorSubject<CustomerListState>();
  Stream<CustomerListState> get state => _stateController.stream;

  CustomerListViewModel(this._getCustomers, this._deleteCustomer) {
    handleIntent( FetchCustomersIntent());
  }

  // Getter para a UI saber qual filtro está ativo
  String? get currentTierFilter {
    final state = _stateController.value;
    if (state is CustomerListSuccessState) {
      return state.selectedTierKeyword;
    }
    return null;
  }

  void handleIntent(CustomerListIntent intent) async {
    if (intent is FetchCustomersIntent) {
      await _fetchCustomers();
    } else if (intent is DeleteCustomerIntent) {
      await _deleteCustomerById(intent.customerId);
      handleIntent( FetchCustomersIntent());
    } else if (intent is SearchCustomerIntent) {
      _applyFilters(searchTerm: intent.searchTerm);
    }else if (intent is FilterByTierIntent) {
      // AQUI ESTÁ A CHAVE: sempre pega o searchTerm ATUAL do estado
      final currentState = _stateController.value;
      if (currentState is CustomerListSuccessState) {
        _applyFilters(
          searchTerm: currentState.searchTerm, // ← texto da busca atual
          tierKeyword: intent.tierKeyword, // ← null = limpar filtro de tier
        );
      } else {
        // Se por algum motivo não estiver no SuccessState, força recarregar
        handleIntent(FetchCustomersIntent());
      }
    }
  }

  Future<void> _fetchCustomers() async {
    _stateController.add( CustomerListLoadingState());
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

  void _applyFilters({String? searchTerm, String? tierKeyword}) {
    final current = _stateController.value;
    if (current is! CustomerListSuccessState) return;

    final activeSearch = searchTerm ?? current.searchTerm;
    final activeTier = tierKeyword; // ← não usa ?? aqui! queremos sobrescrever com null se vier null

    final filtered = current.allCustomers.where((customer) {
      // Filtro por texto
      final matchesSearch = activeSearch.isEmpty ||
          customer.name.toLowerCase().contains(activeSearch.toLowerCase()) ||
          customer.cpf.contains(activeSearch) ||
          customer.phone.contains(activeSearch) ||
          customer.whatsapp.contains(activeSearch);

      // Filtro por tier
      final notesLower = (customer.notes ?? '').toLowerCase();
      final matchesTier = activeTier == null ||
          (activeTier == 'ouro' && notesLower.contains('ouro')) ||
          (activeTier == 'prata' && notesLower.contains('prata')) ||
          (activeTier == 'bronze' && notesLower.contains('bronze'));

      return matchesSearch && matchesTier;
    }).toList();

    _stateController.add(current.copyWith(
      filteredCustomers: filtered,
      searchTerm: activeSearch,
      selectedTierKeyword: activeTier, // ← pode ser null → limpa o filtro
    ));
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