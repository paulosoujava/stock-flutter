import 'package:stock/domain/entities/sale/sale.dart';

class SellerMonthlyPerformance {
  final String sellerName;
  final double totalSold;

  SellerMonthlyPerformance({required this.sellerName, required this.totalSold});
}


// Classe para agrupar as vendas e o total de um mês
class MonthlySales {
  final int month;
  final double totalAmount;
  final List<Sale> sales;
  final List<SellerMonthlyPerformance> sellerPerformances;

  MonthlySales({
    required this.month,
    required this.totalAmount,
    required this.sales,
    required this.sellerPerformances,
  });

  MonthlySales copyWith({
    int? month,
    double? totalAmount,
    List<Sale>? sales,
  }) {
    return MonthlySales(
      month: month ?? this.month,
      totalAmount: totalAmount ?? this.totalAmount,
      sales: sales ?? this.sales,
      sellerPerformances: sellerPerformances
    );
  }
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

  YearlySales copyWith({
    int? year,
    double? totalAmount,
    List<MonthlySales>? monthlySales,
  }) {
    return YearlySales(
      year: year ?? this.year,
      totalAmount: totalAmount ?? this.totalAmount,
      monthlySales: monthlySales ?? this.monthlySales,
    );
  }
}


