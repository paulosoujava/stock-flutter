import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/usecases/customers/add_customer.dart';
import 'package:stock/domain/usecases/customers/update_customer.dart';
import 'package:stock/presentation/pages/customer/form/customer_form_intent.dart';

import 'customer_form_state.dart';

@injectable
class CustomerFormViewModel {
  final AddCustomer _addCustomer;
  final UpdateCustomer _updateCustomer;

  final _stateController = StreamController<CustomerFormState>.broadcast();

  Stream<CustomerFormState> get state => _stateController.stream;

  CustomerFormViewModel(this._addCustomer, this._updateCustomer) {
    _stateController.add(CustomerFormInitialState());
  }

  /// Processa as intenções recebidas da UI.
  void handleIntent(CustomerFormIntent intent) {
    if (intent is SaveCustomerIntent) {
      _saveCustomer(intent.customer);
    } else if (intent is UpdateCustomerIntent) {
      _updateCustomerMethod(intent.customer);
    }
  }

  Future<void> _saveCustomer(Customer customer) async {
    _stateController.add(CustomerFormLoadingState());
    try {
      await _addCustomer(customer);
      _stateController.add(CustomerFormSuccessState());
    } catch (e) {
      _stateController.add(
          CustomerFormErrorState('Erro ao salvar cliente: ${e.toString()}'));
    }
  }

  Future<void> _updateCustomerMethod(Customer customer) async {
    _stateController.add(CustomerFormLoadingState());
    try {
      await _updateCustomer(customer);
      _stateController.add(CustomerFormSuccessState());
    } catch (e) {
      _stateController.add(
          CustomerFormErrorState('Erro ao atualizar cliente: ${e.toString()}'));
    }
  }

  void dispose() {
    _stateController.close();
  }
}
