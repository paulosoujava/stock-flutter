import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/sale/sale.dart';
import 'package:stock/domain/entities/sale/sale_item.dart';
import 'package:stock/presentation/pages/sales/report/sales_report_state.dart';
import 'package:stock/presentation/pages/sales/report/sales_report_view_model.dart';

import '../../../../core/di/app_module.dart';

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({super.key});

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  late final SalesReportViewModel _viewModel;
  final NumberFormat _currencyFormat =
  NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<SalesReportViewModel>();
  }

  String _getMonthName(int month) {
    const monthNames = [
      "", "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho",
      "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"
    ];
    return monthNames[month];
  }

  void _showItemDetailsDialog(SaleItem item, List<Sale> sales) {
    final buyers = sales
        .where((sale) =>
        sale.items.any((saleItem) => saleItem.productId == item.productId))
        .map((sale) => sale.customerName)
        .toSet()
        .toList();

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text(item.productName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text(
                      'Este item foi comprado por ${buyers.length} cliente(s) neste mês:'),
                  const SizedBox(height: 8),
                  ...buyers.map((name) => Text('- $name')),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('FECHAR')),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<SalesReportState>(
        stream: getIt.isRegistered<SalesReportViewModel>()
            ? _viewModel.state
            : const Stream.empty(),
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is SalesReportLoading || state == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SalesReportError) {
            return Center(child: Text(state.message));
          }
          if (state is SalesReportLoaded) {
            if (state.yearlySales.isEmpty) {
              return const Center(child: Text('Nenhuma venda registrada ainda.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.yearlySales.length,
              itemBuilder: (context, yearIndex) {
                final yearData = state.yearlySales[yearIndex];

                // ** O SEU LAYOUT DE TIMELINE FOI MANTIDO EXATAMENTE COMO ESTAVA **
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 2,
                            height: 20,
                            color: Colors.deepPurple,
                          ),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.deepPurple,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: 2,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${yearData.year}',
                                        style: const TextStyle(
                                            fontSize: 22, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.monetization_on, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Total Anual: ${_currencyFormat.format(yearData.totalAmount)}',
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                            // ** AQUI ESTÁ A ÚNICA MUDANÇA: O CONTAINER DO MÊS FOI TROCADO POR UM ExpansionTile **
                            ...yearData.monthlySales.map((monthData) {
                              return Theme(
                                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                child: Card(
                                  elevation: 1,
                                  margin: const EdgeInsets.only(top: 8, bottom: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  clipBehavior: Clip.antiAlias,
                                  child: ExpansionTile(
                                    key: PageStorageKey('${yearData.year}-${monthData.month}'),
                                    initiallyExpanded: false, // Começa contraído
                                    backgroundColor: Colors.grey[50],
                                    title: Text(_getMonthName(monthData.month), style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('Total Mensal: ${_currencyFormat.format(monthData.totalAmount)}'),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Vendedores:', style: TextStyle(fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 4),
                                            ...monthData.sellerPerformances.map((perf) {
                                              return Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(perf.sellerName.toUpperCase()),
                                                        Text(_currencyFormat.format(perf.totalSold), style: const TextStyle(fontWeight: FontWeight.bold)),
                                                      ],
                                                    ),
                                                  ),
                                                  Divider()
                                                ],
                                              );
                                            }),
                                            const SizedBox(height: 16),
                                            const Text("Clientes:", style: TextStyle(fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 4),
                                            ...monthData.sales.map((sale) {
                                              return Card(
                                                elevation: 1,
                                                color: Colors.white,
                                                margin: const EdgeInsets.symmetric(vertical: 4),
                                                child: ExpansionTile(
                                                  leading: const Icon(Icons.receipt_long),
                                                  title: Text(sale.customerName),
                                                  subtitle: Text(_dateFormat.format(sale.saleDate)),
                                                  trailing: Text(_currencyFormat.format(sale.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
                                                  children: sale.items.map((item) {
                                                    return ListTile(
                                                      leading: const Icon(Icons.inventory_2_outlined),
                                                      title: Text(item.productName),
                                                      subtitle: Text('${item.quantity} x ${_currencyFormat.format(item.pricePerUnit)}'),
                                                      trailing: Text(_currencyFormat.format(item.totalPrice)),
                                                      onTap: () => _showItemDetailsDialog(item, monthData.sales),
                                                    );
                                                  }).toList(),
                                                ),
                                              );
                                            }).toList(),
                                          ],
                                          ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 24), // Espaço entre os anos
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
