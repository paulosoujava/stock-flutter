import 'package:stock/domain/entities/category/category.dart';

abstract class CategoryListState {}

// Estado para quando a tela está buscando os dados.
// A UI deve mostrar um indicador de carregamento (Spinner).
class CategoryListLoadingState extends CategoryListState {}

// Estado para quando a busca foi bem-sucedida.
// Ele carrega a lista de categorias para a UI exibir.
class CategoryListSuccessState extends CategoryListState {
  final List<Category> categories;
  CategoryListSuccessState(this.categories);
}

// Estado para quando ocorreu um erro durante a busca dos dados.
// A UI deve mostrar uma mensagem de erro para o usuário.
class CategoryListErrorState extends CategoryListState {
  final String message;
  CategoryListErrorState(this.message);
}
