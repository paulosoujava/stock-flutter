
import 'package:injectable/injectable.dart';
import 'package:stock/domain/repositories/ilive_repository.dart';


@injectable
class DeleteLiveUseCase {
  final ILiveRepository _repository;

  DeleteLiveUseCase(this._repository);

  Future<void> call(String liveId) {
    return _repository.deleteLive(liveId);
  }
}
