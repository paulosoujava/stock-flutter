import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/live/live.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/domain/repositories/ilive_repository.dart';


@injectable
class SaveLiveUseCase {
  final ILiveRepository _repository;

  SaveLiveUseCase(this._repository);

  Future<void> call(Live live, List<Product> products) {
    return _repository.saveLive(live, products);
  }
}
