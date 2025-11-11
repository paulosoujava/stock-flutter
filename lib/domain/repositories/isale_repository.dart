import 'package:stock/domain/entities/sale/sale.dart';

abstract class ISaleRepository {
  /// Salva uma nova venda no banco de dados.
  Future<void> saveSale(Sale sale);

  /// Retorna todas as vendas para um mês e ano específicos.
  Future<List<Sale>> getSalesByMonth(int year, int month);

  /// Retorna todas as vendas de um ano inteiro.
  Future<List<Sale>> getSalesByYear(int year);
}
