import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/domain/repositories/iproduct_repository.dart';


@injectable
class GetProductsByCategory {
  final IProductRepository _repository;

  GetProductsByCategory(this._repository);

  Future<List<Product>> call(String categoryId) {
    return _repository.getProductsByCategoryId(categoryId);
  }
}
