import 'package:injectable/injectable.dart';
import 'package:stock/domain/repositories/iproduct_repository.dart';


@injectable
class GetLastProductCode {
  final IProductRepository repository;

  GetLastProductCode(this.repository);

  Future<int?> call() async {
    final products = await repository.getAllProducts();
    if (products.isEmpty) return null;

    final codes = products
        .where((p) => p.codeOfProduct != null)
        .map((p) => int.tryParse(p.codeOfProduct!) ?? 0)
        .toList();

    if (codes.isEmpty) return null;

    return codes.reduce((a, b) => a > b ? a : b);
  }
}