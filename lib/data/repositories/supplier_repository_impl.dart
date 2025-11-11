import 'package:hive/hive.dart';
import 'package:stock/domain/entities/supplier/supplier.dart';
import 'package:stock/domain/repositories/isupplier_repository.dart';
import 'package:uuid/uuid.dart';

const String _kSuppliersBox = 'suppliersBox';

class SupplierRepositoryImpl implements ISupplierRepository {
  Future<Box<Supplier>> _openBox() async {
    return Hive.openBox<Supplier>(_kSuppliersBox);
  }

  @override
  Future<void> addSupplier(Supplier supplier) async {
    final box = await _openBox();
    final newSupplier = supplier.copyWith(id: const Uuid().v4());
    await box.put(newSupplier.id, newSupplier);
  }

  @override
  Future<void> deleteSupplier(String supplierId) async {
    final box = await _openBox();
    await box.delete(supplierId);
  }

  @override
  Future<List<Supplier>> getSuppliers() async {
    final box = await _openBox();
    return box.values.toList();
  }

  @override
  Future<void> updateSupplier(Supplier supplier) async {
    final box = await _openBox();
    await box.put(supplier.id, supplier);
  }
}
