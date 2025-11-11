import 'package:flutter/material.dart';

import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/sale/sale.dart';
import 'package:stock/domain/entities/sale/sale_item.dart';
import 'package:intl/intl.dart';
import 'package:stock/presentation/pages/sales/report/sales_report_state.dart';

import 'sales_report_view_model.dart';

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({super.key});

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  late final SalesReportViewModel _viewModel;
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<SalesReportViewModel>();
  }

  String _getMonthName(int month) {
    const monthNames = ["", "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"];
    return monthNames[month];
  }

  void _showItemDetailsDialog(SaleItem item, List<Sale> sales) {
    // Encontra todos os compradores daquele item específico
    final buyers = sales.where((sale) => sale.items.any((saleItem) => saleItem.productId == item.productId)).map((sale) => sale.customerName).toSet().toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text('Este item foi comprado por ${buyers.length} cliente(s) neste mês:'),
              const SizedBox(height: 8),
              ...buyers.map((name) => Text('- $name')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('FECHAR')),
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
              return const Center(
                  child: Text('Nenhuma venda registrada ainda.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8), // Padding geral da lista
              itemCount: state.yearlySales.length,
              itemBuilder: (context, yearIndex) {
                final yearData = state.yearlySales[yearIndex];
                return Card(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: ExpansionTile(
                    title: Text('${yearData.year}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        'Total Anual: ${_currencyFormat.format(yearData.totalAmount)}'),
                    children: yearData.monthlySales.map((monthData) {
                      return ExpansionTile(
                        title: Text(_getMonthName(monthData.month),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            'Total Mensal: ${_currencyFormat.format(monthData.totalAmount)}'),
                        // AQUI ESTÁ A EXIBIÇÃO DA NOVA SEÇÃO
                        children: [
                          // -- Seção de Vendas por Vendedor --
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Vendas por Vendedor:', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                ...monthData.sellerPerformances.map((perf) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(perf.sellerName),
                                      Text(_currencyFormat.format(perf.totalSold)),
                                    ],
                                  );
                                }),
                                const Divider(height: 20),
                              ],
                            ),
                          ),
                          // -- Seção de Vendas Detalhadas --
                          ...monthData.sales.map((sale) {
                            return ExpansionTile(
                              leading: const Icon(Icons.receipt_long),
                              title: Text(sale.customerName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_dateFormat.format(sale.saleDate)),
                                ],
                              ),
                              trailing: Text(
                                  _currencyFormat.format(sale.totalAmount),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              children: sale.items.map((item) {
                                return ListTile(
                                  leading:
                                  const Icon(Icons.inventory_2_outlined),
                                  title: Text(item.productName),
                                  subtitle: Text(
                                      '${item.quantity} x ${_currencyFormat.format(item.pricePerUnit)}'),
                                  trailing: Text(
                                      _currencyFormat.format(item.totalPrice)),
                                  onTap: () => _showItemDetailsDialog(
                                      item, monthData.sales),
                                );
                              }).toList(),
                            );
                          }).toList(),
                        ],
                      );
                    }).toList(),
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
