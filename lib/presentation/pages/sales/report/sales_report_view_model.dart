import 'dart:async';
import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stock/domain/entities/sale/sale.dart';
import 'package:stock/domain/usecases/categories/get_all_sales_use_case.dart';
import 'package:stock/presentation/pages/sales/report/sales_report_state.dart';
import '../../../../domain/entities/sale/month_sales.dart';
import 'sales_report_intent.dart';


@lazySingleton
class SalesReportViewModel {
  final GetAllSalesUseCase _getAllSalesUseCase;

  final _stateController = BehaviorSubject<SalesReportState>();
  Stream<SalesReportState> get state => _stateController.stream;

  SalesReportViewModel(this._getAllSalesUseCase) {
    handleIntent(LoadSalesReportIntent()); // Carrega os dados assim que é criado
  }

  void handleIntent(SalesReportIntent intent) {
    if (intent is LoadSalesReportIntent) {
      _loadReport();
    }
  }

  Future<void> _loadReport() async {
    _stateController.add(SalesReportLoading());
    try {
      final allSales = await _getAllSalesUseCase();

      // Agrupa todas as vendas por ano
      final salesByYear = groupBy(allSales, (Sale sale) => sale.saleDate.year);

      final List<YearlySales> yearlySalesList = [];

      // Itera sobre cada ano (ex: 2024, 2023...)
      salesByYear.forEach((year, yearSales) {
        // Calcula o total do ano
        final yearTotal = yearSales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);

        // Agrupa as vendas daquele ano por mês
        final salesByMonth = groupBy(yearSales, (Sale sale) => sale.saleDate.month);

        final List<MonthlySales> monthlySalesList = [];
        // Itera sobre cada mês daquele ano
        salesByMonth.forEach((month, monthSales) {
          // Calcula o total do mês
          final monthTotal = monthSales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
          monthlySalesList.add(MonthlySales(
            month: month,
            totalAmount: monthTotal,
            sales: monthSales,
          ));
        });

        // Ordena os meses em ordem decrescente
        monthlySalesList.sort((a, b) => b.month.compareTo(a.month));

        yearlySalesList.add(YearlySales(
          year: year,
          totalAmount: yearTotal,
          monthlySales: monthlySalesList,
        ));
      });

      // Ordena os anos em ordem decrescente
      yearlySalesList.sort((a, b) => b.year.compareTo(a.year));

      _stateController.add(SalesReportLoaded(yearlySales: yearlySalesList));
    } catch (e) {
      _stateController.add(SalesReportError("Erro ao gerar relatório: ${e.toString()}"));
    }
  }

  @disposeMethod
  void dispose() {
    _stateController.close();
  }
}
