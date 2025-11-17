import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stock/presentation/pages/sales/timelines/timeline_sale_card.dart';

import '../../../../domain/entities/sale/month_sales.dart';
import '../../../../domain/entities/sale/sale.dart';

class TimelineMonthBlock extends StatelessWidget {
  final String month;
  final MonthlySales data;
  final NumberFormat currency;
  final DateFormat date;

  final void Function(Sale) onProfile;
  final void Function(Sale) onHistory;
  final void Function(Sale) onCancel;
  final Future<void> Function(Sale) onRegisterDelivery;

  const TimelineMonthBlock({
    required this.month,
    required this.data,
    required this.currency,
    required this.date,
    required this.onProfile,
    required this.onHistory,
    required this.onCancel,
    required this.onRegisterDelivery,
    super.key,
  });

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
                        onRegisterDelivery: onRegisterDelivery,
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