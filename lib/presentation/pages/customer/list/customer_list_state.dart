import 'package:stock/domain/entities/customer/customer.dart';

abstract class CustomerListState {}

class CustomerListInitialState extends CustomerListState {}

class CustomerListLoadingState extends CustomerListState {}

class CustomerListErrorState extends CustomerListState {
  final String message;
  CustomerListErrorState(this.message);
}

class CustomerListSuccessState extends CustomerListState {
  final List<Customer> allCustomers;
  final List<Customer> filteredCustomers;
  final String searchTerm;
  final String? selectedTierKeyword; // "ouro", "prata", "bronze" ou null

  CustomerListSuccessState({
    required this.allCustomers,
    required this.filteredCustomers,
    this.searchTerm = '',
    this.selectedTierKeyword,
  });

  CustomerListSuccessState copyWith({
    List<Customer>? allCustomers,
    List<Customer>? filteredCustomers,
    String? searchTerm,
    String? selectedTierKeyword, // ← pode receber null
  }) {
    return CustomerListSuccessState(
      allCustomers: allCustomers ?? this.allCustomers,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      searchTerm: searchTerm ?? this.searchTerm,
      selectedTierKeyword: selectedTierKeyword ?? this.selectedTierKeyword,
    );
  }


}