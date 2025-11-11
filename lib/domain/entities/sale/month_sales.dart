import 'package:stock/domain/entities/sale/sale.dart';

// Classe para agrupar as vendas e o total de um mês
class MonthlySales {
  final int month;
  final double totalAmount;
  final List<Sale> sales;

  MonthlySales({
    required this.month,
    required this.totalAmount,
    required this.sales,
  });
}

// Classe para agrupar os meses e o total de um ano
class YearlySales {
  final int year;
  final double totalAmount;
  final List<MonthlySales> monthlySales;

  YearlySales({
    required this.year,
    required this.totalAmount,
    required this.monthlySales,
  });
}


