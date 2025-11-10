
abstract class CustomerListIntent {}

class FetchCustomersIntent extends CustomerListIntent {}

class DeleteCustomerIntent extends CustomerListIntent {
  final String customerId;
  DeleteCustomerIntent(this.customerId);
}
