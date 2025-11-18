// domain/usecases/live/create_live_use_case.dart
import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/live/live.dart';
import 'package:stock/domain/repositories/ilive_repository.dart';

@injectable
class CreateLiveUseCase {
  final ILiveRepository _repository;
  CreateLiveUseCase(this._repository);

  Future<void> call({
    required String title,
    required String description,
    required DateTime scheduledDate,
    required int goalAmountCents,
  }) async {
    final live = Live(
      id: '',
      title: title,
      description: description,
      scheduledDate: scheduledDate,
      goalAmount: goalAmountCents,
    );
    await _repository.addLive(live);
  }
}