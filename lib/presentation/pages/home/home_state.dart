import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/presentation/widgets/LowStockInfo.dart';

/// Classe base abstrata para todos os estados da HomePage.abstract class HomeState {}
abstract class HomeState {}


/// Estado inicial, antes de qualquer ação ser tomada.
/// A tela começa neste estado.
class HomeInitialState extends HomeState {}

/// Estado que indica que os dados estão sendo carregados.
/// A View deve mostrar um indicador de progresso (ex: CircularProgressIndicator).
class HomeLoadingState extends HomeState {}

/// Estado de sucesso, emitido quando os dados são carregados com êxito.
/// Contém a lista de produtose categorias  com estoque baixo para ser exibida.
class HomeSuccessState extends HomeState {
  final List<LowStockInfo> lowStockInfo;
  HomeSuccessState({required this.lowStockInfo});
}

/// Estado de erro, emitido quando ocorre uma falha.
/// Contém uma mensagem de erro para ser exibida na View.
class HomeErrorState extends HomeState {
  final String errorMessage;

  HomeErrorState({required this.errorMessage});
}
