import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/repositories/icustomer_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetCustomers {
  final ICustomerRepository repository;

  GetCustomers(this.repository);

  Future<List<Customer>> call() {
    return repository.getCustomers();
  }
}
