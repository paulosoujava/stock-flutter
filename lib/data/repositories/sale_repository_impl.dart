import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/sale/sale.dart';
import 'package:stock/domain/repositories/isale_repository.dart';

const String _kSalesBox = 'salesBox';

class SaleRepositoryImpl implements ISaleRepository {
  Future<Box<Sale>> _openBox() async {
    return Hive.openBox<Sale>(_kSalesBox);
  }

  @override
  Future<void> saveSale(Sale sale) async {
    final box = await _openBox();
    // Chave estruturada para otimizar buscas por período.
    final key =
        '${sale.saleDate.year}-${sale.saleDate.month.toString().padLeft(2, '0')}-${sale.id}';
    await box.put(key, sale);
  }

  @override
  Future<List<Sale>> getSalesByMonth(int year, int month) async {
    final box = await _openBox();
    final prefix = '$year-${month.toString().padLeft(2, '0')}-';

    // Filtra as chaves que começam com o prefixo do ano e mês.
    final sales = box.keys
        .where((key) => (key as String).startsWith(prefix))
        .map((key) => box.get(key)!)
        .toList();

    sales.sort((a, b) => b.saleDate.compareTo(a.saleDate)); // Mais recentes primeiro
    return sales;
  }

  @override
  Future<List<Sale>> getSalesByYear(int year) async {
    final box = await _openBox();
    final prefix = '$year-';

    final sales = box.keys
        .where((key) => (key as String).startsWith(prefix))
        .map((key) => box.get(key)!)
        .toList();

    sales.sort((a, b) => b.saleDate.compareTo(a.saleDate));
    return sales;
  }
}
