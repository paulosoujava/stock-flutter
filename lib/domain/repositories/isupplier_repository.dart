import 'package:stock/domain/entities/supplier/supplier.dart';

abstract class ISupplierRepository {
  Future<List<Supplier>> getSuppliers();  Future<void> addSupplier(Supplier supplier);
  Future<void> updateSupplier(Supplier supplier);
  Future<void> deleteSupplier(String supplierId);
}
