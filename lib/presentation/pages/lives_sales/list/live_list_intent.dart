import 'package:stock/domain/entities/live/live.dart';

/// Define a intenção base para a tela de listagem de lives.
abstract class LiveListIntent {}

/// Intenção de carregar (ou recarregar) a lista de todas as lives.
class LoadLivesIntent extends LiveListIntent {}

/// Intenção de deletar uma live específica.
class DeleteLiveIntent extends LiveListIntent {
  final String liveId;

  DeleteLiveIntent(this.liveId);
}

/// Intenção de iniciar uma live específica, mudando seu status.
class StartLiveIntent extends LiveListIntent {
  final Live live;
  StartLiveIntent(this.live);
}