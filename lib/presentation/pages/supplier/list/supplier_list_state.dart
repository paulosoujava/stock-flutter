import 'package:stock/domain/entities/supplier/supplier.dart';

abstract class SupplierListState {}

class SupplierListInitial extends SupplierListState {}

class SupplierListLoading extends SupplierListState {}

class SupplierListError extends SupplierListState {
  final String message;  SupplierListError(this.message);
}

class SupplierListLoaded extends SupplierListState {
  final List<Supplier> suppliers;
  SupplierListLoaded(this.suppliers);
}
