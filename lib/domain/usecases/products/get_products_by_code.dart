import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/domain/repositories/iproduct_repository.dart';


@injectable
class GetProductsByCode {
  final IProductRepository _repository;

  GetProductsByCode(this._repository);

  Future<Product?> call(String code) {
    return _repository.getProductsByCode(code);
  }
}
