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
      final salesByYear = groupBy(allSales, (Sale sale) => sale.saleDate.year);
      final List<YearlySales> yearlySalesList = [];

      salesByYear.forEach((year, yearSales) {
        final yearTotal = yearSales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
        final salesByMonth = groupBy(yearSales, (Sale sale) => sale.saleDate.month);
        final List<MonthlySales> monthlySalesList = [];

        salesByMonth.forEach((month, monthSales) {
          final monthTotal = monthSales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
          final Map<String, double> sellerSalesMap = {};
          for (var sale in monthSales) {
            // Se o vendedor já está no mapa, soma o valor. Senão, adiciona.
            sellerSalesMap.update(
              sale.sellerName,
                  (value) => value + sale.totalAmount,
              ifAbsent: () => sale.totalAmount,
            );
          }
          // Converte o mapa em uma lista de objetos de performance
          final sellerPerformances = sellerSalesMap.entries.map((entry) {
            return SellerMonthlyPerformance(
              sellerName: entry.key,
              totalSold: entry.value,
            );
          }).toList();
          // Ordena os vendedores por quem vendeu mais
          sellerPerformances.sort((a, b) => b.totalSold.compareTo(a.totalSold));


          monthlySalesList.add(MonthlySales(
            month: month,
            totalAmount: monthTotal,
            sales: monthSales,
            sellerPerformances: sellerPerformances, // Passa a lista processada
          ));
        });

        monthlySalesList.sort((a, b) => b.month.compareTo(a.month));

        yearlySalesList.add(YearlySales(
          year: year,
          totalAmount: yearTotal,
          monthlySales: monthlySalesList,
        ));
      });

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
