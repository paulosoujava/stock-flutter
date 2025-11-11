import 'package:injectable/injectable.dart';
import 'package:stock/domain/repositories/isupplier_repository.dart';

@injectable
class DeleteSupplier {
  final ISupplierRepository _repository;
  DeleteSupplier(this._repository);

  Future<void> call(String supplierId) => _repository.deleteSupplier(supplierId);
}
