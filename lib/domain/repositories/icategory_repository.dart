
import 'package:stock/domain/entities/category/category.dart';

abstract class ICategoryRepository {
  Future<List<Category>> getCategories();
  Future<void> addCategory(Category category);
  Future<void> deleteCategory(String categoryId);
  Future<void> updateCategory(Category category);
}
