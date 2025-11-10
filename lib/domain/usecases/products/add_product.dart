import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/domain/repositories/iproduct_repository.dart';


@injectable
class AddProduct {
  final IProductRepository _repository;

  AddProduct(this._repository);

  Future<void> call(Product product) {
    if (product.name.trim().isEmpty) {
      throw Exception('O nome do produto não pode estar vazio.');
    }
    if (product.salePrice <= 0) {
      throw Exception('O preço de venda deve ser maior que zero.');
    }
    return _repository.addProduct(product);
  }
}
