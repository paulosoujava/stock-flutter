// sales_report_view_model.dart
import 'dart:async';
import 'package:collection/collection.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stock/data/model/params_delivery.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/entities/sale/sale.dart';
import 'package:stock/domain/entities/sale/month_sales.dart';
import 'package:stock/domain/usecases/customers/get_customers.dart';
import 'package:stock/domain/usecases/delivery/get_delivery_usecase.dart';
import 'package:stock/domain/usecases/delivery/register_delivery_usecase.dart';
import 'package:stock/presentation/pages/sales/delivery/delivery_dialog.dart';
import '../../../../core/events/event_bus.dart';
import '../../../../data/model/delivery.dart';
import '../../../../domain/usecases/sales/update_sale_use_case.dart';
import '../../../../domain/usecases/sales/get_all_sales_use_case.dart';
import '../../products/list/categories/product_category_list_intent.dart';
import 'sales_report_intent.dart';
import 'sales_report_state.dart';

@injectable
class SalesReportViewModel {
  final GetAllSalesUseCase _getAllSalesUseCase;
  final UpdateSaleUseCase _updateSaleUseCase;
  final GetCustomers _getCustomersUseCase;
  final RegisterDeliveryUseCase _registerDeliveryUseCase;
  final GetDeliveryUseCase _getDeliveryUseCase;
  final EventBus _eventBus;
  final _stateController = BehaviorSubject<SalesReportState>();

  Stream<SalesReportState> get state => _stateController.stream;

  SalesReportViewModel(
    this._getAllSalesUseCase,
    this._updateSaleUseCase,
    this._getCustomersUseCase,
    this._registerDeliveryUseCase,
    this._getDeliveryUseCase,
    this._eventBus,
  ) {
    _init();
    _listenToEvents();
  }

  void _init() {
    handleIntent(LoadSalesReportIntent());
  }

  void handleIntent(SalesReportIntent intent) {
    if (intent is LoadSalesReportIntent) {
      _loadReport();
    } else if (intent is CancelSaleIntent) {
      _cancelSale(intent.saleId, intent.reason);
    }
  }

  Future<Customer?> getCustomerById(String id) async {
    final allCustomers = await _getCustomersUseCase();
    return allCustomers.firstWhereOrNull((customer) => customer.id == id);
  }

  Future<void> _listenToEvents() async {
    _eventBus.stream.listen((event) async {
      if (event is SalesEvent) {
        print("Evento recebido: $event");
        _stateController  .add(SalesReportLoading());
        await Future.delayed(const Duration(seconds: 1));
        _loadReport();
        print("Evento recebido DEI LOAD NA PAGINA: $event");
      }
    });
  }

  Future<void> onRegisterDelivery(String saleId, DeliveryData data) async {
    print("saleId $saleId data $data");
    await _registerDeliveryUseCase(
      DeliveryParams(saleId: saleId, data: data),
    );
    _eventBus.fire(SalesEvent());
  }

  Future<DeliveryData?> fetchDeliveryData(String saleId) async {
    return await _getDeliveryUseCase(saleId);
  }

  // ===============================================================
  // 1. SANITIZAÇÃO DOS CAMPOS NULL
  // ===============================================================
  List<Sale> _sanitizeSales(List<Sale> rawSales) {
    return rawSales.map((sale) {
      return sale.copyWith(
        globalDiscount: sale.globalDiscount ?? 0,
        globalDescription: sale.globalDescription ?? '',
      );
    }).toList();
  }

