import 'package:stock/domain/entities/category/category.dart';

abstract class CategoryListState {}

// Estado para quando a tela está buscando os dados.
// A UI deve mostrar um indicador de carregamento (Spinner).
class CategoryListLoadingState extends CategoryListState {}

// A chave é a Categoria, o valor é a contagem de produtos (int).
class CategoryListSuccessState extends CategoryListState {
  final Map<Category, int> categoriesWithCount;
  CategoryListSuccessState(this.categoriesWithCount);
}

// Estado para quando ocorreu um erro durante a busca dos dados.
// A UI deve mostrar uma mensagem de erro para o usuário.
class CategoryListErrorState extends CategoryListState {
  final String message;
  CategoryListErrorState(this.message);
}
