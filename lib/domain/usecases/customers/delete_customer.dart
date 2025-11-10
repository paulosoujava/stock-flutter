
import 'package:stock/domain/repositories/icustomer_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteCustomer {
  final ICustomerRepository repository;

  DeleteCustomer(this.repository);

  Future<void> call(String customerId) {
    return repository.deleteCustomer(customerId);
  }
}
