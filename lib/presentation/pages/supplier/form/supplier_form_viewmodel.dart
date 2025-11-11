import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stock/domain/entities/supplier/supplier.dart';
import 'package:stock/domain/usecases/supplier/add_supplier.dart';
import 'package:stock/domain/usecases/supplier/update_supplier.dart';
import 'supplier_form_intent.dart';
import 'supplier_form_state.dart';

@injectable
class SupplierFormViewModel {
  final AddSupplier _addSupplier;
  final UpdateSupplier _updateSupplier;

  final _stateController = BehaviorSubject<SupplierFormState>();
  Stream<SupplierFormState> get state => _stateController.stream;

  SupplierFormViewModel(this._addSupplier, this._updateSupplier);

  void handleIntent(SupplierFormIntent intent) {
    if (intent is SaveSupplierIntent) {
      _saveSupplier(intent.supplier);
    }
  }

  Future<void> _saveSupplier(Supplier supplier) async {
    _stateController.add(SupplierFormLoading());
    try {
      if (supplier.id.isEmpty) {
        await _addSupplier(supplier);
      } else {
        await _updateSupplier(supplier);
      }
      _stateController.add(SupplierFormSuccess());
    } catch (e) {
      _stateController.add(SupplierFormError("Erro ao salvar fornecedor."));
    }
  }

  void dispose() {
    _stateController.close();
  }
}
