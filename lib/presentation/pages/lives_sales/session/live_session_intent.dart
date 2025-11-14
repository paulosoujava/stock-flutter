// Ficheiro: lib/presentation/pages/lives_sales/session/live_session_intent.dart

import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/entities/product/product.dart';

abstract class LiveSessionIntent {}

// Carregar dados da live (forceReload opcional)
class LoadLiveSessionDataIntent extends LiveSessionIntent {
  final String liveId;
  final bool forceReload;

  LoadLiveSessionDataIntent(this.liveId, {this.forceReload = false});
}

// Adicionar um item (com quantidade)
class AddSaleItemIntent extends LiveSessionIntent {
  final Customer customer;
  final Product product;
  final int quantity;

  AddSaleItemIntent({
    required this.customer,
    required this.product,
    this.quantity = 1,
  });
}

// Atualizar quantidade de um item (cliente + produto)
class UpdateSaleItemQuantityIntent extends LiveSessionIntent {
  final Customer customer;
  final Product product;
  final int newQuantity;

  UpdateSaleItemQuantityIntent({
    required this.customer,
    required this.product,
    required this.newQuantity,
  });
}

  // Remover um item específico (cliente + produto)
  class RemoveSaleItemIntent extends LiveSessionIntent {
    final Customer customer;
    final Product product;

    RemoveSaleItemIntent({
      required this.customer,
      required this.product,
    });
  }

// Remover todos os itens de um comprador
class RemoveCustomerGroupIntent extends LiveSessionIntent {
  final Customer customer;

  RemoveCustomerGroupIntent({required this.customer});
}

// Finalizar live
class FinalizeLiveIntent extends LiveSessionIntent {}
