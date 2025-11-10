import 'package:stock/domain/entities/product/product.dart';
abstract class IProductRepository {
  /// Retorna uma lista de produtos que pertencem a um [categoryId] específico.
  Future<List<Product>> getProductsByCategoryId(String categoryId);

  /// Adiciona um novo [product] ao repositório.
  Future<void> addProduct(Product product);

  /// Atualiza um [product] existente no repositório.
  Future<void> updateProduct(Product product);

  /// Remove um produto do repositório usando seu [productId].
  Future<void> deleteProduct(String productId);
}
