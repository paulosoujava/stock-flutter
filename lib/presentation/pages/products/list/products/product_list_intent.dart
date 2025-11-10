/// Classe base para todas as intenções da tela de listagem de produtos.
abstract class ProductListIntent {}

/// Intenção para carregar os produtos de uma categoria específica.
/// Ela carrega o ID da categoria para a qual os produtos devem ser filtrados.
class LoadProducts extends ProductListIntent {
  final String categoryId;
  LoadProducts(this.categoryId);
}
/// Intenção para deletar um produto específico.
class DeleteProductIntent extends ProductListIntent {
  final String productId;
  DeleteProductIntent(this.productId);
}