// Ficheiro: lib/presentation/pages/lives_sales/form/live_form_state.dart

import 'package:stock/domain/entities/product/product.dart';

abstract class LiveFormState {}

class LiveFormLoadingState extends LiveFormState {}

class LiveFormReadyState extends LiveFormState {
  // Guarda todos os produtos disponíveis no sistema para a pesquisa.
  final List<Product> allAvailableProducts;
  // Guarda apenas a lista temporária de produtos selecionados para a live.
  final List<Product> tempProductsInLive;

  LiveFormReadyState({
    required this.allAvailableProducts,
    this.tempProductsInLive = const [], // Inicia com uma lista vazia.
  });

  // Método 'copyWith' para facilitar a atualização do estado.
  LiveFormReadyState copyWith({
    List<Product>? allAvailableProducts,
    List<Product>? tempProductsInLive,
  }) {
    return LiveFormReadyState(
      allAvailableProducts: allAvailableProducts ?? this.allAvailableProducts,
      tempProductsInLive: tempProductsInLive ?? this.tempProductsInLive,
    );
  }
}

class LiveFormSaveSuccessState extends LiveFormState {}

class LiveFormErrorState extends LiveFormState {
  final String errorMessage;

  LiveFormErrorState(this.errorMessage);
}
