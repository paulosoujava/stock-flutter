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
    return monthNames[month];
  }

  void _showItemDetailsDialog(SaleItem item, List<Sale> sales) {
    // Encontra todos os compradores daquele item específico
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
                      'Este item foi comprado por ${buyers
                          .length} cliente(s) neste mês:'),
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

  /*@override
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
                return Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent, // remove as linhas automáticas
                  ),
                  child:Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: ExpansionTile(
                      title: Text('${yearData.year}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      subtitle: Container(
                        color: Colors.grey[200],
                        padding: const EdgeInsets.all(18),
                        child: Text(
                            'Total Anual: ${_currencyFormat.format(yearData.totalAmount)}'),
                      ),
                      children: yearData.monthlySales.map((monthData) {
                        return ExpansionTile(
                          title: Text(_getMonthName(monthData.month),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          subtitle: Container(
                            color: Colors.grey[200],
                            padding: const EdgeInsets.all(18),
                            child: Text(
                                'Total Mensal: ${_currencyFormat.format(monthData.totalAmount)}'),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Vendedores:',
                                      style:
                                          TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  ...monthData.sellerPerformances.map((perf) {
                                    return Container(
                                      color: Colors.grey[200],
                                      padding: const EdgeInsets.all(18),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(perf.sellerName.toUpperCase()),
                                              Text(
                                                  _currencyFormat
                                                      .format(perf.totalSold),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  )),
                                            ],
                                          ),
                  
                  
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                                  child: Text("Clientes:",
                                      style:
                                          TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
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
                            }),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }*/

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
              padding: const EdgeInsets.all(16),
              itemCount: state.yearlySales.length,
              itemBuilder: (context, yearIndex) {
                final yearData = state.yearlySales[yearIndex];

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Linha vertical + marcador
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
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 20,
                          color: Colors.deepPurple,
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Ano
                              Text('${yearData.year}',
                                  style: const TextStyle(
                                      fontSize: 22, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(
                                'Total Anual: ${_currencyFormat.format(yearData.totalAmount)}',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 12),

                              // Meses
                              ...yearData.monthlySales.map((monthData) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getMonthName(monthData.month),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Total Mensal: ${_currencyFormat.format(monthData.totalAmount)}',
                                      ),
                                      const SizedBox(height: 8),

                                      // Vendedores
                                      const Text('Vendedores:',
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      ...monthData.sellerPerformances.map((perf) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(perf.sellerName.toUpperCase()),
                                              Text(
                                                _currencyFormat.format(perf.totalSold),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),

                                      const SizedBox(height: 8),
                                      const Text('Clientes:',
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),

                                      // Vendas
                                      ...monthData.sales.map((sale) {
                                        return Card(
                                          color: Colors.white,
                                          elevation: 1,
                                          margin: const EdgeInsets.symmetric(vertical: 4),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(sale.customerName,
                                                        style: const TextStyle(
                                                            fontWeight: FontWeight.bold)),
                                                    Text(
                                                      _currencyFormat.format(sale.totalAmount),
                                                      style: const TextStyle(
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                                Text(_dateFormat.format(sale.saleDate)),
                                                const SizedBox(height: 8),

                                                // Itens da venda
                                                ...sale.items.map((item) {
                                                  return GestureDetector(
                                                    onTap: () => _showItemDetailsDialog(
                                                        item, monthData.sales),
                                                    child: Container(
                                                      margin: const EdgeInsets.symmetric(
                                                          vertical: 2),
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        borderRadius:
                                                        BorderRadius.circular(6),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(item.productName),
                                                          Text(
                                                            '${item.quantity} x ${_currencyFormat.format(item.pricePerUnit)}',
                                                          ),
                                                          Text(
                                                            _currencyFormat.format(item.totalPrice),
                                                            style: const TextStyle(
                                                                fontWeight: FontWeight.bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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

