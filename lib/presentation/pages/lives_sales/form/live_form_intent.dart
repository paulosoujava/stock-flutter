import 'package:stock/domain/entities/live/live.dart';
import 'package:stock/domain/entities/product/product.dart';

/// Intenção base para o formulário de Live.
abstract class LiveFormIntent {}

/// Intenção para carregar os dados iniciais necessários para o formulário
/// (como a lista de todos os produtos).
class LoadInitialDataIntent extends LiveFormIntent {}

/// Intenção para adicionar um produto à lista de produtos da live.
class AddProductToLiveIntent extends LiveFormIntent {
  final Product product;
  AddProductToLiveIntent(this.product);
}

/// Intenção para remover um produto da lista de produtos da live.
class RemoveProductFromLiveIntent extends LiveFormIntent {
  final Product product;
  RemoveProductFromLiveIntent(this.product);
}

/// Intenção para salvar a live (seja nova ou uma edição).
class SaveLiveIntent extends LiveFormIntent {
  final String title;
  final String? description;
  final List<Product> productsInLive;

  SaveLiveIntent({
    required this.title,
    this.description,
    required this.productsInLive,
  });
}


