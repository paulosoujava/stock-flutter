import 'package:stock/domain/entities/customer/customer.dart';

abstract class CustomerListState {}

class CustomerListInitialState extends CustomerListState {}

class CustomerListLoadingState extends CustomerListState {}

class CustomerListErrorState extends CustomerListState {
  final String message;
  CustomerListErrorState(this.message);
}

class CustomerListSuccessState extends CustomerListState {
  final List<Customer> allCustomers; // Guarda a lista original, sem filtro
  final List<Customer> filteredCustomers; // A lista que será exibida, após o filtro
  final String searchTerm;

  CustomerListSuccessState({
    required this.allCustomers,
    required this.filteredCustomers,
    this.searchTerm = '',
  });

  // Método auxiliar para criar cópias do estado, muito útil no ViewModel
  CustomerListSuccessState copyWith({
    List<Customer>? allCustomers,
    List<Customer>? filteredCustomers,
    String? searchTerm,
  }) {
    return CustomerListSuccessState(
      allCustomers: allCustomers ?? this.allCustomers,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }
}
