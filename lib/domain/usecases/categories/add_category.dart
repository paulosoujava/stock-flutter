import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/category/category.dart';
import 'package:stock/domain/repositories/icategory_repository.dart';

@injectable class AddCategory {
final ICategoryRepository _repository;
AddCategory(this._repository);

Future<void> call(Category category) {
  if (category.name.isEmpty) {
    throw Exception('O nome da categoria não pode estar vazio.');
  }
  return _repository.addCategory(category);
}
}
