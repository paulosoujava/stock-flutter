
abstract class SalesReportIntent {}

class LoadSalesReportIntent extends SalesReportIntent {}
class LoadingReportIntent extends SalesReportIntent {}

class CancelSaleIntent extends SalesReportIntent {
  final String saleId;
  final String reason;
  CancelSaleIntent(this.saleId, this.reason);
}