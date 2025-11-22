import 'package:stock/domain/entities/customer/customer.dart';

abstract class CustomerFormIntent {}

class SaveCustomerIntent extends CustomerFormIntent {
  final Customer customer;

  SaveCustomerIntent(this.customer);
}

class UpdateCustomerIntent extends CustomerFormIntent {
  final Customer customer;

  UpdateCustomerIntent(this.customer);
}


