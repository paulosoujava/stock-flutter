import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/sale/sale.dart';
import 'package:stock/domain/repositories/isale_repository.dart';

@injectable
class GetSalesByMonthUseCase {
  final ISaleRepository _repository;

  GetSalesByMonthUseCase(this._repository);

  Future<List<Sale>> call(int year, int month) {
    return _repository.getSalesByMonth(year, month);
  }
}
