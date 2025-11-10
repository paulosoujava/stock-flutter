// lib/presentation/pages/categories/form/category_form_state.dart

/// Classe base para todos os estados da tela de criação de categoria.
abstract class CategoryFormState {}

/// Estado inicial: o formulário está pronto para ser preenchido.
class CategoryCreateInitialState extends CategoryFormState {}

/// Estado de carregamento: o app está salvando a nova categoria no banco.
/// A UI deve mostrar um indicador de progresso (loading spinner).
class CategoryCreateLoadingState extends CategoryFormState {}

/// Estado de sucesso: a categoria foi salva com sucesso.
/// A UI usará este estado para fechar a tela e voltar para a lista.
class CategoryCreateSuccessState extends CategoryFormState {}

/// Estado de erro: algo deu errado ao tentar salvar.
/// A UI deve mostrar uma mensagem de erro (snackbar, etc.).
class CategoryCreateErrorState extends CategoryFormState {
  final String message;
  CategoryCreateErrorState(this.message);
}