  // ===============================================================
  // 2. CARREGA RELATÓRIO COM TODOS OS AJUSTES
  // ===============================================================
  Future<void> _loadReport() async {
    _stateController.add(SalesReportLoading());

    try {
      // --- PRINT 1: BUSCANDO TODAS AS VENDAS ---
      print("--- [1] BUSCANDO TODAS AS VENDAS ---");
      final rawSales = await _getAllSalesUseCase();
      final allSales = _sanitizeSales(rawSales); // ← SANITIZA AQUI
      print("Total de vendas encontradas: ${allSales.length}");
      allSales.forEach((sale) => print(
          " - Venda ID: ${sale.id}, Data: ${sale.saleDate}, Valor: ${sale.totalAmount}, Vendedor: ${sale.sellerName}, Desconto: ${sale.globalDiscount}%"));

      print("--------------------------------------\n");

      final salesByYear = groupBy(allSales, (Sale sale) => sale.saleDate.year);
      final List<YearlySales> yearlySalesList = [];

      // --- PRINT 2: AGRUPANDO POR ANO ---
      print("--- [2] AGRUPANDO VENDAS POR ANO ---");
      print("Anos encontrados: ${salesByYear.keys.toList()}");
      print("------------------------------------\n");

      salesByYear.forEach((year, yearSales) {
        print("--- [3] PROCESSANDO ANO: $year ---");
        print(" - Total de vendas neste ano: ${yearSales.length}");

        final yearTotal =
            yearSales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
        print(" - Valor total para o ano $year: $yearTotal");

        final salesByMonth =
            groupBy(yearSales, (Sale sale) => sale.saleDate.month);
        final List<MonthlySales> monthlySalesList = [];

        print(" - Meses encontrados: ${salesByMonth.keys.toList()}");
        print("-------------------------------------\n");

        salesByMonth.forEach((month, monthSales) {
          print(" --- [4] PROCESSANDO MÊS: $month/$year ---");
          print(" - Total de vendas neste mês: ${monthSales.length}");

          final monthTotal =
              monthSales.fold<double>(0, (sum, sale) => sum + sale.totalAmount);
          print(" - Valor total para o mês $month: $monthTotal");

          final Map<String, double> sellerSalesMap = {};
          for (var sale in monthSales) {
            sellerSalesMap.update(
              sale.sellerName,
              (value) => value + sale.totalAmount,
              ifAbsent: () => sale.totalAmount,
            );
          }

          print(" - Desempenho dos vendedores no mês $month:");
          sellerSalesMap.forEach((seller, total) {
            print("   • $seller: R\$$total");
          });

          final sellerPerformances = sellerSalesMap.entries.map((entry) {
            return SellerMonthlyPerformance(
              sellerName: entry.key,
              totalSold: entry.value,
            );
          }).toList()
            ..sort((a, b) => b.totalSold.compareTo(a.totalSold));

          print(" - Performance ORDENADA:");
          sellerPerformances.forEach((perf) {
            print("   • ${perf.sellerName}: R\$${perf.totalSold}");
          });

          monthlySalesList.add(MonthlySales(
            month: month,
            totalAmount: monthTotal,
            sales: monthSales,
            sellerPerformances: sellerPerformances,
          ));

          print(" ------------------------------------------\n");
        });

        // Ordena meses do mais recente para o mais antigo
        monthlySalesList.sort((a, b) => b.month.compareTo(a.month));

        yearlySalesList.add(YearlySales(
          year: year,
          totalAmount: yearTotal,
          monthlySales: monthlySalesList,
        ));
      });

      // Ordena anos do mais recente para o mais antigo
      yearlySalesList.sort((a, b) => b.year.compareTo(a.year));

      // --- PRINT FINAL: DADOS PRONTOS ---
      print("\n--- [FINAL] DADOS PROCESSADOS PRONTOS PARA UI ---");
      print("Total de anos: ${yearlySalesList.length}");
      for (var yearData in yearlySalesList) {
        print(" • Ano ${yearData.year}: R\$${yearData.totalAmount}");
        for (var monthData in yearData.monthlySales) {
          print(
              "   ├─ Mês ${monthData.month}: R\$${monthData.totalAmount} (${monthData.sales.length} vendas)");
          if (monthData.sellerPerformances.isNotEmpty) {
            print(
                "   └─ Top vendedor: ${monthData.sellerPerformances.first.sellerName}");
          }
        }
      }
      print(
          "---------------------------------------------------------------------\n");

      _stateController.add(SalesReportLoaded(yearlySales: yearlySalesList));
    } catch (e, stackTrace) {
      print("--- [ERRO] FALHA AO CARREGAR RELATÓRIO ---");
      print("Erro: $e");
      print("Stack: $stackTrace");
      print("----------------------------------------------------------\n");
      _stateController
          .add(SalesReportError("Erro ao gerar relatório: ${e.toString()}"));
    }
  }

  // ===============================================================
  // CANCELAR VENDA
  // ===============================================================
  Future<void> _cancelSale(String saleId, String reason) async {
    final currentState = _stateController.value;
    if (currentState is! SalesReportLoaded) return;

    try {
      final allSales = _sanitizeSales(await _getAllSalesUseCase());
      final saleToCancel = allSales.firstWhere((sale) => sale.id == saleId);

      final updatedSale = saleToCancel.copyWith(
        isCanceled: true,
        cancelReason: reason,
      );

      await _updateSaleUseCase(updatedSale);
      _loadReport();
    } catch (e) {
      _stateController
          .add(SalesReportError("Erro ao cancelar venda: ${e.toString()}"));
    }
  }


  void dispose() {
    _stateController.close();
  }
}
