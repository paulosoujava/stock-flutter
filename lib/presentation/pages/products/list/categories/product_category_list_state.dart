import 'package:stock/domain/entities/category/category.dart';

abstract class ProductCategoryListState {}

class ProductCategoryListLoading extends ProductCategoryListState {}

class ProductCategoryListError extends ProductCategoryListState {
  final String message;
  ProductCategoryListError(this.message);
}

class NoCategoriesFound extends ProductCategoryListState {}

class CategoriesWithProductsCountLoaded extends ProductCategoryListState {
  final Map<Category, int> categoriesWithCount;
  CategoriesWithProductsCountLoaded(this.categoriesWithCount);
}
