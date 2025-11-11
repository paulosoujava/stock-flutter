import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/supplier/supplier.dart';
import 'package:stock/domain/repositories/isupplier_repository.dart';

@injectable
class UpdateSupplier {
  final ISupplierRepository _repository;
  UpdateSupplier(this._repository);

  Future<void> call(Supplier supplier) => _repository.updateSupplier(supplier);
}
