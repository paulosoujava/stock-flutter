import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/repositories/icustomer_repository.dart';

/// Caso de Uso para ATUALIZAR um cliente existente.
@injectable
class UpdateCustomer {
  final ICustomerRepository _repository;

  UpdateCustomer(this._repository);

  /// Executa o caso de uso, validando os dados antes de chamar o repositório.
  Future<void> call(Customer customer) {
    if (customer.id.isEmpty) {
      throw Exception('ID do cliente inválido para atualização.');
    }
    if (customer.name.trim().isEmpty) {
      throw Exception('O nome do cliente não pode estar vazio.');
    }
    return _repository.updateCustomer(customer);
  }
}
