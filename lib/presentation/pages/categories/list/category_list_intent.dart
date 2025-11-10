// Classe base abstrata para todas as intenções da lista de categorias.
abstract class CategoryListIntent {}

// Intenção para buscar a lista de categorias do banco de dados.
// Será disparada quando a tela for iniciada.
class FetchCategoriesIntent extends CategoryListIntent {}

// Intenção para deletar uma categoria específica.
// Será disparada quando o usuário confirmar a exclusão de um item.
class DeleteCategoryIntent extends CategoryListIntent {
  final String categoryId;
  DeleteCategoryIntent(this.categoryId);
}
