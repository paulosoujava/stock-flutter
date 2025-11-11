import 'package:stock/domain/entities/customer/customer.dart';

abstract class CustomerSelectionState {}

class CustomerSelectionInitial extends CustomerSelectionState {}

class CustomerSelectionLoading extends CustomerSelectionState {}

class CustomerSelectionError extends CustomerSelectionState {
  final String message;
  CustomerSelectionError(this.message);
}

class CustomerSelectionLoaded extends CustomerSelectionState {
  final List<Customer> allCustomers;
  final List<Customer> filteredCustomers;

  CustomerSelectionLoaded({
    required this.allCustomers,
    required this.filteredCustomers,
  });
}
