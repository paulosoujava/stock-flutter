import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/sale/sale.dart';
import 'package:stock/domain/repositories/isale_repository.dart';

@injectable
class SaveSaleUseCase {
  final ISaleRepository _repository;

  SaveSaleUseCase(this._repository);

  Future<void> call(Sale sale) async {
    // Aqui você pode adicionar lógicas de negócio no futuro,
    // como validar a venda, atualizar o estoque do produto, etc.
    return _repository.saveSale(sale);
  }
}
