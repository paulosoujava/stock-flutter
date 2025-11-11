import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/supplier/supplier.dart';
import 'package:stock/domain/repositories/isupplier_repository.dart';

@injectable class GetSuppliers {
final ISupplierRepository _repository;
GetSuppliers(this._repository);

Future<List<Supplier>> call() => _repository.getSuppliers();
}
