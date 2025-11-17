import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stock/data/model/delivery.dart';

import '../../../../core/di/injection.dart';
import '../../../../domain/entities/sale/month_sales.dart';
import '../../../../domain/entities/sale/sale.dart';
import '../delivery/delivery_dialog.dart';
import '../report/sales_report_view_model.dart';
import '../widgets/action_cars.dart';
import '../widgets/delivery_status_chip.dart';

class TimelineSaleCard extends StatefulWidget {
  final Sale sale;
  final NumberFormat currency;
  final DateFormat date;

  final VoidCallback onProfile;
  final VoidCallback onHistory;
  final VoidCallback onCancel;
  final Future<void> Function(Sale sale) onRegisterDelivery;

  const TimelineSaleCard({
    required this.sale,
    required this.currency,
    required this.date,
    required this.onProfile,
    required this.onHistory,
    required this.onCancel,
    required this.onRegisterDelivery,
    super.key,
  });

  @override
  State<TimelineSaleCard> createState() => _TimelineSaleCardState();
}

class _TimelineSaleCardState extends State<TimelineSaleCard> {
  late final SalesReportViewModel _viewModel;
  late Future<DeliveryData?> _deliveryFuture;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<SalesReportViewModel>();
    _deliveryFuture = _viewModel.fetchDeliveryData(widget.sale.id);
  }

  @override
  Widget build(BuildContext context) {
    final bool canceled = widget.sale.isCanceled == true;

    print(
      "TimelineSaleCard: ${widget.sale}\n"
      "sale.globalDiscount: ${widget.sale.globalDiscount}\n"
      "onProfile: ${widget.onProfile}\n"
      "onHistory: ${widget.onHistory}\n",
    );
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: canceled
            ? Colors.grey.shade200
            : Colors.blue.shade50.withOpacity(0.7),
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
            tag: "avatar_${widget.sale.id}",
            child: CircleAvatar(
              radius: 20,
              backgroundColor: canceled ? Colors.grey : Colors.blue.shade600,
              child: Text(
                widget.sale.customerName.substring(0, 1).toUpperCase(),
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.bold),
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
                  widget.sale.customerName,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    decoration: canceled ? TextDecoration.lineThrough : null,
                    color: canceled ? Colors.grey.shade600 : Colors.black87,
                  ),
                ),
                if (widget.sale.isCanceled == true)
                  Text(
                    "Pedido cancelado: ${widget.sale.cancelReason}",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                      color: canceled ? Colors.grey.shade600 : Colors.black87,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  widget.date.format(widget.sale.saleDate),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color:
                        canceled ? Colors.grey.shade500 : Colors.grey.shade700,
                  ),
                ),
                if ((widget.sale.globalDiscount ?? 0) > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${widget.sale.globalDescription} : ${widget.sale.globalDiscount}%",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                //DELIVERY
                FutureBuilder<DeliveryData?>(
                  future: _deliveryFuture,
                  // A Future que definimos no initState
                  builder: (context, snapshot) {
                    // Estado 1: Enquanto os dados estão carregando
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text(
                        "Delivery: Carregando...",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      );
                    }

                    // Estado 2: Após carregar, verifique se há dados
                    final delivery = snapshot.data;
                    final status = delivery?.status ?? "Não registrado";
                    final returnReason = delivery?.returnReason ?? "";

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DeliveryStatusChip(
                          status: status,
                          isCanceled: canceled,
                        ),
                        if(returnReason != "")
                        Text(
                          "Motivo da devolução: $returnReason",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: canceled
                                ? Colors.grey.shade500
                                : Colors.grey.shade700,
                            fontWeight: delivery != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        )
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Valor + Ações
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.currency.format(widget.sale.totalAmount),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: canceled
                      ? Colors.grey.shade600
                      : Colors.deepPurple.shade700,
                  decoration: canceled ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (widget.sale.isCanceled == null)
                    ActionButton(
                      icon: Icons.delivery_dining,
                      tooltip: "Entrega",
                      onPressed: () => widget.onRegisterDelivery(widget.sale),
                      color: Colors.deepPurple,
                    ),
                  const SizedBox(width: 4),
                  ActionButton(
                    icon: Icons.person_outline,
                    tooltip: "Perfil",
                    onPressed: widget.onProfile,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(width: 4),
                  ActionButton(
                    icon: Icons.receipt_long,
                    tooltip: "Histórico",
                    onPressed: widget.onHistory,
                    color: Colors.deepPurple,
                  ),
                  if (!canceled) ...[
                    const SizedBox(width: 4),
                    ActionButton(
                      icon: Icons.cancel,
                      tooltip: "Cancelar",
                      onPressed: widget.onCancel,
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
