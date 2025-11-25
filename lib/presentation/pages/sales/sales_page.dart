// sales_page.dart — 100% ORIGINAL + APENAS A CORREÇÃO DO BUG DO CLIENTE
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/presentation/pages/sales/customer_selection/customer_selection_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/dialog_customer_details.dart';
import 'sales_intent.dart';
import 'sales_state.dart';
import 'sales_view_model.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  late final SalesViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<SalesViewModel>();
    _viewModel.reset();
    _viewModel
        .handleIntent(SearchProductsIntent('')); // CARREGA TODOS AO ENTRAR
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final currentState = await _viewModel.state.first;

    if (currentState is! SalesReadyState ||
        (currentState.cart.isEmpty && currentState.selectedCustomer == null)) {
      return true;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar Venda?'),
        content: const Text(
            'Você tem uma venda em andamento. Deseja descartar as alterações e sair?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Continuar Vendendo')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Descartar e Sair'),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      _viewModel.reset();
    }
    return shouldExit ?? false;
  }

  void _openCustomerSelection() async {
    final selectedCustomer = await showModalBottomSheet<Customer>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (_) => const _CustomerSelectionModal(),
    );

    if (selectedCustomer != null) {
      _viewModel.handleIntent(SelectCustomerIntent(selectedCustomer));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.person_add, color: Colors.white),
                const SizedBox(width: 8),
                Text('Cliente selecionado: ${selectedCustomer.name}'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: const StadiumBorder(),
            duration: const Duration(seconds: 2),
          ),
        );

        // AQUI ESTÁ A ÚNICA COISA QUE MUDOU: RECARREGA OS PRODUTOS QUANDO SELECIONA CLIENTE
        _viewModel.handleIntent(SearchProductsIntent(''));
      }
    }
  }

  void _openSaleConfigDialog(SalesReadyState state) {
    final globalDiscountController = TextEditingController(
        text: state.globalDiscount > 0 ? '${state.globalDiscount}' : '');
    final descriptionController =
        TextEditingController(text: state.globalDescription);

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: 450,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: const [
                  Icon(Icons.discount_outlined,
                      color: Colors.deepPurple, size: 28),
                  SizedBox(width: 12),
                  Text('Configuração da Venda',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 24),
                TextField(
                  controller: globalDiscountController,
                  decoration: const InputDecoration(
                      labelText: 'Desconto Global (%)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.percent)),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),
                TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                        labelText: 'Descrição do Desconto (Opcional)',
                        border: OutlineInputBorder()),
                    maxLines: 2),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check_circle),
                    onPressed: () {
                      final discount =
                          int.tryParse(globalDiscountController.text) ?? 0;
                      _viewModel.handleIntent(SetGlobalDiscountIntent(
                          discount, descriptionController.text));
                      Navigator.pop(dialogContext);
                    },
                    label: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCustomerDetailsDialog(Customer customer) {
    showDialog(
        context: context,
        builder: (dialogContext) => CustomerDetailsDialog(customer: customer));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: StreamBuilder<SalesState>(
          stream: _viewModel.state,
          builder: (context, snapshot) {
            final state = snapshot.data;
            return Stack(
              children: [
                if (state is SalesReadyState)
                  _buildSalesReadyView(context, state)
                else
                  const Center(child: CircularProgressIndicator()),
                if (state is! SalesReadyState)
                  _buildOverlayStates(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSalesReadyView(BuildContext context, SalesReadyState state) {
    return Column(
      children: [
        _buildAppBar(context, state),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    flex: 3,
                    child: state.selectedCustomer == null
                        ? _buildCustomerSelectionPrompt(context)
                        : _buildProductSearchSection(context, state)),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildShoppingCart(context, state)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, SalesReadyState state) {
    final theme = Theme.of(context);
    final customer = state.selectedCustomer;

    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
      elevation: 4,
      shadowColor: Colors.black38,
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 16),
        child: Row(
          children: [
            IconButton(
                icon: Icon(Icons.arrow_back, color: theme.primaryColor),
                onPressed: () async {
                  final shouldPop = await _onWillPop();
                  if (shouldPop && mounted) context.pop();
                }),
            const SizedBox(width: 8),
            if (customer == null)
              Text('Registrar Nova Venda',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold))
            else ...[
              Builder(builder: (context) {
                final notes = customer.notes?.toLowerCase() ?? '';
                Color avatarColor = theme.primaryColor;
                Widget avatarChild = Text(
                    customer.name.isNotEmpty
                        ? customer.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold));

                if (notes.contains('ouro')) {
                  avatarColor = const Color(0xFFD4AF37);
                  avatarChild = const Icon(Icons.emoji_events,
                      color: Colors.white, size: 20);
                } else if (notes.contains('prata')) {
                  avatarColor = const Color(0xFFA8A9AD);
                  avatarChild = const Icon(Icons.emoji_events,
                      color: Colors.white, size: 20);
                } else if (notes.contains('bronze')) {
                  avatarColor = const Color(0xFFCD7F32);
                  avatarChild = const Icon(Icons.emoji_events,
                      color: Colors.white, size: 20);
                }

                return CircleAvatar(
                    radius: 20,
                    backgroundColor: avatarColor,
                    child: avatarChild);
              }),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cliente',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(customer.name.toUpperCase(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              _iconButton(
                  icon: Icons.info_outline,
                  tooltip: 'Detalhes do Cliente',
                  onPressed: () => _showCustomerDetailsDialog(customer)),
              _iconButton(
                  icon: Icons.swap_horiz,
                  tooltip: 'Trocar Cliente',
                  onPressed: _openCustomerSelection),
            ],
            const Spacer(),
            Badge(
              isLabelVisible: state.globalDiscount > 0,
              label: const Icon(Icons.check, size: 10, color: Colors.white),
              backgroundColor: Colors.green,
              child: _iconButton(
                  icon: Icons.discount_outlined,
                  tooltip: 'Configuração da Venda',
                  onPressed: () => _openSaleConfigDialog(state)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSelectionPrompt(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search,
                size: 80,
                color: Theme.of(context).primaryColor.withOpacity(0.7)),
            const SizedBox(height: 24),
            const Text('Nenhum Cliente Selecionado',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Selecione um cliente para iniciar a venda.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            const SizedBox(height: 32),
            FilledButton.icon(
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Selecionar ou Cadastrar Cliente'),
              style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
              onPressed: _openCustomerSelection,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSearchSection(
      BuildContext context, SalesReadyState state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Pesquise por nome, código ou preço...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _viewModel.handleIntent(SearchProductsIntent(''));
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (query) =>
                _viewModel.handleIntent(SearchProductsIntent(query)),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(child: _buildSearchResultsView(context, state)),
      ],
    );
  }

  // VOLTEI EXATAMENTE COMO ERA ANTES — SEM GRID NOVO, SEM LAYOUTBUILDER, SEM PORRA NENHUMA
  Widget _buildSearchResultsView(BuildContext context, SalesReadyState state) {
    if (state.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.searchResults.isEmpty && state.currentSearchQuery.isNotEmpty) {
      return const Center(child: Text('Nenhum produto encontrado.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: state.searchResults.length,
      itemBuilder: (context, index) {
        final product = state.searchResults[index];
        final latestProduct = state.originalProducts.firstWhere(
          (p) => p.id == product.id,
          orElse: () => product,
        );

        return _ProductSearchItem(
          key: ValueKey('${latestProduct.id}_${latestProduct.stockQuantity}'),
          product: latestProduct,
          onAddToCart: (quantity, discount) {
            _viewModel.handleIntent(
                AddProductToCartIntent(latestProduct, quantity, discount));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Adicionado: ${latestProduct.name} × $quantity${discount > 0 ? ' com $discount% desconto' : ''}'),
                duration: const Duration(milliseconds: 900),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.only(left: 300, right: 20, bottom: 20),
                shape: const StadiumBorder(),
              ),
            );
          },
          globalDiscount: state.globalDiscount,
        );
      },
    );
  }


  Widget _buildShoppingCart(BuildContext context, SalesReadyState state) {
    final theme = Theme.of(context);
    final cartTotal =
        state.cart.fold<double>(0, (sum, item) => sum + item.totalPrice);
    final discountedTotal = cartTotal * (1 - state.globalDiscount / 100);


    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Badge(
                    label: Text('${state.cart.length}'),
                    isLabelVisible: state.cart.isNotEmpty,
                    child: const Icon(Icons.shopping_cart_outlined, size: 28)),
                const SizedBox(width: 12),
                Text('Carrinho',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(height: 1),
          if (state.cart.isEmpty)
            Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                  Icon(Icons.remove_shopping_cart_outlined,
                      size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Carrinho Vazio',
                      style: TextStyle(fontSize: 16, color: Colors.grey))
                ]))
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: state.cart.length,
                itemBuilder: (context, index) {
                  final item = state.cart[index];

                  return Dismissible(
                    key: Key(item.productId),
                    direction: DismissDirection.endToStart,
                    background: Container(
                        color: Colors.red.shade700,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete_sweep,
                            color: Colors.white)),
                    onDismissed: (_) => _viewModel.handleIntent(
                        RemoveProductFromCartIntent(item.productId)),
                    child: Card(
                      elevation: 0,
                      color: Colors.grey[50],
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: Row(
                          children: [
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(item.productName.toUpperCase(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      '${item.quantity} x R\$ ${item.pricePerUnit.toStringAsFixed(2)}',
                                      style: TextStyle(color: Colors.grey[600])),
                                      if(item.discount  !=null && item.discount! > 0)
                                      Text('${item.discount}% de desconto',
                                          style: const TextStyle(color: Colors.green)),
                                ])),
                            Text('R\$ ${item.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            _quantityButton(
                                icon: Icons.delete,
                                onPressed: () => _viewModel.handleIntent(
                                    DecrementCartItemIntent(item.productId))),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[200]!))),
            child: Column(
              children: [
                if (state.globalDiscount > 0) ...[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal',
                            style: TextStyle(color: Colors.grey)),
                        Text('R\$ ${cartTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough))
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Desconto (${state.globalDiscount}%)',
                            style: const TextStyle(color: Colors.green)),
                        Text(
                            '- R\$ ${(cartTotal - discountedTotal).toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.green))
                      ]),
                  const Divider(height: 16),
                ],
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TOTAL',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: theme.textTheme.headlineSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor),
                          child:
                              Text('R\$ ${discountedTotal.toStringAsFixed(2)}'))
                    ]),
                const SizedBox(height: 16),
                SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                        icon: const Icon(Icons.check_circle, size: 20),
                        label: const Text('FINALIZAR VENDA'),
                        style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        onPressed: state.cart.isEmpty ||
                                state.selectedCustomer == null
                            ? null
                            : () =>
                                _viewModel.handleIntent(FinalizeSaleIntent()))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayStates(BuildContext context, SalesState? state) {
    if (state is SalesLoadingState) {
      return Container(
          color: Colors.black.withOpacity(0.5),
          child: const Center(
              child: Card(
                  child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Finalizando venda...",
                            style: TextStyle(fontSize: 16))
                      ])))));
    }
    if (state is SalesErrorState) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                    icon: const Icon(Icons.error, color: Colors.red, size: 48),
                    title: const Text('Erro ao Finalizar'),
                    content: Text(state.message),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('OK'))
                    ]));
      });
    }
    if (state is SalesSaleSuccessfulState) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (dialogContext) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.check_circle_outline,
                          color: Colors.white, size: 40)),
                  const SizedBox(height: 20),
                  const Text('Venda Registrada!',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                      'A venda foi concluída com sucesso e o carrinho foi limpo.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 15, color: Colors.grey.shade600)),
                  const SizedBox(height: 24),
                  FilledButton(
                      onPressed: () {
                        _viewModel.reset();
                        Navigator.pop(dialogContext);
                      },
                      child: const Text('Ótimo!')),
                ],
              ),
            ),
          ),
        );
      });
    }
    return const SizedBox.shrink();
  }

  Widget _iconButton(
      {required IconData icon,
      required String tooltip,
      required VoidCallback onPressed}) {
    return Tooltip(
        message: tooltip,
        child: IconButton(
            icon: Icon(icon), onPressed: onPressed, splashRadius: 20));
  }

  Widget _quantityButton(
      {required IconData icon, required VoidCallback? onPressed}) {
    return IconButton(
        icon: Icon(icon, size: 20, color: Colors.red,),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        onPressed: onPressed);
  }
}

