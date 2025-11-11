import 'package:stock/domain/entities/supplier/supplier.dart';

abstract class SupplierFormIntent {}

class SaveSupplierIntent extends SupplierFormIntent {
  final Supplier supplier;
  SaveSupplierIntent(this.supplier);
}
