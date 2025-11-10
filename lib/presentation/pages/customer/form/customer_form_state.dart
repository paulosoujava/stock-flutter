abstract class CustomerFormState {}

// Estado inicial ou pronto para receber dados
class CustomerFormInitialState extends CustomerFormState {}

// Estado de carregamento enquanto salva
class CustomerFormLoadingState extends CustomerFormState {}

// Estado de sucesso após salvar
class CustomerFormSuccessState extends CustomerFormState {}

// Estado de erro caso algo falhe
class CustomerFormErrorState extends CustomerFormState {
  final String message;
  CustomerFormErrorState(this.message);
}
