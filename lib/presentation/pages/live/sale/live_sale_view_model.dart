// live_sale_view_model.dart
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/injection.dart';
import '../../../../domain/entities/customer/customer.dart';
import '../../../../domain/entities/product/product.dart';
import '../../../../domain/entities/sale/sale.dart';
import '../../../../domain/entities/sale/sale_item.dart';
import '../../../../domain/repositories/icustomer_repository.dart';
import '../../../../domain/repositories/ilive_repository.dart';
import '../../../../domain/usecases/auth/get_current_user_use_case.dart';
import '../../../../domain/usecases/live/finish_live_use_case.dart';
import '../../../../domain/usecases/products/get_all_products_use_case.dart';
import '../../../../domain/usecases/products/update_product.dart';
import '../../../../domain/usecases/sales/save_sale_use_case.dart';
import 'live_sale_intent.dart';
import 'live_sale_state.dart';

@injectable
class LiveSaleViewModel {
  final ILiveRepository _liveRepo;
  final ICustomerRepository _customerRepo;
  final SaveSaleUseCase _saveSale;
  final UpdateProduct _updateProduct;
  final GetCurrentUserUseCase _getUser;
  final FinishLiveUseCase _finishLive;

  final _state = BehaviorSubject<LiveSaleState>.seeded(LiveSaleLoading());

  Stream<LiveSaleState> get state => _state.stream;

  List<Product> _allProducts = [];

  LiveSaleViewModel(
    this._liveRepo,
    this._customerRepo,
    this._saveSale,
    this._updateProduct,
    this._getUser,
    this._finishLive,
  );