class _CustomerSelectionModal extends StatelessWidget {
  const _CustomerSelectionModal();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          children: [
            Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3))),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 8),
              child: Row(children: const [
                Icon(Icons.person_search, size: 28),
                SizedBox(width: 12),
                Text('Selecionar Cliente',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Spacer(),
                CloseButton()
              ]),
            ),
            const Divider(height: 1),
            const Expanded(child: CustomerSelectionPage()),
          ],
        ),
      ),
    );
  }
}

class _ProductSearchItem extends StatefulWidget {
  final Product product;
  final Function(int quantity, int discount) onAddToCart;
  final int globalDiscount;

  const _ProductSearchItem({
    required super.key,
    required this.product,
    required this.onAddToCart,
    required this.globalDiscount,
  });

  @override
  State<_ProductSearchItem> createState() => _ProductSearchItemState();
}

class _ProductSearchItemState extends State<_ProductSearchItem>
    with AutomaticKeepAliveClientMixin {
  late int _quantity = 1;
  late int _discount = 0;
  final _discountController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  void _increment() => setState(() => _quantity =
      _quantity < widget.product.stockQuantity ? _quantity + 1 : _quantity);

  void _decrement() =>
      setState(() => _quantity = _quantity > 1 ? _quantity - 1 : 1);

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final hasStock = widget.product.stockQuantity > 0;
    final isLowStock = hasStock &&
        widget.product.stockQuantity <= widget.product.lowStockThreshold;
    final canAddMore = _quantity < widget.product.stockQuantity;
    final hasGlobalDiscount = widget.globalDiscount > 0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nome + Preço + Estoque
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'R\$ ${widget.product.salePrice.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (isLowStock
                            ? Colors.orange.shade700
                            : hasStock
                                ? Colors.green.shade700
                                : Colors.red)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${widget.product.stockQuantity}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isLowStock
                          ? Colors.orange.shade700
                          : (hasStock ? Colors.green.shade700 : Colors.red),
                    ),
                  ),
                ),

              ],
            ),
            if (!hasGlobalDiscount)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SizedBox(
                  width: 76,
                  height: 40,
                  child: TextField(
                    controller: _discountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      hintText: '% desc',
                    ),
                    onChanged: (v) => _discount = int.tryParse(v) ?? 0,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Divider(),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle, size: 22),
                      color: _quantity > 1 ? Colors.red.shade400 : Colors.grey,
                      onPressed: _quantity > 1 ? _decrement : null,
                    ),
                    SizedBox(
                      width: 38,
                      child: Center(
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, size: 22),
                      color: canAddMore ? Colors.green.shade600 : Colors.grey,
                      onPressed: canAddMore ? _increment : null,
                    ),
                  ],
                ),



                // Botão Add
                IconButton(
                  onPressed: hasStock
                      ? () {
                          widget.onAddToCart(
                              _quantity, hasGlobalDiscount ? 0 : _discount);
                          setState(() {
                            _quantity = 1;
                            _discount = 0;
                            _discountController.clear();
                          });
                        }
                      : null,
                  icon: const Icon(Icons.add_shopping_cart, size: 21),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
