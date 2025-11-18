
import 'package:injectable/injectable.dart';

import '../../entities/live/live.dart';
import '../../repositories/ilive_repository.dart';

@injectable
class GetActiveLiveUseCase {
  final ILiveRepository _repository;
  GetActiveLiveUseCase(this._repository);

  Future<Live?> call() => _repository.getActiveLive();
}