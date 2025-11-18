import '../entities/customer/customer.dart';

abstract class ICustomerRepository {
  Future<List<Customer>> getCustomers();
  Future<void> deleteCustomer(String customerId);
  Future<void> addCustomer(Customer customer);
  Future<void> updateCustomer(Customer customer);
  Future<Customer?> getCustomerByInstagram(String instagram);
}
