// presentation/pages/sales/report/sales_report_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/sale/month_sales.dart';
import 'package:stock/domain/entities/sale/sale.dart';
import 'package:stock/presentation/pages/sales/delivery/delivery_dialog.dart';
import 'package:stock/presentation/pages/sales/report/sales_report_state.dart';
import 'package:stock/presentation/pages/sales/report/sales_report_view_model.dart';
import 'package:stock/presentation/pages/sales/report/sales_report_intent.dart';

import '../../../../core/events/event_bus.dart';
import '../../../../data/model/delivery.dart';
import '../../../../domain/entities/customer/customer.dart';
import '../../../widgets/dialog_customer_details.dart';
import '../../live/list/pop_ups/pop_ups.dart';
import '../timelines/timeline_year_block.dart';

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({super.key});

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  late final SalesReportViewModel _viewModel;

  final NumberFormat _currency =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final DateFormat _date = DateFormat('dd/MM/yyyy - HH:mm');
  StreamSubscription? _tempCustomerSavedSubscription;

  // FILTRO LOCAL — ÚNICA COISA ADICIONADA
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<SalesReportViewModel>();
    _viewModel.handleIntent(LoadSalesReportIntent());

    final eventBus = getIt<EventBus>();
    _tempCustomerSavedSubscription = eventBus.stream.listen((event) {
      if (event is RegisterEvent) {
        _viewModel.handleIntent(LoadSalesReportIntent());
      }
    });
  }

  @override
  void dispose() {
    _tempCustomerSavedSubscription?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  String _monthName(int m) {
    const names = [
      "",
      "Janeiro",
      "Fevereiro",
      "Março",
      "Abril",
      "Maio",
      "Junho",
      "Julho",
      "Agosto",
      "Setembro",
      "Outubro",
      "Novembro",
      "Dezembro"
    ];
    return names[m];
  }

  // ===============================================================
  // POPUP PERFIL
  // ===============================================================
  Future<void> _openCustomerProfile(Sale sale) async {
    final Customer? customer = await _viewModel.getCustomerByIdOrInstagram(
        sale.customerId, sale.customerName);
    print("CUSTOMER : $customer e sales $sale");
    if (!mounted) return;

    ///CLIENTE REGISTRADO TEMPORARIAMENTE NA LIVE
    if (sale.customerName.contains("@") && customer == null) {
      showCustomerNotRegistered(context, sale);

      ///CLIENTE NAO ENCONTRADO NO BANCO DE DADOS
    } else if (customer == null) {
      // Cliente foi excluído ou não existe mais
      showDeletedCustomer(context, sale);
    } else {
      /// PERFIL DO CLIENTE JÁ CADASTRADO NO BANCO
      showDialog(
          context: context,
          builder: (dialogContext) =>
              CustomerDetailsDialog(customer: customer!));
    }
  }

  // ===============================================================
  // POPUP HISTÓRICO
  // ===============================================================

  void _openSaleHistory(Sale sale) {
    openSaleHistory(context, sale, _currency);
  }

  Future<void> _openCancelDialog(Sale sale) async {
    final reasonController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cancelar Venda"),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: "Motivo"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _viewModel.handleIntent(CancelSaleIntent(sale.id, reasonController.text));
    }
  }

  Future<void> _openDeliveryDialog(Sale sale) async {
    final delivery = await _viewModel.fetchDeliveryData(sale.id);
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (_) => DeliveryDialog(
        customer: null,
        deliveryToEdit: delivery,
        onConfirm: (data) async {
          // NÃO USEI registerDelivery — SÓ RECARREGA O RELATÓRIO
          _viewModel.handleIntent(LoadSalesReportIntent());
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }

  // FILTRO — O QUE VOCÊ PEDIU
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.tune, size: 36, color: Colors.deepPurple),
        title: const Text("Filtrar por Status",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _filterOption("Todos os pedidos", Icons.filter_list_off, null),
            _filterOption("Pendente", Icons.hourglass_bottom, "Pendente",
                Colors.amber.shade700),
            _filterOption("Saiu para entrega", Icons.local_shipping,
                "Saiu para entrega", Colors.indigo.shade700),
            _filterOption("Entregue", Icons.check_circle, "Entregue",
                Colors.green.shade700),
            _filterOption(
                "Retornou", Icons.reply, "Retornou", Colors.red.shade700),
          ],
        ),
      ),
    );
  }

  Widget _filterOption(String title, IconData icon, String? value,
      [Color? color]) {
    final isSelected = _selectedFilter == value;
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey.shade600),
      title: Text(title),
      trailing:
          isSelected ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () {
        setState(() => _selectedFilter = value);
        Navigator.pop(context);
      },
    );
  }

  (IconData, Color) _getIconAndColorForFilter(String? filter) {
    switch (filter) {
      case "Pendente":
        return (Icons.hourglass_bottom, Colors.amber.shade700);
      case "Saiu para entrega":
        return (Icons.local_shipping, Colors.indigo.shade700);
      case "Entregue":
        return (Icons.check_circle, Colors.green.shade700);
      case "Retornou":
        return (Icons.reply, Colors.red.shade700);
      default: // "Todos os pedidos" ou nulo
        return (Icons.filter_list_off, Colors.grey.shade600);
    }
  }
  @override
  Widget build(BuildContext context) {
    final filterText = _selectedFilter ?? 'Todos os pedidos';
    final (filterIcon, filterColor) = _getIconAndColorForFilter(_selectedFilter);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        foregroundColor: Colors.black,
        title: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 16, // Tamanho base
              color: Colors.black,
            ),
            children: [
              // Parte 1: O texto "Filtro:"
              const TextSpan(
                text: 'Filtro: ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // --- INÍCIO DA MODIFICAÇÃO ---

              // Parte 2: O Ícone, inserido como um WidgetSpan
              WidgetSpan(
                alignment: PlaceholderAlignment.middle, // Alinha o ícone verticalmente
                child: Icon(
                  filterIcon,
                  color: filterColor,
                  size: 20, // Tamanho do ícone
                ),
              ),

              // Espaço entre o ícone e o texto
              const WidgetSpan(child: SizedBox(width: 8)),

              // Parte 3: O nome do filtro
              TextSpan(
                text: filterText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
              // --- FIM DA MODIFICAÇÃO ---
            ],
          ),
        ),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.tune, size: 28),
                onPressed: _showFilterDialog,
              ),
              if (_selectedFilter != null)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.redAccent, blurRadius: 6)
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: StreamBuilder<SalesReportState>(
        stream: _viewModel.state,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is SalesReportLoading || state == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SalesReportError) {
            return Center(child: Text(state.message));
          }
          if (state is SalesReportLoaded) {
            return FutureBuilder<List<YearlySales>>(
              future: () async {
                if (_selectedFilter == null) return state.yearlySales;

                final List<YearlySales> filtered = [];

                for (final year in state.yearlySales) {
                  final List<MonthlySales> newMonths = [];

                  for (final month in year.monthlySales) {
                    final List<Sale> newSales = [];

                    for (final sale in month.sales) {
                      final delivery =
                          await _viewModel.fetchDeliveryData(sale.id);
                      final status = delivery?.status ?? "Pendente";
                      if (status == _selectedFilter) {
                        newSales.add(sale);
                      }
                    }

                    if (newSales.isNotEmpty) {
                      newMonths.add(MonthlySales(
                        month: month.month,
                        totalAmount:
                            newSales.fold(0.0, (sum, s) => sum + s.totalAmount),
                        sales: newSales,
                        sellerPerformances: month.sellerPerformances,
                      ));
                    }
                  }

                  if (newMonths.isNotEmpty) {
                    filtered.add(YearlySales(
                      year: year.year,
                      totalAmount:
                          newMonths.fold(0.0, (sum, m) => sum + m.totalAmount),
                      monthlySales: newMonths,
                    ));
                  }
                }
                return filtered;
              }(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snap.data ?? [];

                if (data.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long,
                            size: 90, color: Colors.grey),
                        const SizedBox(height: 20),
                        Text(
                          _selectedFilter == null
                              ? "Nenhuma venda registrada ainda."
                              : 'Nenhuma venda com status "$_selectedFilter"',
                          style: GoogleFonts.poppins(
                              fontSize: 17, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  );
                }

                return CustomScrollView(
                  slivers: [
                    const SliverPadding(padding: EdgeInsets.all(16)),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => TimelineYearBlock(
                          year: data[i].year,
                          total: data[i].totalAmount,
                          months: data[i].monthlySales,
                          monthName: _monthName,
                          currency: _currency,
                          date: _date,
                          onProfile: _openCustomerProfile,
                          onHistory: _openSaleHistory,
                          onCancel: _openCancelDialog,
                          onRegisterDelivery: _openDeliveryDialog,
                        ),
                        childCount: data.length,
                      ),
                    ),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
                  ],
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
