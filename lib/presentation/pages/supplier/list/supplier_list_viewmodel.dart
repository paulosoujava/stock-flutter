import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stock/domain/usecases/supplier/delete_supplier.dart';
import 'package:stock/domain/usecases/supplier/get_suppliers.dart';
import 'supplier_list_intent.dart';
import './supplier_list_state.dart';

@lazySingleton
class SupplierListViewModel {
  final GetSuppliers _getSuppliers;
  final DeleteSupplier _deleteSupplier;
  List<dynamic> _originalSuppliers = [];

  final _stateController = BehaviorSubject<SupplierListState>();
  Stream<SupplierListState> get state => _stateController.stream;

  SupplierListViewModel(this._getSuppliers, this._deleteSupplier) {
    handleIntent(LoadSuppliersIntent());
  }

  void handleIntent(SupplierListIntent intent) {
    switch (intent) {
      case LoadSuppliersIntent():
        _loadSuppliers();
      case SearchSuppliersIntent():
        _searchSuppliers(intent.query);
      case DeleteSupplierIntent():
        _deleteAndReload(intent.supplierId);
    }
  }

  Future<void> _loadSuppliers() async {
    _stateController.add(SupplierListLoading());
    try {
      final suppliers = await _getSuppliers();
      _originalSuppliers = suppliers;
      _stateController.add(SupplierListLoaded(suppliers));
    } catch (e) {
      _stateController.add(SupplierListError("Erro ao carregar fornecedores."));
    }
  }

  void _searchSuppliers(String query) {
    if (query.isEmpty) {
      _stateController.add(SupplierListLoaded(_originalSuppliers.cast()));
      return;
    }
    final lowerCaseQuery = query.toLowerCase();
    final filteredList = _originalSuppliers.where((supplier) {
      return supplier.name.toLowerCase().contains(lowerCaseQuery) ||
          supplier.phone.toLowerCase().contains(lowerCaseQuery) ||
          supplier.email.toLowerCase().contains(lowerCaseQuery);
    }).toList();
    _stateController.add(SupplierListLoaded(filteredList.cast()));
  }

  Future<void> _deleteAndReload(String supplierId) async {
    try {
      await _deleteSupplier(supplierId);
      _loadSuppliers(); // Recarrega a lista após deletar
    } catch (e) {
      _stateController.add(SupplierListError("Erro ao deletar fornecedor."));
    }
  }

  @disposeMethod
  void dispose() {
    _stateController.close();
  }
}
