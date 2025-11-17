import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/sale/month_sales.dart';
import 'package:stock/domain/entities/sale/sale.dart';
import 'package:stock/domain/entities/sale/sale_item.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/presentation/pages/sales/report/sales_report_state.dart';
import 'package:stock/presentation/pages/sales/report/sales_report_view_model.dart';
import 'package:stock/presentation/pages/sales/report/sales_report_intent.dart';

// ===============================================================
// PAGE
// ===============================================================
class SalesReportPage extends StatefulWidget {
  const SalesReportPage({super.key});

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage>
    with TickerProviderStateMixin {
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

  // ===============================================================
  // POPUP PERFIL
  // ===============================================================
  Future<void> _openCustomerProfile(Sale sale) async {
    final Customer customer = await _viewModel.getCustomerById(sale.customerId);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                      color: Colors.white, fontWeight: FontWeight.bold),
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
                  if (customer.instagram != null)
                    _infoTile("Instagram", customer.instagram!),
                  if (customer.notes != null)
                    _infoTile("Notas", customer.notes!),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Fechar", style: GoogleFonts.poppins(color: Colors.deepPurple)),
            )
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
                  color: Colors.deepPurple.shade700, fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade800)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Row(
            children: [
              const Icon(Icons.receipt_long, color: Colors.deepPurple, size: 26),
              const SizedBox(width: 10),
              Text("Histórico da Venda",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 19)),
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
                          const Icon(Icons.discount, color: Colors.green, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Desconto global: ${sale.globalDiscount}%\n${sale.globalDescription ?? ''}",
                              style: GoogleFonts.poppins(fontSize: 13.5, color: Colors.green.shade800),
                            ),
                          ),
                        ],
                      ),
                    ),

                  ...sale.items.map((SaleItem item) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 1,
                      child: ListTile(
                        leading: const Icon(Icons.inventory_2_outlined, color: Colors.deepPurple),
                        title: Text(item.productName,
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${item.quantity}x ${_currency.format(item.pricePerUnit)}",
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
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.deepPurple),
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
              child: Text("Fechar", style: GoogleFonts.poppins(color: Colors.deepPurple)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Text("Cancelar Venda",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 19)),
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
                child: Text("Voltar", style: GoogleFonts.poppins(color: Colors.grey.shade700))),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  _viewModel.handleIntent(
                    CancelSaleIntent(sale.id, controller.text.trim()),
                  );
                  Navigator.pop(ctx);
                }
              },
              child: Text("Confirmar Cancelamento", style: GoogleFonts.poppins(color: Colors.white)),
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
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
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
                      style: GoogleFonts.poppins(color: Colors.red, fontSize: 16)),
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
                    const Icon(Icons.receipt_long, size: 90, color: Colors.grey),
                    const SizedBox(height: 20),
                    Text("Nenhuma venda registrada ainda.",
                        style: GoogleFonts.poppins(fontSize: 17, color: Colors.grey.shade700)),
                    const SizedBox(height: 8),
                    Text("As vendas aparecerão aqui em uma linha do tempo.",
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade500)),
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

// ===============================================================
// TIMELINE YEAR BLOCK
// ===============================================================
class TimelineYearBlock extends StatefulWidget {
  final int year;
  final double total;
  final List<MonthlySales> months;
  final String Function(int) monthName;
  final NumberFormat currency;
  final DateFormat date;

  final void Function(Sale) onProfile;
  final void Function(Sale) onHistory;
  final void Function(Sale) onCancel;

  const TimelineYearBlock({
    required this.year,
    required this.total,
    required this.months,
    required this.monthName,
    required this.currency,
    required this.date,
    required this.onProfile,
    required this.onHistory,
    required this.onCancel,
    Key? key,
  }) : super(key: key);

  @override
  State<TimelineYearBlock> createState() => _TimelineYearBlockState();
}

