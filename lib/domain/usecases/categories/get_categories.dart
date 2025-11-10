import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/category/category.dart';
import 'package:stock/domain/repositories/icategory_repository.dart';

@injectable
class GetCategories {
  final ICategoryRepository _repository;
  GetCategories(this._repository);

  Future<List<Category>> call() => _repository.getCategories();
}
