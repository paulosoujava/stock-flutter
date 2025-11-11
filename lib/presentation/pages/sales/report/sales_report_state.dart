// Estados da tela de relatório
import 'package:stock/domain/entities/sale/month_sales.dart';

abstract class SalesReportState {}

class SalesReportInitial extends SalesReportState {}

class SalesReportLoading extends SalesReportState {}

class SalesReportError extends SalesReportState {
  final String message;
  SalesReportError(this.message);
}

class SalesReportLoaded extends SalesReportState {
  // A UI vai receber uma lista de anos já processada
  final List<YearlySales> yearlySales;

  SalesReportLoaded({required this.yearlySales});
}