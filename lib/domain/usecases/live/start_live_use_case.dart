
import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/live/live.dart';
import 'package:stock/domain/repositories/ilive_repository.dart';

@injectable
class StartLiveUseCase {
  final ILiveRepository _repository;

  StartLiveUseCase(this._repository);

  Future<void> call(Live live) async {
    // A lógica de negócio é alterar o status e a data de início real.
    live.status = LiveStatus.live;
    // Poderíamos também redefinir o startDateTime para o momento exato do clique.
    // live.startDateTime = DateTime.now();

    // O UseCase de salvar produtos não precisa ser chamado,
    // pois o saveLive do repositório já lida com o objeto Live completo.
    await _repository.saveLive(live, live.products.toList());
  }
}
