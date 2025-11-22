import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/usecases/customers/add_customer.dart';
import 'package:stock/domain/usecases/customers/update_customer.dart';
import 'package:stock/presentation/pages/customer/form/customer_form_intent.dart';

import '../../../../core/events/event_bus.dart';
import 'customer_form_state.dart';

@injectable
class CustomerFormViewModel {
  final AddCustomer _addCustomer;
  final UpdateCustomer _updateCustomer;
  final EventBus _eventBus;

  final _stateController = StreamController<CustomerFormState>.broadcast();

  Stream<CustomerFormState> get state => _stateController.stream;

  CustomerFormViewModel(
    this._addCustomer,
    this._updateCustomer,
    this._eventBus,
  ) {
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
      final newCustomer = customer.copyWith(
        instagram: customer.instagram?.replaceFirst(RegExp(r'^@'), ''),
      );
      await _addCustomer(newCustomer);
      _stateController.add(CustomerFormSuccessState());
      _eventBus.fire(RegisterEvent());
    } catch (e) {
      _stateController.add(
          CustomerFormErrorState('Erro ao salvar cliente: ${e.toString()}'));
    }
  }

  Future<void> _updateCustomerMethod(Customer customer) async {
    _stateController.add(CustomerFormLoadingState());

    try {
      // === REGRA NOVA: Decide se cria novo ou atualiza existente ===
      final bool isTempOrNew =
          customer.id.isEmpty || customer.id.startsWith('temp_');

      print('Verificando se é cliente novo/temporário: $isTempOrNew');

      if (isTempOrNew) {
        print(
            'DECISÃO: Cliente é temporário ou novo. Criando um novo registro...');
        // É um cliente temporário da live → SEMPRE cria um novo
        final newCustomer = customer.copyWith(
          id: '', // deixa vazio → o repositório vai gerar um ID real
          instagram: customer.instagram?.replaceFirst(RegExp(r'^@'), ''),
        );
        // O método _saveCustomer já tem seus próprios prints, então não precisa aqui.
        await _saveCustomer(newCustomer); // use o use case de criação
        _eventBus.fire(RegisterEvent());
      } else {
        print(
            'DECISÃO: Cliente já existe. Atualizando o registro com ID: ${customer.id}');
        // Cliente já existe de verdade → atualiza normalmente
        await _updateCustomer(customer);
        print('Atualização concluída com sucesso.');
      }
      print('--- EMITINDO ESTADO: CustomerFormSuccessState ---');
      _stateController.add(CustomerFormSuccessState());
    } catch (e) {
      print('*** ERRO CAPTURADO em _updateCustomerMethod: ${e.toString()} ***');
      _stateController.add(
        CustomerFormErrorState('Erro ao salvar cliente: ${e.toString()}'),
      );
    } finally {
      print('--- _updateCustomerMethod FINALIZADO ---');
    }
  }

  void dispose() {
    _stateController.close();
  }
}
