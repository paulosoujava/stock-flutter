

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

  // Usar BehaviorSubject permite acessar o último estado emitido com .value
  final _stateController = BehaviorSubject<CustomerListState>();
  Stream<CustomerListState> get state => _stateController.stream;

  CustomerListViewModel(this._getCustomers, this._deleteCustomer) {
    handleIntent(FetchCustomersIntent());
  }


  // Método central que recebe as "intenções" da UI
  void handleIntent(CustomerListIntent intent) async  {
    if (intent is FetchCustomersIntent) {
      await _fetchCustomers();
    } else if (intent is DeleteCustomerIntent) {
      await _deleteCustomerById(intent.customerId);
    }else if (intent is SearchCustomerIntent) {
      _searchCustomers(intent.searchTerm);
    }
  }

Future<void> _fetchCustomers() async {
//  _stateController.add(CustomerListLoadingState());
  await Future.delayed(const Duration(seconds: 1));
  try {
    final customers = await _getCustomers();
    // No início, a lista filtrada é a mesma que a lista completa
    _stateController.add(CustomerListSuccessState(
      allCustomers: customers,
      filteredCustomers: customers,
    ));
  } catch (e) {
    _stateController.add(CustomerListErrorState('Falha ao carregar clientes.'));
  }
}
void _searchCustomers(String searchTerm) {
  final currentState = _stateController.value;
  if (currentState is CustomerListSuccessState) {
    List<Customer> filteredList;
    if (searchTerm.isEmpty) {
      // Se a busca estiver vazia, a lista filtrada volta a ser a lista completa
      filteredList = currentState.allCustomers;
    } else {
      // Filtra a lista completa (allCustomers) para não perder a referência original
      filteredList = currentState.allCustomers
          .where((customer) =>
      customer.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
          customer.cpf.contains(searchTerm))
          .toList();
    }
    // Emite uma cópia do estado atual com a lista filtrada e o termo da busca
    _stateController.add(currentState.copyWith(
      filteredCustomers: filteredList,
      searchTerm: searchTerm,
    ));
  }
}

Future<void> _deleteCustomerById(String customerId) async {
    try {
      await _deleteCustomer(customerId);
    } catch (e) {
      print("Erro ao deletar cliente: $e");
      _stateController.add(CustomerListErrorState("Erro ao deletar cliente: $e"));

    }
  }

  @disposeMethod
  void dispose() {
    _stateController.close();
  }
}