  void add(LiveSaleIntent intent) async {
    final current = _state.value;

    if (intent is LoadLiveIntent) {
      try {
        final lives = await _liveRepo.getAllLives();
        final live = lives.firstWhere((l) => l.id == intent.liveId);
        final products = await getIt<GetAllProductsUseCase>()();

        _allProducts = products;

        _state.add(LiveSaleLoaded(
          live: live,
          products: products,
        ));
      } catch (e) {
        _state.add(LiveSaleError(e.toString()));
      }
      return;
    }

    if (current is! LiveSaleLoaded) return;

    switch (intent.runtimeType) {
      case SearchProductIntent:
        _handleSearchProduct(intent as SearchProductIntent, current);
        break;

      case SearchInstagramIntent:
        final text = current.instagramController.text.trim().toLowerCase();
        if (text.isEmpty) return;

        // Validação 1: Verificar se um produto está selecionado
        if (current.selectedProduct == null) {
          _emitMessage(current, "Selecione um produto primeiro!");
          current.instagramController.clear();
          return;
        }

        // Validação 2: Verificar o estoque
        if (current.currentCustomers.length >=
            current.selectedProduct!.stockQuantity) {
          _emitMessage(current, "Estoque do produto esgotado.");
          current.instagramController.clear();
          return;
        }

        // Validação 3: Verificar cliente duplicado
        if (current.currentCustomers
            .any((customer) => customer.instagram == text)) {
          _emitMessage(current, "Cliente @$text já foi adicionado.");
          current.instagramController.clear();
          return;
        }

        final customer = await _customerRepo.getCustomerByInstagram(text);
        final newList = List<Customer>.from(current.currentCustomers);

        if (customer != null) {
          newList.add(customer);
        } else {
          newList.add(Customer(
            id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
            name: '@$text',
            instagram: text,
            cpf: '',
            email: '',
            phone: '',
            whatsapp: '',
            address: '',
            address1: null,
            address2: null,
          ));
        }

        current.instagramController.clear();
        _state.add(current.copyWith(currentCustomers: newList));
        break;

      case RemoveCurrentCustomerIntent:
        final newList = List<Customer>.from(current.currentCustomers)
          ..removeAt((intent as RemoveCurrentCustomerIntent).index);
        _state.add(current.copyWith(currentCustomers: newList));
        break;

      case SelectProductIntent:
        final productIntent = intent as SelectProductIntent;
        if (productIntent.product == null) {
          current.instagramController.clear();
          _state.add(current.copyWith(
            selectedProduct: null,
            clearSelectedProduct: true,
            currentCustomers: [],
          ));
        } else {
          _state.add(current.copyWith(selectedProduct: productIntent.product));
        }
        break;
      case AddOrderIntent:
        if (current.selectedProduct == null || current.currentCustomers.isEmpty) break;

        final product = current.selectedProduct!;
        final alreadySold = current.orders
            .where((o) => o.product.id == product.id)
            .fold(0, (sum, o) => sum + o.customers.length);

        final sellingNow = current.currentCustomers.length;

        if (alreadySold + sellingNow > product.stockQuantity) {
          _emitMessage(current, "Not enough stock! Only ${product.stockQuantity - alreadySold} left.");
          break;
        }

        final newOrders = List<LiveOrder>.from(current.orders);
        newOrders.add(LiveOrder(
          product: product,
          discountPercent: current.discountPercent,
          customers: List.from(current.currentCustomers),
        ));

        // UPDATE STOCK IN THE PRODUCT LIST (forces new object + rebuild)
        final updatedProducts = current.products.map((p) {
          if (p.id == product.id) {
            final totalSoldNow = newOrders
                .where((o) => o.product.id == p.id)
                .fold(0, (sum, o) => sum + o.customers.length);
            return p.copyWith(stockQuantity: product.stockQuantity - (totalSoldNow - alreadySold));
          }
          return p.copyWith(); // forces new instance even if unchanged
        }).toList();

        current.instagramController.clear();

        _state.add(current.copyWith(
          selectedProduct: null,
          currentCustomers: [],
          clearSelectedProduct: true,
          orders: newOrders,
          products: updatedProducts,
        ));
        break;
      case RemoveOrderIntent:
        final index = (intent as RemoveOrderIntent).index;
        final orderToRemove = current.orders[index];

        // 1. Remove o pedido da lista
        final newOrders = List<LiveOrder>.from(current.orders)..removeAt(index);

        // 2. Recalcula o estoque VISÍVEL no grid corretamente
        final updatedProducts = current.products.map((p) {
          if (p.id == orderToRemove.product.id) {
            // Quantas unidades desse produto ainda estão vendidas (após remoção)
            final stillSold = newOrders
                .where((o) => o.product.id == p.id)
                .fold(0, (sum, o) => sum + o.customers.length);

            // Estoque original - o que ainda está vendido = estoque disponível agora
            final originalStock = p.stockQuantity + orderToRemove.customers.length; // devolve o que foi removido
            final newVisibleStock = originalStock - stillSold;

            return p.copyWith(stockQuantity: newVisibleStock);
          }
          return p;
        }).toList();

        _state.add(current.copyWith(
          orders: newOrders,
          products: updatedProducts,
        ));
        break;

      case SetGlobalDiscountIntent:
        final newValue = (intent as SetGlobalDiscountIntent).value;
        _state.add(current.copyWith(globalDiscount: newValue.clamp(0, 100)));
        break;

      case SetIndividualDiscountIntent:
        final newValue = (intent as SetIndividualDiscountIntent).value;
        _state.add(current.copyWith(
            discountPercent: newValue.clamp(0, 100))); // Revertido
        break;

      case FinalizeLiveIntent:
        try {
          final user = await _getUser();
          if (user == null) throw 'Vendedor não autenticado';

          for (final order in current.orders) {
            for (final customer in order.customers) {
              final totalDiscount =
                  order.discountPercent + current.globalDiscount;
              final priceAfterDiscount =
                  order.product.salePrice * (1 - totalDiscount / 100);

              final sale = Sale(
                id: const Uuid().v4(),
                customerId: customer.id.startsWith('temp_') ? '' : customer.id,
                customerName: customer.instagram != null && customer.instagram!.isNotEmpty
                    ? '@${customer.instagram!}'
                    : customer.name,
                saleDate: DateTime.now(),
                liveId: current.live.id,
                items: [
                  SaleItem(
                    productId: order.product.id,
                    productName: order.product.name,
                    quantity: 1,
                    pricePerUnit: order.product.salePrice,
                    discount: totalDiscount,
                  )
                ],
                totalAmount: priceAfterDiscount,
                sellerId: user.uid,
                sellerName: user.displayName ?? 'Vendedor',
                globalDiscount:
                    current.globalDiscount > 0 ? current.globalDiscount : null,
              );

              await _saveSale(sale);
            }

            await _updateProduct(order.product.copyWith(
                stockQuantity:
                    order.product.stockQuantity - order.customers.length));
          }

          final totalCents = current.orders.fold<int>(
            0,
            (sum, o) =>
                sum +
                (o.totalWithGlobalDiscount(current.globalDiscount) * 100)
                    .toInt(),
          );

          final updatedLive = current.live.copyWith(
            endDate: DateTime.now(),
            achievedAmount: current.live.achievedAmount + totalCents,
          );

          await _liveRepo.updateLive(updatedLive);
          await _finishLive(updatedLive.id);

          _state.add(LiveSaleFinished(
            success: true,
            goalAchieved: updatedLive.goalAchieved,
          ));
        } catch (e) {
          _state.add(LiveSaleError(e.toString()));
        }
        break;
    }
  }

  void _emitMessage(LiveSaleLoaded current, String message) {
    _state.add(LiveSaleMessage(
      message: message,
      state: current,
    ));
  }

  void _handleSearchProduct(
      SearchProductIntent intent, LiveSaleLoaded current) {
    final query = intent.query.toLowerCase();
    List<Product> filteredProducts;

    if (query.isEmpty) {
      filteredProducts = _allProducts;
    } else {
      filteredProducts = _allProducts.where((product) {
        final nameMatches = product.name.toLowerCase().contains(query);
        final codeMatches =
            product.codeOfProduct?.toLowerCase().contains(query) ?? false;
        return nameMatches || codeMatches;
      }).toList();
    }

    _state.add(current.copyWith(products: filteredProducts));
  }

  void dispose() {
    _state.close();
  }
}
