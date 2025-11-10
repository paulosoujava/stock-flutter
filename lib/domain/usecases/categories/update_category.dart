// lib/domain/usecases/category/update_category.dart

import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/category/category.dart';
import 'package:stock/domain/repositories/icategory_repository.dart';

/// Caso de Uso para ATUALIZAR uma categoria existente.
@injectable
class UpdateCategory {
  final ICategoryRepository _repository;

  UpdateCategory(this._repository);

  /// Executa o caso de uso.
  Future<void> call(Category category) {
    if (category.name.trim().isEmpty) {
      throw Exception('O nome da categoria não pode estar vazio.');
    }
    if (category.id.isEmpty) {
      throw Exception('ID da categoria inválido para atualização.');
    }
    return _repository.updateCategory(category);
  }
}
