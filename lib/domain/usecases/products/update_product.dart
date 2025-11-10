import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/domain/repositories/iproduct_repository.dart';


@injectable
class UpdateProduct {
  final IProductRepository _repository;

  UpdateProduct(this._repository);

  Future<void> call(Product product) {
    if (product.id.isEmpty) {
      throw Exception('ID do produto inválido para atualização.');
    }
    if (product.name.trim().isEmpty) {
      throw Exception('O nome do produto não pode estar vazio.');
    }
    return _repository.updateProduct(product);
  }
}
