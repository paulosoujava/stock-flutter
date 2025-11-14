// Ficheiro: lib/presentation/pages/lives_sales/session/live_session_state.dart

import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/entities/live/live.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/presentation/pages/lives_sales/session/live_session_viewmodel.dart';

/// Estado base usado pela LiveSessionPage (View) e pelo ViewModel.
abstract class LiveSessionState {}

/// Estado de carregamento inicial.
class LiveSessionLoadingState extends LiveSessionState {}

/// Estado de erro (mensagem legível).
class LiveSessionErrorState extends LiveSessionState {
  final String message;
  LiveSessionErrorState(this.message);
}

/// Estado principal de sucesso: contém todos os dados que a UI precisa.
/// - live: dados da live
/// - availableProducts: produtos carregados
/// - availableCustomers: clientes carregados
/// - saleItems: snapshot dos itens vendidos (List<LiveSaleItem>)
/// - sessionStock: mapa productId -> estoque disponível na sessão
class LiveSessionSuccessState extends LiveSessionState {
  final Live live;
  final List<Product> availableProducts;
  final List<Customer> availableCustomers;
  final List<LiveSaleItem> saleItems;
  final Map<String, int> sessionStock;

  LiveSessionSuccessState({
    required this.live,
    required this.availableProducts,
    required this.availableCustomers,
    this.saleItems = const [],
    this.sessionStock = const {},
  });
}

/// Estado de aviso — usado pelo ViewModel para informar problemas não-fatais
/// (por exemplo: tentativa de exceder estoque). A UI pode mostrar um SnackBar.
class LiveSessionWarningState extends LiveSessionState {
  final String message;
  LiveSessionWarningState(this.message);
}

/// Estado emitido quando a live é finalizada; contém snapshot final das vendas.
class LiveSessionFinalizeState extends LiveSessionState {
  final List<LiveSaleItem> saleItems;
  LiveSessionFinalizeState(this.saleItems);
}
