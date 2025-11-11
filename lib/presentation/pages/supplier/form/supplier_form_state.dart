abstract class SupplierFormState {}

class SupplierFormInitial extends SupplierFormState {}

class SupplierFormLoading extends SupplierFormState {}

class SupplierFormSuccess extends SupplierFormState {}

class SupplierFormError extends SupplierFormState {
  final String message;
  SupplierFormError(this.message);
}
