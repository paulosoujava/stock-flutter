// lib/data/repositories/category_repository_impl.dart
import 'dart:math';
import 'package:hive/hive.dart';
import 'package:stock/domain/entities/category/category.dart';
import 'package:stock/domain/repositories/icategory_repository.dart';

const String _kCategoryBox = 'categoryBox';

class CategoryRepositoryImpl implements ICategoryRepository {
  Future<Box<Category>> _openBox() async {
    return Hive.openBox<Category>(_kCategoryBox);
  }

  @override
  Future<List<Category>> getCategories() async {
    final box = await _openBox();
    final categories = box.values.toList();
    categories.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return categories;
  }

  @override
  Future<void> addCategory(Category category) async {
    final box = await _openBox();
    final newCategory = Category(
      id: Random().nextInt(999999).toString(), // ID único temporário
      name: category.name,
    );
    await box.put(newCategory.id, newCategory);
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    final box = await _openBox();
    await box.delete(categoryId);
  }

  @override
  Future<void> updateCategory(Category category) async {
    final box = await _openBox();
    // O método 'put' do Hive tanto adiciona quanto atualiza.
    // Se a chave (category.id) já existe, ele sobrescreve o valor.
    await box.put(category.id, category);
  }
}
