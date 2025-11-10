
import 'package:stock/domain/entities/customer/customer.dart';

abstract class CustomerListState {}

class CustomerListLoadingState extends CustomerListState {}

class CustomerListSuccessState extends CustomerListState {
  final List<Customer> customers;
  CustomerListSuccessState(this.customers);
}

class CustomerListErrorState extends CustomerListState {
  final String message;
  CustomerListErrorState(this.message);
}
