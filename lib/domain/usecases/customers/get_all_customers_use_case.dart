import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/repositories/icustomer_repository.dart';

@injectable
class GetAllCustomersUseCase {
  final ICustomerRepository _repository;
  GetAllCustomersUseCase(this._repository);

  Future<List<Customer>> call() {
    return _repository.getAllCustomers();
  }
}
