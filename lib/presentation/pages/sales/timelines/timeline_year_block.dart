import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stock/presentation/pages/sales/timelines/timeline_month_block.dart';

import '../../../../domain/entities/sale/month_sales.dart';
import '../../../../domain/entities/sale/sale.dart';

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
  final Future<void> Function(Sale) onRegisterDelivery;

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
    required this.onRegisterDelivery,
    super.key,
  });

  @override
  State<TimelineYearBlock> createState() => _TimelineYearBlockState();
}

class _TimelineYearBlockState extends State<TimelineYearBlock> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
                    colors: [
                      Colors.deepPurple.shade600,
                      Colors.deepPurple.shade800
                    ],
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.deepPurple.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up,
                          color: Colors.deepPurple, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Total do Ano",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 14),
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
                    onRegisterDelivery: widget
                        .onRegisterDelivery, // ← Passa diretamente (tipo alinhado)
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
