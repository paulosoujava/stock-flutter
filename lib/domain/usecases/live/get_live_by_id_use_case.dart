// Ficheiro: lib/domain/usecases/live/get_live_by_id_use_case.dart

import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/live/live.dart';
import 'package:stock/domain/repositories/ilive_repository.dart';

@injectable
class GetLiveByIdUseCase {
  final ILiveRepository _repository;

  GetLiveByIdUseCase(this._repository);

  Future<Live?> call(String liveId) {
    return _repository.getLiveById(liveId);
  }
}