class _TimelineYearBlockState extends State<TimelineYearBlock>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: ScaleTransition(
        scale: _animation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline Line + Year Dot
              Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.deepPurple.shade600, Colors.deepPurple.shade800],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.year.toString(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 3,
                    height: 80 + (widget.months.length * 140),
                    color: Colors.deepPurple.shade200,
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total do Ano
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.deepPurple.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.trending_up, color: Colors.deepPurple, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Total do Ano",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const Spacer(),
                          Text(
                            widget.currency.format(widget.total),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple.shade700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Meses
                    ...widget.months.map((m) {
                      return TimelineMonthBlock(
                        month: widget.monthName(m.month),
                        data: m,
                        currency: widget.currency,
                        date: widget.date,
                        onProfile: widget.onProfile,
                        onHistory: widget.onHistory,
                        onCancel: widget.onCancel,
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// TIMELINE MONTH BLOCK
// ===============================================================
class TimelineMonthBlock extends StatelessWidget {
  final String month;
  final MonthlySales data;
  final NumberFormat currency;
  final DateFormat date;

  final void Function(Sale) onProfile;
  final void Function(Sale) onHistory;
  final void Function(Sale) onCancel;

  const TimelineMonthBlock({
    required this.month,
    required this.data,
    required this.currency,
    required this.date,
    required this.onProfile,
    required this.onHistory,
    required this.onCancel,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Dot
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.deepPurple.shade400,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Month Card
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              shadowColor: Colors.deepPurple.withOpacity(0.15),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.deepPurple.shade50.withOpacity(0.3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, color: Colors.deepPurple, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          month,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            currency.format(data.totalAmount),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.deepPurple.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Vendas do mês
                    ...data.sales.map((sale) => Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: TimelineSaleCard(
                        sale: sale,
                        currency: currency,
                        date: date,
                        onProfile: () => onProfile(sale),
                        onHistory: () => onHistory(sale),
                        onCancel: () => onCancel(sale),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// TIMELINE SALE CARD
// ===============================================================
class TimelineSaleCard extends StatelessWidget {
  final Sale sale;
  final NumberFormat currency;
  final DateFormat date;

  final VoidCallback onProfile;
  final VoidCallback onHistory;
  final VoidCallback onCancel;

  const TimelineSaleCard({
    required this.sale,
    required this.currency,
    required this.date,
    required this.onProfile,
    required this.onHistory,
    required this.onCancel,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool canceled = sale.isCanceled == true;

    print(
      "TimelineSaleCard: $sale\n"
      "sale.globalDiscount: ${sale.globalDiscount}\n"
      "onProfile: $onProfile\n"
      "onHistory: $onHistory\n",

    );
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: canceled ? Colors.grey.shade200 : Colors.blue.shade50.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: canceled ? Colors.grey.shade400 : Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Hero(
            tag: "avatar_${sale.id}",
            child: CircleAvatar(
              radius: 20,
              backgroundColor: canceled ? Colors.grey : Colors.blue.shade600,
              child: Text(
                sale.customerName.substring(0, 1).toUpperCase(),
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sale.customerName,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    decoration: canceled ? TextDecoration.lineThrough : null,
                    color: canceled ? Colors.grey.shade600 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date.format(sale.saleDate),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: canceled ? Colors.grey.shade500 : Colors.grey.shade700,
                    decoration: canceled ? TextDecoration.lineThrough : null,
                  ),
                ),
                if ((sale.globalDiscount ?? 0) > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "−${sale.globalDiscount}%",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Valor + Ações
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currency.format(sale.totalAmount),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: canceled ? Colors.grey.shade600 : Colors.deepPurple.shade700,
                  decoration: canceled ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _ActionButton(
                    icon: Icons.person_outline,
                    tooltip: "Perfil",
                    onPressed: onProfile,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(width: 4),
                  _ActionButton(
                    icon: Icons.receipt_long,
                    tooltip: "Histórico",
                    onPressed: onHistory,
                    color: Colors.deepPurple,
                  ),
                  if (!canceled) ...[
                    const SizedBox(width: 4),
                    _ActionButton(
                      icon: Icons.cancel,
                      tooltip: "Cancelar",
                      onPressed: onCancel,
                      color: Colors.red.shade600,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}