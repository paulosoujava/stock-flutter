import 'package:injectable/injectable.dart';
import 'package:stock/domain/repositories/iproduct_repository.dart';

@injectable
class GetProductCountByCategory {
  final IProductRepository _repository;

  GetProductCountByCategory(this._repository);

  Future<int> call(String categoryId) async {
    final products = await _repository.getProductsByCategoryId(categoryId);
    return products.length;
  }
}
