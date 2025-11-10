

import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/repositories/icustomer_repository.dart';

@injectable
class AddCustomer {
  final ICustomerRepository repository;

  AddCustomer(this.repository);

  Future<void> call(Customer customer) async {
    if (customer.name.isEmpty) {
      throw Exception('O nome do cliente não pode estar vazio.');
    }
    return repository.addCustomer(customer);
  }
}
