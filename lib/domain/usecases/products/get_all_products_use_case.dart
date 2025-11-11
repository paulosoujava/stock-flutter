import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/domain/repositories/iproduct_repository.dart';

@injectable
class GetAllProductsUseCase {
  final IProductRepository _repository;

  GetAllProductsUseCase(this._repository);

  Future<List<Product>> call() async {
    return await _repository.getAllProducts();
  }
}
