import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/sale/sale.dart';
import 'package:stock/domain/repositories/isale_repository.dart';

@injectable
class GetAllSalesUseCase {
  final ISaleRepository _repository;

  GetAllSalesUseCase(this._repository);

  Future<List<Sale>> call() {
    return _repository.getAllSales();
  }
}
