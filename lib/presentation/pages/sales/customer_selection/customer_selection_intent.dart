abstract class CustomerSelectionIntent {}

class LoadAllCustomersIntent extends CustomerSelectionIntent {}

class FilterCustomersIntent extends CustomerSelectionIntent {
  final String query;
  FilterCustomersIntent(this.query);
}
