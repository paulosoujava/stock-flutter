// sales_report_view_model.dart
import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
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
import '../../../../core/di/injection.dart';
import '../../../../core/events/event_bus.dart';
import '../../../../data/model/delivery.dart';
import '../../../../domain/repositories/icustomer_repository.dart';
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
    _listenToEvents();
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

  Future<Customer?> getCustomerByIdOrInstagram(String id, String instagram) async {
    final customerRepo = getIt<ICustomerRepository>();
    return customerRepo.getCustomersByIdOrInstagram(id, instagram);
  }

  Future<void> _listenToEvents() async {
    _eventBus.stream.listen((event) async {
      if (event is SalesEvent) {

        _stateController  .add(SalesReportLoading());
        await Future.delayed(const Duration(seconds: 1));
        _loadReport();

      }
    });
  }



  Future<void> onRegisterDelivery(String saleId, DeliveryData data) async {
    print("OnRegisterDelivery: , $data");
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
    // 1. Emite Loading imediatamente (UI mostra spinner na hora)
    _stateController.add(SalesReportLoading());

    try {
      // 2. Busca as vendas e sanitiza
      final rawSales = await _getAllSalesUseCase();
      final allSales = _sanitizeSales(rawSales);  // ← Agora pode acessar porque não é static

      // 3. Processamento pesado em isolate (não trava a UI)
      final yearlySalesList = await compute(_processSalesDataIsolated, allSales);

      // 4. Emite os dados prontos
      _stateController.add(SalesReportLoaded(yearlySales: yearlySalesList));
    } catch (e, stackTrace) {
      print("--- [ERRO] FALHA AO CARREGAR RELATÓRIO ---");
      print("Erro: $e");
      print("Stack: $stackTrace");
      _stateController.add(SalesReportError("Erro ao gerar relatório: ${e.toString()}"));
    }
  }

// ==============================================================
// FUNÇÃO ISOLADA PARA O COMPUTE (NÃO PODE SER STATIC NEM USAR INSTÂNCIA)
// ==============================================================
  static List<YearlySales> _processSalesDataIsolated(List<Sale> allSales) {
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
          sellerSalesMap.update(
            sale.sellerName,
                (value) => value + sale.totalAmount,
            ifAbsent: () => sale.totalAmount,
          );
        }

        final sellerPerformances = sellerSalesMap.entries
            .map((e) => SellerMonthlyPerformance(sellerName: e.key, totalSold: e.value))
            .toList()
          ..sort((a, b) => b.totalSold.compareTo(a.totalSold));

        monthlySalesList.add(MonthlySales(
          month: month,
          totalAmount: monthTotal,
          sales: monthSales,
          sellerPerformances: sellerPerformances,
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

    return yearlySalesList;
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
