// lib/presentation/pages/products/form/product_form_state.dart
abstract class ProductFormState {}

class ProductFormInitial extends ProductFormState {}

class ProductFormLoading extends ProductFormState {}

class ProductFormSuccess extends ProductFormState {}

class ProductFormError extends ProductFormState {
  final String message;
  ProductFormError(this.message);
}
