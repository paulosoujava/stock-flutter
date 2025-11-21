abstract class CustomerListIntent {}

class FetchCustomersIntent extends CustomerListIntent {}

class DeleteCustomerIntent extends CustomerListIntent {
  final String customerId;
  DeleteCustomerIntent(this.customerId);
}

class SearchCustomerIntent extends CustomerListIntent {
  final String searchTerm;
  SearchCustomerIntent(this.searchTerm);
}

// NOVO: Filtro por nível (Ouro, Prata, Bronze)
class FilterByTierIntent extends CustomerListIntent {
  final String? tierKeyword; // "ouro", "prata", "bronze" ou null
   FilterByTierIntent(this.tierKeyword);
}