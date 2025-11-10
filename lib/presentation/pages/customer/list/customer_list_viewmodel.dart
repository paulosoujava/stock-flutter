// lib/app/presentation/pages/customer/list/customer_list_viewmodel.dart

import 'dart:async';

import 'package:stock/domain/usecases/customers/delete_customer.dart';
import 'package:stock/domain/usecases/customers/get_customers.dart';

import 'package:injectable/injectable.dart';

import 'customer_list_intent.dart';
import 'customer_list_state.dart';


@injectable
class CustomerListViewModel {
  // 1. DECLARAÇÃO DOS CASOS DE USO
  // Eles guardam a lógica de negócio (buscar, deletar, etc.)
  late final GetCustomers _getCustomers;
  late final DeleteCustomer _deleteCustomer;

  // Stream que emite os estados para a UI (Carregando, Sucesso, Erro)
  final _stateController = StreamController<CustomerListState>.broadcast();
  Stream<CustomerListState> get state => _stateController.stream;

  CustomerListViewModel(this._getCustomers, this._deleteCustomer) {
    handleIntent(FetchCustomersIntent());
  }


  // Método central que recebe as "intenções" da UI
  void handleIntent(CustomerListIntent intent) {
    if (intent is FetchCustomersIntent) {
      _loadCustomers();
    } else if (intent is DeleteCustomerIntent) {
      _deleteCustomerById(intent.customerId);
    }
  }

  Future<void> _loadCustomers() async {
    _stateController.add(CustomerListLoadingState());
    try {
      final customers = await _getCustomers(); // <- Busca os dados do Hive
  _stateController.add(CustomerListSuccessState(customers));

    } catch (e) {
      _stateController.add(CustomerListErrorState('Falha ao carregar clientes do banco de dados.'));
    }
  }

  Future<void> _deleteCustomerById(String customerId) async {
    try {
      await _deleteCustomer(customerId);
      _loadCustomers();
    } catch (e) {
      print("Erro ao deletar cliente: $e");
      _stateController.add(CustomerListErrorState("Erro ao deletar cliente: $e"));

    }
  }

  void dispose() {
    _stateController.close();
  }
}
