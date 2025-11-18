import 'package:injectable/injectable.dart';

import '../../repositories/ilive_repository.dart';

@injectable
class StartLiveUseCase {
  final ILiveRepository _repository;
  StartLiveUseCase(this._repository);

  Future<void> call(String liveId) async {
    final lives = await _repository.getAllLives();
    final live = lives.firstWhere((l) => l.id == liveId);

    final active = await _repository.getActiveLive();
    if (active != null && active.id != liveId) {
      throw Exception("Já existe uma live em andamento!");
    }

    await _repository.updateLive(live.copyWith(startDate: DateTime.now()));
  }
}