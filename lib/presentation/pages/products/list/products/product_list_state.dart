import 'package:stock/domain/entities/product/product.dart';

/// Classe base para todos os estados da tela de listagem de produtos.
abstract class ProductListState {}

/// Estado enquanto os dados dos produtos estão sendo buscados.
class ProductListLoading extends ProductListState {}

/// Estado de sucesso, quando a lista de produtos é carregada.
class ProductListLoaded extends ProductListState {
  final List<Product> products;
  ProductListLoaded(this.products);
}

/// Estado de erro, caso algo falhe na busca dos produtos.
class ProductListError extends ProductListState {
  final String message;
  ProductListError(this.message);
}
