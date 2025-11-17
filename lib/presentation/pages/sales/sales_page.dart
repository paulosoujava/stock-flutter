// sales_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/presentation/pages/sales/customer_selection/customer_selection_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/url_launcher_utils.dart';
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
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final currentState =
        await _viewModel.state.first; // Lê o valor atual do Stream

    if (currentState is! SalesReadyState) return true;

    if (currentState.cart.isEmpty && currentState.selectedCustomer == null) {
      return true;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Encerrar venda?'),
        content: const Text(
            'Você tem itens no carrinho ou cliente selecionado. Deseja descartar tudo e sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    if (shouldExit == true) {
      // LIMPA O CARRINHO E O CLIENTE ANTES DE SAIR
      _viewModel.reset();
    }
    return shouldExit ?? false;
  }

  void _openCustomerSelection(BuildContext context) async {
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
      }
    }
  }

  void _openSaleConfigDialog() {
    final TextEditingController _globalDiscountController =
        TextEditingController(
      text: _viewModel.globalDiscount > 0
          ? _viewModel.globalDiscount.toString()
          : '',
    );
    final TextEditingController _descriptionController = TextEditingController(
      text: _viewModel.globalDescription,
    );

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.settings, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text(
                    'Configuração da Venda',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _globalDiscountController,
                decoration: InputDecoration(
                  labelText: 'Desconto Global (%)',
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.percent),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () {
                    final discount =
                        int.tryParse(_globalDiscountController.text) ?? 0;
                    final description = _descriptionController.text;
                    _viewModel.handleIntent(
                        SetGlobalDiscountIntent(discount, description));
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          title: StreamBuilder<SalesState>(
            stream: _viewModel.state,
            builder: (context, snapshot) {
              final state = snapshot.data;
              final customer =
                  state is SalesReadyState ? state.selectedCustomer : null;

              if (customer == null) {
                return const Text('Registrar Venda');
              }

              return Row(
                children: [
                  GestureDetector(
                    onTap: () => _showCustomerDetailsDialog(customer),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white,
                          child: Text(
                            customer.name.isNotEmpty
                                ? customer.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                                fontSize: 12,
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          customer.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _iconButton(
                    icon: Icons.info_outline,
                    tooltip: 'Detalhes',
                    onPressed: () => _showCustomerDetailsDialog(customer),
                    color: Colors.grey,
                  ),
                  _iconButton(
                    icon: Icons.swap_horiz,
                    tooltip: 'Trocar Cliente',
                    onPressed: () => _openCustomerSelection(context),
                    color: Colors.orange,
                  ),
                ],
              );
            },
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Configuração',
              onPressed: _openSaleConfigDialog,
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Card(
          elevation: 8,
          margin: const EdgeInsets.all(16.0),
          color: Colors.white,
          shadowColor: Colors.black12,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<SalesState>(
                stream: _viewModel.state,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  if (state is SalesLoadingState) {
                    return Container(
                      color: Colors.white.withOpacity(0.95),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.deepPurple),
                            SizedBox(height: 16),
                            Text(
                              "Finalizando venda...",
                              style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  if (state is SalesErrorState) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(state.message, textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  }
                  if (state is SalesSaleSuccessfulState) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Venda finalizada com sucesso!'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: StadiumBorder(),
                        ),
                      );
                    });
                  }
                  if (state is SalesReadyState) {
                    return _buildSalesReadyView(context, state);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSalesReadyView(BuildContext context, SalesReadyState state) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            children: [
              const SizedBox(height: 8),
              if (state.selectedCustomer == null)
                _buildCustomerSection(context, state),
              if (state.selectedCustomer != null) ...[
                const SizedBox(height: 24),
                _buildProductSearchSection(context, state),
              ],
            ],
          ),
        ),
        if (state.cart.isNotEmpty) _buildShoppingCart(context, state),
      ],
    );
  }

  Widget _buildCustomerSection(BuildContext context, SalesReadyState state) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_search, color: theme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Cliente',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.person_add),
              label: const Text('Selecionar ou Cadastrar Cliente'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _openCustomerSelection(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomerDetailsDialog(Customer customer) {
    final theme = Theme.of(context);
    Future<void> _launchWhatsApp(String phone) async {
      final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
      final whatsappUrl = Uri.parse("https://wa.me/55$cleanPhone");
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Não foi possível abrir o WhatsApp para $phone'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.person, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Detalhes do Cliente',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              _infoRow('Nome', customer.name, Icons.person_outline),
              const Divider(),
              _infoRow('Telefone', customer.phone, Icons.phone),
              const Divider(),
              _infoRow(
                'WhatsApp',
                customer.whatsapp.isEmpty ? 'Não informado' : customer.whatsapp,
                Icons.message,
                trailing: customer.whatsapp.isNotEmpty
                    ? IconButton(
                        icon:
                            const Icon(Icons.open_in_new, color: Colors.green),
                        onPressed: () => _launchWhatsApp(customer.whatsapp),
                      )
                    : null,
              ),
              const Divider(),
              _infoRow(
                'Endereço',
                customer.address.isEmpty ? 'Não informado' : customer.address,
                Icons.location_on_outlined,
                trailing: customer.address.isNotEmpty
                    ? IconButton(
                        icon:
                            const Icon(Icons.map, color: Colors.blue, size: 20),
                        onPressed: () => UrlLauncherUtils.launchMap(
                            context, customer.address),
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 36, minHeight: 36),
                        tooltip: 'Abrir no mapa',
                      )
                    : null,
              ),
              const Divider(),
              _infoRow('Observação', customer.notes ?? 'Sem observações',
                  Icons.note),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('FECHAR',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon,
      {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailing != null) SizedBox(height: 36, child: trailing),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSearchSection(
      BuildContext context, SalesReadyState state) {
    final theme = Theme.of(context);
    return AnimatedSlide(
      duration: const Duration(milliseconds: 400),
      offset: const Offset(0, 0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.inventory_2, color: Colors.purple),
                  const SizedBox(width: 8),
                  Text(
                    'Adicionar Produtos',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // sales_page.dart — apenas o TextField da pesquisa (substitua por este)
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Pesquise por nome, código ou preço...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchController,
                    builder: (context, value, child) {
                      if (value.text.isEmpty) return const SizedBox.shrink();
                      return IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          // FORÇA LIMPEZA IMEDIATA DA LISTA
                          _viewModel.handleIntent(SearchProductsIntent(''));
                        },
                      );
                    },
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onChanged: (query) {
                  _viewModel.handleIntent(SearchProductsIntent(query));
                },
              ),
              const SizedBox(height: 16),
              if (state.isSearching)
                const Center(child: CircularProgressIndicator())
              else if (state.searchResults.isEmpty &&
                  state.currentSearchQuery.isNotEmpty)
                const Center(
                  child: Text('Nenhum produto encontrado.',
                      style: TextStyle(color: Colors.grey)),
                )
              else if (state.searchResults.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.searchResults.length,
                  itemBuilder: (context, index) {
                    final product = state.searchResults[index];
                    return _ProductSearchItem(
                      product: product,
                      onAddToCart: (quantity, discount) {
                        _viewModel.handleIntent(AddProductToCartIntent(
                            product, quantity, discount));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Adicionado: ${product.name} × $quantity${discount > 0 ? ' com $discount% desconto' : ''}'),
                            duration: const Duration(milliseconds: 800),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      globalDiscount: state.globalDiscount,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildShoppingCart(BuildContext context, SalesReadyState state) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: ExpansionTile(
              collapsedIconColor: Colors.black54,
              iconColor: theme.primaryColor,
              title: Row(
                children: [
                  Badge(
                    label: Text('${state.cart.length}'),
                    backgroundColor: theme.primaryColor,
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'CARRINHO',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              children: [
                if (state.globalDiscount > 0)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      'Desconto global de ${state.globalDiscount}% aplicado. ${state.globalDescription.isNotEmpty ? state.globalDescription : 'Sem descrição.'}',
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ...state.cart.map((item) {
                  final product = state.originalProducts.firstWhere(
                    (p) => p.id == item.productId,
                    orElse: () => Product(
                      id: '',
                      name: 'Produto não encontrado',
                      description: '',
                      costPrice: 0,
                      salePrice: 0,
                      stockQuantity: 0,
                      lowStockThreshold: 0,
                      categoryId: '',
                    ),
                  );
                  String desc = product.description;
                  if (desc.length > 80) desc = '${desc.substring(0, 80)}...';
                  return Dismissible(
                    key: Key(item.productId),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      _viewModel.handleIntent(
                          RemoveProductFromCartIntent(item.productId));
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: const Icon(Icons.inventory_2_outlined,
                              color: Colors.grey),
                        ),
                        title: Text(
                          item.productName.toUpperCase(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(
                          desc,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _quantityButton(
                              icon: Icons.remove_circle_outline,
                              onPressed: () => _viewModel.handleIntent(
                                  DecrementCartItemIntent(item.productId)),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            _quantityButton(
                              icon: Icons.add_circle_outline,
                              onPressed: () => _viewModel.handleIntent(
                                  IncrementCartItemIntent(item.productId)),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'R\$ ${item.totalPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              children: [
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
                        color: theme.primaryColor,
                      ),
                      child: Text(
                        'R\$ ${(state.globalDiscount > 0 ? state.cartTotal * (1 - state.globalDiscount / 100) : state.cartTotal).toStringAsFixed(2)}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check_circle, size: 20),
                    label: const Text('FINALIZAR VENDA',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    onPressed: () =>
                        _viewModel.handleIntent(FinalizeSaleIntent()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return IconButton(
      icon: Icon(icon, size: 20),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: onPressed,
    );
  }

  Widget _iconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        splashRadius: 20,
      ),
    );
  }
}

class _ProductSearchItem extends StatefulWidget {
  final Product product;
  final Function(int quantity, int discount) onAddToCart;
  final int globalDiscount;

  const _ProductSearchItem(
      {required this.product,
      required this.onAddToCart,
      required this.globalDiscount});

  @override
  State<_ProductSearchItem> createState() => __ProductSearchItemState();
}

class __ProductSearchItemState extends State<_ProductSearchItem>
    with TickerProviderStateMixin {
  int _quantity = 1;
  int _discount = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final TextEditingController _discountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 0.95).animate(_animationController);
    _discountController.text = '0';
  }

  @override
  void dispose() {
    _animationController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasStock = widget.product.stockQuantity > 0;
    final isLowStock = hasStock &&
        widget.product.stockQuantity <= widget.product.lowStockThreshold;
    final isMaxed = _quantity >= widget.product.stockQuantity;
    final hasGlobalDiscount = widget.globalDiscount > 0;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: hasStock ? Colors.white : Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'R\$ ${widget.product.salePrice.toStringAsFixed(2)}',
                          style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      const Text('Estoque',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        '${widget.product.stockQuantity}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isLowStock
                              ? Colors.orange[800]
                              : (hasStock ? Colors.green[700] : Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  if (hasStock) ...[
                    const Text('Qtd:'),
                    const SizedBox(width: 12),
                    _quantityButton(
                        Icons.remove_circle_outline,
                        _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null),
                    SizedBox(
                        width: 40,
                        child: Center(
                            child: Text('$_quantity',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)))),
                    _quantityButton(Icons.add_circle_outline,
                        !isMaxed ? () => setState(() => _quantity++) : null,
                        tooltip: isMaxed ? 'Estoque máximo' : null),
                  ] else
                    const Row(
                      children: [
                        Icon(Icons.sentiment_very_dissatisfied,
                            color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('Esgotado',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  const SizedBox(width: 16),
                  if (hasStock && !hasGlobalDiscount) ...[
                    const Text('Desc. (%):'),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: _discountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly, // ACEITA APENAS DÍGITOS
                        ],
                        onChanged: (value) {
                          final parsed = int.tryParse(value);
                          _discount = parsed ?? 0;
                          // Opcional: limpa o campo se não for número válido
                          if (parsed == null && value.isNotEmpty) {
                            _discountController.clear();
                          }
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          hintText: '0', // opcional
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  FilledButton(
                    onPressed: hasStock
                        ? () {
                            _animationController
                                .forward()
                                .then((_) => _animationController.reverse());
                            widget.onAddToCart(
                                _quantity, hasGlobalDiscount ? 0 : _discount);
                            setState(() => _quantity = 1);
                            _discountController.text = '0';
                          }
                        : null,
                    style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: const Text('Adicionar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback? onPressed,
      {String? tooltip}) {
    return Tooltip(
      message: tooltip ?? '',
      child: IconButton(
        icon: Icon(icon, color: onPressed != null ? null : Colors.grey),
        onPressed: onPressed,
        disabledColor: Colors.grey[400],
      ),
    );
  }
}

class _CustomerSelectionModal extends StatelessWidget {
  const _CustomerSelectionModal();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets,
      duration: const Duration(milliseconds: 200),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black26, blurRadius: 20, offset: Offset(0, -2)),
            ],
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Icon(Icons.person_search,
                        color: theme.primaryColor, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Selecionar Cliente',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Container(
                    color: Colors.grey[50],
                    child: const CustomerSelectionPage()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
