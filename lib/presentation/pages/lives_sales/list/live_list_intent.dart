/// Define a intenção base para a tela de listagem de lives.
abstract class LiveListIntent {}

/// Intenção de carregar (ou recarregar) a lista de todas as lives.
class LoadLivesIntent extends LiveListIntent {}

/// Intenção de deletar uma live específica.
class DeleteLiveIntent extends LiveListIntent {
  final String liveId;

  DeleteLiveIntent(this.liveId);
}
