/// Classe base abstrata para todas as intenções (ações do usuário) da HomePage.
abstract class HomeIntent {}/// Intenção para carregar os dados iniciais do dashboard.
/// A View enviará esta intenção quando a tela for criada.
class LoadInitialDataIntent extends HomeIntent {}
