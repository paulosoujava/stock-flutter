abstract class SupplierListIntent {}

class LoadSuppliersIntent extends SupplierListIntent {}

class SearchSuppliersIntent extends SupplierListIntent {
  final String query;
  SearchSuppliersIntent(this.query);
}

class DeleteSupplierIntent extends SupplierListIntent {
  final String supplierId;  DeleteSupplierIntent(this.supplierId);
}
