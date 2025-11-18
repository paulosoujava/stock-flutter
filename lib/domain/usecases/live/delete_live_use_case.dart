// domain/usecases/live/delete_live_use_case.dart

import 'package:injectable/injectable.dart';
import 'package:stock/domain/repositories/ilive_repository.dart';

@injectable
class DeleteLiveUseCase {
  final ILiveRepository _repository;

  DeleteLiveUseCase(this._repository);

  Future<void> call(String liveId) async {
    // Regra de negócio: não permite deletar live que já começou
    final lives = await _repository.getAllLives();
    final live = lives.firstWhere((l) => l.id == liveId);

    if (live.startDate != null) {
      throw Exception("Não é possível deletar uma live que já foi iniciada ou finalizada.");
    }

    await _repository.deleteLive(liveId);
  }
}