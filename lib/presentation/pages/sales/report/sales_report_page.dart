import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/sale/month_sales.dart';
import 'package:stock/domain/entities/sale/sale.dart';
import 'package:stock/domain/entities/sale/sale_item.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/presentation/pages/sales/delivery/delivery_dialog.dart'; // Corrigido para 'delivery_dialog.dart' (assumindo nome correto)
import 'package:stock/presentation/pages/sales/report/sales_report_state.dart';
import 'package:stock/presentation/pages/sales/report/sales_report_view_model.dart';
import 'package:stock/presentation/pages/sales/report/sales_report_intent.dart';

import '../../../../data/model/delivery.dart';
import '../timelines/timeline_year_block.dart';

// ===============================================================
// PAGE
// ===============================================================
class SalesReportPage extends StatefulWidget {
  const SalesReportPage({super.key});

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage>{

  late final SalesReportViewModel _viewModel;

  final NumberFormat _currency = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  final DateFormat _date = DateFormat('dd/MM/yyyy - HH:mm');

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<SalesReportViewModel>();


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


  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  // ===============================================================
  //  DELIVERY
  // ===============================================================
  Future<void> _openDeliveryDialog(Sale sale) async {
    final Customer? customer =
        await _viewModel.getCustomerById(sale.customerId);
    print("CUSTOMER: $customer e sales $sale");
    final DeliveryData? delivery = await _viewModel.fetchDeliveryData(sale.id);

    print("DELIVERY: $delivery");

    _viewModel.getCustomerById(sale.customerId);
    if (customer == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Cliente não encontrado. Usando dados básicos da venda."),
          backgroundColor: Colors.orange,
        ),
      );
    }

    await showDialog<DeliveryData>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeliveryDialog(
        customer: customer,
        deliveryToEdit: delivery,
        onConfirm: (data) async {
          print("DATA: $data");
          await _viewModel.onRegisterDelivery(sale.id, data);
          Navigator.pop(context);
        },
      ),
    );
  }

  // ===============================================================
  // POPUP PERFIL
  // ===============================================================
  Future<void> _openCustomerProfile(Sale sale) async {
    final Customer? customer =
        await _viewModel.getCustomerById(sale.customerId);

    if (!mounted) return;

    if (customer == null) {
      // Cliente foi excluído ou não existe mais
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          icon: Icon(Icons.person_off, size: 48, color: Colors.orange.shade700),
          title: Text(
            "Cliente não encontrado",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.orange.shade800,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "O cliente \"${sale.customerName}\" foi removido do sistema ou não está mais disponível.",
                style: GoogleFonts.poppins(
                    fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),
              Text(
                "Ainda assim, a venda continua registrada com o nome salvo na época.",
                style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                "Entendido",
                style: GoogleFonts.poppins(
                    color: Colors.deepPurple, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
      return;
    }

    // Cliente encontrado → mostra perfil completo
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.deepPurple.shade600,
                child: Text(
                  sale.customerName.substring(0, 1).toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  sale.customerName,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoTile("Email", customer.email),
                  _infoTile("CPF", customer.cpf),
                  _infoTile("Telefone", customer.phone),
                  _infoTile("WhatsApp", customer.whatsapp),
                  _infoTile("Endereço", customer.address),
                  if (customer.address1.isNotEmpty)
                    _infoTile("Endereço 2", customer.address1),
                  if (customer.address2.isNotEmpty)
                    _infoTile("Endereço 3", customer.address2),
                  if (customer.instagram != null &&
                      customer.instagram!.isNotEmpty)
                    _infoTile("Instagram", customer.instagram!),
                  if (customer.notes != null && customer.notes!.isNotEmpty)
                    _infoTile("Notas", customer.notes!),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                "Fechar",
                style: GoogleFonts.poppins(color: Colors.deepPurple),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  color: Colors.deepPurple.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 14, color: Colors.grey.shade800)),
        ],
      ),
    );
  }

  // ===============================================================
  // POPUP HISTÓRICO
  // ===============================================================
  void _openSaleHistory(Sale sale) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Row(
            children: [
              const Icon(Icons.receipt_long,
                  color: Colors.deepPurple, size: 26),
              const SizedBox(width: 10),
              Text("Histórico da Venda",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 19)),
            ],
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.75,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if ((sale.globalDiscount ?? 0) > 0)
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green.shade50, Colors.green.shade100],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.discount,
                              color: Colors.green, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Desconto global: ${sale.globalDiscount}%\n${sale.globalDescription ?? ''}",
                              style: GoogleFonts.poppins(
                                  fontSize: 13.5, color: Colors.green.shade800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ...sale.items.map((SaleItem item) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 1,
                      child: ListTile(
                        leading: const Icon(Icons.inventory_2_outlined,
                            color: Colors.deepPurple),
                        title: Text(item.productName,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "${item.quantity}x ${_currency.format(item.pricePerUnit)}",
                                style: GoogleFonts.poppins(fontSize: 13)),
                            if ((item.discount ?? 0) > 0)
                              Text(
                                "Desconto: ${item.discount}%",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                        trailing: Text(
                          _currency.format(item.quantity * item.pricePerUnit),
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Fechar",
                  style: GoogleFonts.poppins(color: Colors.deepPurple)),
            )
          ],
        );
      },
    );
  }

  // ===============================================================
  // POPUP CANCELAMENTO
  // ===============================================================
  void _openCancelDialog(Sale sale) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Text("Cancelar Venda",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 19)),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Motivo do cancelamento",
                labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.deepPurple),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text("Voltar",
                    style: GoogleFonts.poppins(color: Colors.grey.shade700))),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  _viewModel.handleIntent(
                    CancelSaleIntent(sale.id, controller.text.trim()),
                  );
                  Navigator.pop(ctx);
                }
              },
              child: Text("Confirmar Cancelamento",
                  style: GoogleFonts.poppins(color: Colors.white)),
            )
          ],
        );
      },
    );
  }



  // ===============================================================
  // BUILD
  // ===============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: StreamBuilder<SalesReportState>(
        stream: _viewModel.state,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state == null || state is SalesReportLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple));
          }

          if (state is SalesReportError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 70, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message,
                      textAlign: TextAlign.center,
                      style:
                          GoogleFonts.poppins(color: Colors.red, fontSize: 16)),
                ],
              ),
            );
          }

          if (state is SalesReportLoaded) {
            if (state.yearlySales.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt_long,
                        size: 90, color: Colors.grey),
                    const SizedBox(height: 20),
                    Text("Nenhuma venda registrada ainda.",
                        style: GoogleFonts.poppins(
                            fontSize: 17, color: Colors.grey.shade700)),
                    const SizedBox(height: 8),
                    Text("As vendas aparecerão aqui em uma linha do tempo.",
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.grey.shade500)),
                  ],
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverPadding(padding: const EdgeInsets.all(16)),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final year = state.yearlySales[i];
                      return TimelineYearBlock(
                        year: year.year,
                        total: year.totalAmount,
                        months: year.monthlySales,
                        monthName: _monthName,
                        currency: _currency,
                        date: _date,
                        onProfile: _openCustomerProfile,
                        onHistory: _openSaleHistory,
                        onCancel: _openCancelDialog,
                        onRegisterDelivery:
                            _openDeliveryDialog, // ← Corrigido: passa o novo método
                      );
                    },
                    childCount: state.yearlySales.length,
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
