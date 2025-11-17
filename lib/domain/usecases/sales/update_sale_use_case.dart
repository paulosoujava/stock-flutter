// update_sale_use_case.dart (nova usecase)
import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/sale/sale.dart';
import 'package:stock/domain/repositories/isale_repository.dart';

@injectable
class UpdateSaleUseCase {
  final ISaleRepository _repository;

  UpdateSaleUseCase(this._repository);

  Future<void> call(Sale sale) async {
    return _repository.updateSale(sale);
  }
}