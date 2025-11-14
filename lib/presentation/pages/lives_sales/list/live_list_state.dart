
import 'package:stock/domain/entities/live/live.dart';


abstract class LiveListState {}

/// Define o estado base para a tela de listagem de lives.abstract class LiveListState {}

/// Estado inicial, antes de qualquer carregamento.
class LiveListInitialState extends LiveListState {}

/// Estado que indica que os dados estão a ser carregados.
class LiveListLoadingState extends LiveListState {}

/// Estado de sucesso, contendo a lista de lives a ser exibida.
class LiveListSuccessState extends LiveListState {
  final List<Live> lives;

  LiveListSuccessState(this.lives);
}

/// Estado que indica que ocorreu um erro durante o carregamento.
class LiveListErrorState extends LiveListState {
  final String errorMessage;

  LiveListErrorState(this.errorMessage);
}

class NavigateToLiveSessionState extends LiveListState {
  final String liveId;
  NavigateToLiveSessionState(this.liveId);
}

