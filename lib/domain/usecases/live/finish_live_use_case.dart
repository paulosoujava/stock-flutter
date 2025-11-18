
import 'package:injectable/injectable.dart';

import '../../repositories/ilive_repository.dart';

@injectable
class FinishLiveUseCase {
  final ILiveRepository _repository;
  FinishLiveUseCase(this._repository);

  Future<void> call(String liveId) async {
    final lives = await _repository.getAllLives();
    final live = lives.firstWhere((l) => l.id == liveId);
    await _repository.updateLive(live.copyWith(endDate: DateTime.now()));
  }
}