import 'package:injectable/injectable.dart';
import 'package:stock/domain/repositories/iproduct_repository.dart';


@injectable
class DeleteProduct {
  final IProductRepository _repository;

  DeleteProduct(this._repository);

  Future<void> call(String productId) {
    if (productId.isEmpty) {
      throw Exception('ID do produto inválido para exclusão.');
    }
    return _repository.deleteProduct(productId);
  }
}
