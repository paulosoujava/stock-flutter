// Classe base abstrata para todas as intenções da lista de categorias.
abstract class CategoryListIntent {}

// Intenção para carregar as categorias E a contagem de produtos
class FetchCategoriesAndCountIntent extends CategoryListIntent {}

// Intenção para deletar uma categoria e recarregar a lista
class DeleteCategoryIntent extends CategoryListIntent {
  final String categoryId;
  DeleteCategoryIntent(this.categoryId);
}