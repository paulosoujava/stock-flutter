// /lib/presentation/pages/sales/timelines/timeline_sale_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stock/data/model/delivery.dart';

import '../../../../core/di/injection.dart';
import '../../../../domain/entities/sale/sale.dart';
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
    // Só busca dados de entrega se não for uma venda na loja
    if (widget.sale.customerName.contains('@')) {
      _deliveryFuture = _viewModel.fetchDeliveryData(widget.sale.id);
    }
  }

  // --- FUNÇÕES HELPER ATUALIZADAS ---

  IconData _getIconForStatus(String? status, bool isStoreSale) {
    if (isStoreSale) {
      return Icons.storefront; // Ícone de loja
    }
    switch (status) {
      case 'Saiu para entrega':
        return Icons.local_shipping;
      case 'Entregue':
        return Icons.check_circle;
      case 'Retornou':
        return Icons.reply;
      default:
        return Icons.hourglass_bottom;
    }
  }

  Color _getBorderColorForStatus(String? status, bool isStoreSale) {
    if (isStoreSale) {
      return Colors.deepPurple.shade300; // Cor da loja
    }
    switch (status) {
      case 'Saiu para entrega':
        return Colors.indigo.shade700;
      case 'Entregue':
        return Colors.green.shade700;
      case 'Retornou':
        return Colors.red.shade700;

      default:
        return Colors.amber.shade700;
    }
  }

  Color _getBackgroundColorForStatus(String? status, bool isStoreSale) {
    if (isStoreSale) {
      return Colors.deepPurple.shade50; // Cor da loja
    }
    switch (status) {
      case 'Saiu para entrega':
        return Colors.orange.shade50;
      case 'Entregue':
        return Colors.green.shade50;
      case 'Retornou':
        return Colors.red.shade50;
      case 'Pendente':
        return Colors.blue.shade50;
      default:
        return Colors.blue.shade50.withOpacity(0.7);
    }
  }
  // --- FIM DAS FUNÇÕES HELPER ---

  @override
  Widget build(BuildContext context) {
    final bool canceled = widget.sale.isCanceled == true;
    final bool isStoreSale = !widget.sale.customerName.contains('@');

    // Se for uma venda na loja, não precisamos do FutureBuilder para o design
    if (isStoreSale) {
      return _buildCardContent(
        status: 'Venda na Loja',
        isStoreSale: true,
        canceled: canceled,
      );
    }

    // Para vendas online, usamos o FutureBuilder
    return FutureBuilder<DeliveryData?>(
      future: _deliveryFuture,
      builder: (context, snapshot) {
        final delivery = snapshot.data;
        final status = delivery?.status;
        return _buildCardContent(
          status: status,
          isStoreSale: false,
          canceled: canceled,
          snapshot: snapshot,
        );
      },
    );
  }

  // Widget unificado para construir o conteúdo do card
  Widget _buildCardContent({
    required String? status,
    required bool isStoreSale,
    required bool canceled,
    AsyncSnapshot<DeliveryData?>? snapshot,
  }) {
    final cardBorderColor = canceled ? Colors.grey.shade400 : _getBorderColorForStatus(status, isStoreSale);
    final cardBackgroundColor = canceled ? Colors.grey.shade200 : _getBackgroundColorForStatus(status, isStoreSale);
    final statusIcon = _getIconForStatus(status, isStoreSale);

    final delivery = snapshot?.data;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cardBorderColor,
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AVATAR
          Tooltip(
              message: delivery?.status ?? "Não registrado",
              child:CircleAvatar(
                radius: 20,
                backgroundColor: canceled ? Colors.grey : cardBorderColor,
                child: Icon(
                  canceled ? Icons.block : statusIcon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
          ),
          const SizedBox(width: 12),
          // INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.sale.customerName.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    decoration: canceled ? TextDecoration.lineThrough : null,
                    color: canceled ? Colors.grey.shade600 : Colors.black87,
                  ),
                ),
                Divider(
                  color: canceled ? Colors.grey.shade400 : cardBorderColor,
                  thickness: 1.2,
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
                    color: canceled ? Colors.grey.shade500 : Colors.grey.shade700,
                  ),
                ),
                if ((widget.sale.globalDiscount ?? 0) > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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

                // DELIVERY STATUS
                if (isStoreSale)
                  DeliveryStatusChip(status: 'Venda na Loja', isCanceled: canceled),

                if (!isStoreSale) ...[
                  if (snapshot?.connectionState == ConnectionState.waiting)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        "Carregando status...",
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  if (snapshot?.connectionState == ConnectionState.done)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DeliveryStatusChip(
                          status: status ?? "Não registrado",
                          isCanceled: canceled,
                        ),
                        if (delivery?.returnReason?.isNotEmpty ?? false)
                          Text(
                            "Motivo: ${delivery!.returnReason}",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                      ],
                    ),
                ],
              ],
            ),
          ),
          // VALOR + AÇÕES
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.currency.format(widget.sale.totalAmount),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: canceled ? Colors.grey.shade600 : cardBorderColor,
                  decoration: canceled ? TextDecoration.lineThrough : null,
                ),
              ),
              SizedBox(
                  width: 160,
                  child: Divider(
                    color: canceled ? Colors.grey.shade400 : cardBorderColor,
                    thickness: 1.2,
                  )
              ),
              Row(
                children: [
                  // Oculta o botão de entrega se for venda na loja
                  if (!isStoreSale && widget.sale.isCanceled == null)
                    ActionButton(
                      icon: Icons.delivery_dining,
                      tooltip: "Entrega",
                      onPressed: () => widget.onRegisterDelivery(widget.sale),
                      color: Colors.deepPurple,
                    ),
                  if (!isStoreSale) const SizedBox(width: 4),
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
