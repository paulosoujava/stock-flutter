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
import '../../../../domain/usecases/products/get_all_products_use_case.dart';
import '../../../../domain/usecases/products/update_product.dart';
import '../../../../domain/usecases/sales/save_sale_use_case.dart';
import 'live_sale_intent.dart';
import 'live_sale_state.dart';

@injectable
class LiveSaleViewModel {
  final ILiveRepository _liveRepo = getIt<ILiveRepository>();
  final ICustomerRepository _customerRepo = getIt<ICustomerRepository>();
  final SaveSaleUseCase _saveSale = getIt<SaveSaleUseCase>();
  final UpdateProduct _updateProduct = getIt<UpdateProduct>();
  final GetCurrentUserUseCase _getUser = getIt<GetCurrentUserUseCase>();

  final _state = BehaviorSubject<LiveSaleState>.seeded(LiveSaleLoading());
  Stream<LiveSaleState> get state => _state.stream;

  // CORREÇÃO: Estas listas agora são controladas pelo ViewModel
  List<Product> _allProducts = [];

  void add(LiveSaleIntent intent) async {
    final current = _state.value;

    if (intent is LoadLiveIntent) {
      try {
        final lives = await _liveRepo.getAllLives();
        final live = lives.firstWhere((l) => l.id == intent.liveId);
        final products = await getIt<GetAllProductsUseCase>()();

        // CORREÇÃO: Armazena a lista completa de produtos
        _allProducts = products;

        _state.add(LiveSaleLoaded(
          live: live,
          products: products, // A lista inicial exibida é a lista completa
        ));
      } catch (e) {
        _state.add(LiveSaleError(e.toString()));
      }
      return;
    }

    if (current is! LiveSaleLoaded) return;

    // A estrutura do switch/case é mais limpa para lidar com múltiplos intents
    switch (intent.runtimeType) {
    // CORREÇÃO: Adiciona o caso para o SearchProductIntent
      case SearchProductIntent:
        _handleSearchProduct(intent as SearchProductIntent, current);
        break;

      case SearchInstagramIntent:
        final text = current.instagramController.text.trim().toLowerCase();
        if (text.isEmpty) return;

        final customer = await _customerRepo.getCustomerByInstagram(text);
        final newList = List<Customer>.from(current.currentCustomers);

        if (customer != null) {
          newList.add(customer);
        } else {
          newList.add(Customer(
            id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
            name: '@$text',
            instagram: text,
            cpf: '', email: '', phone: '', whatsapp: '', address: '', address1: null, address2: null,
          ));
        }

        current.instagramController.clear();
        _state.add(current.copyWith(currentCustomers: newList));
        break;

      case RemoveCurrentCustomerIntent:
        final newList = List<Customer>.from(current.currentCustomers)..removeAt((intent as RemoveCurrentCustomerIntent).index);
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
          // Quando seleciona um novo produto
          _state.add(current.copyWith(selectedProduct: productIntent.product));
        }
        break;

      case AddOrderIntent:
        if (current.selectedProduct == null || current.currentCustomers.isEmpty) return;
        final newOrders = List<LiveOrder>.from(current.orders);
        newOrders.add(LiveOrder(
          product: current.selectedProduct!,
          individualDiscount: current.individualDiscount,
          customers: List.from(current.currentCustomers),
        ));

        current.instagramController.clear();

        _state.add(current.copyWith(
          selectedProduct: null,
          currentCustomers: [],
          clearSelectedProduct: true,
          orders: newOrders,
        ));
        break;

      case RemoveOrderIntent:
        final newOrders = List<LiveOrder>.from(current.orders)..removeAt((intent as RemoveOrderIntent).index);
        _state.add(current.copyWith(orders: newOrders));
        break;

      case SetGlobalDiscountIntent:
        final newValue = (intent as SetGlobalDiscountIntent).value;
        _state.add(current.copyWith(globalDiscount: newValue.clamp(0, 100)));
        break;

      case SetIndividualDiscountIntent:
        final newValue = (intent as SetIndividualDiscountIntent).value;
        _state.add(current.copyWith(individualDiscount: newValue.clamp(0, 100)));
        break;

      case FinalizeLiveIntent:
        try {
          final user = await _getUser();
          if (user == null) throw 'Vendedor não autenticado';

          for (final order in current.orders) {
            for (final customer in order.customers) {
              final totalDiscount = order.individualDiscount + current.globalDiscount;
              final priceAfterDiscount = order.product.salePrice * (1 - totalDiscount / 100);

              final sale = Sale(
                id: const Uuid().v4(),
                customerId: customer.id.startsWith('temp_') ? '' : customer.id,
                customerName: customer.name.replaceAll(' (não cadastrado)', ''),
                saleDate: DateTime.now(),
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
                globalDiscount: current.globalDiscount > 0 ? current.globalDiscount : null,
              );

              await _saveSale(sale);
            }

            await _updateProduct(order.product.copyWith(stockQuantity: order.product.stockQuantity - order.customers.length));
          }

          final totalCents = current.orders.fold<int>(0, (sum, o) => sum + (o.totalWithGlobalDiscount(current.globalDiscount) * 100).toInt());
          final updatedLive = current.live.copyWith(endDate: DateTime.now(), achievedAmount: current.live.achievedAmount + totalCents);
          await _liveRepo.updateLive(updatedLive);

          _state.add(LiveSaleFinished(success: true, goalAchieved: updatedLive.goalAchieved));
        } catch (e) {
          _state.add(LiveSaleError(e.toString()));
        }
        break;
    }
  }


  void _handleSearchProduct(SearchProductIntent intent, LiveSaleLoaded current) {
    final query = intent.query.toLowerCase();
    List<Product> filteredProducts;

    if (query.isEmpty) {
      filteredProducts = _allProducts;
    } else {
      filteredProducts = _allProducts.where((product) {
        final nameMatches = product.name.toLowerCase().contains(query);
        final codeMatches = product.codeOfProduct?.toLowerCase().contains(query);
        if(codeMatches != null) {
          return nameMatches || codeMatches;
        } else {
          return nameMatches;
        }
      }).toList();
    }

    _state.add(current.copyWith(products: filteredProducts));
  }

  void dispose() {
    _state.close();
  }
}
