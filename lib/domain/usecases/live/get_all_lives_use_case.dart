import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/live/live.dart';
import 'package:stock/domain/repositories/ilive_repository.dart';


@injectable
class GetAllLivesUseCase {
  final ILiveRepository _repository;

  GetAllLivesUseCase(this._repository);

  Future<List<Live>> call() {
    return _repository.getAllLives();
  }
}
