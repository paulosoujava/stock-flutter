import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/presentation/pages/sales/customer_selection/customer_selection_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/navigation/app_routes.dart';
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
    _viewModel.handleIntent(ClearCustomerIntent());
    _searchController.dispose();
    super.dispose();
  }

  void _openCustomerSelection(BuildContext context) async {
    final selectedCustomer = await showModalBottomSheet<Customer>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => const CustomerSelectionPage(),
      ),
    );

    if (selectedCustomer != null) {
      _viewModel.handleIntent(SelectCustomerIntent(selectedCustomer));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          _viewModel.handleIntent(ClearCustomerIntent());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Registrar Venda'),
        ),
        body: Card(
          elevation: 2,
          margin: const EdgeInsets.all(12.0),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<SalesState>(
              stream: _viewModel.state,
              builder: (context, snapshot) {
                final state = snapshot.data;

                if (state is SalesLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is SalesErrorState) {
                  return Center(child: Text(state.message));
                }

                if (state is SalesSaleSuccessfulState) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Venda finalizada com sucesso!'),
                        backgroundColor: Colors.green,
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
    );
  }

  Widget _buildSalesReadyView(BuildContext context, SalesReadyState state) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildCustomerSection(context, state),
              if (state.selectedCustomer != null) ...[
                const SizedBox(height: 24),
                _buildProductSearchSection(context, state),
              ],
            ],
          ),
        ),
        if (state.cart.isNotEmpty) _buildShoppingCart(state),
      ],
    );
  }

  Widget _buildCustomerSection(BuildContext context, SalesReadyState state) {
    final theme = Theme.of(context);
    final hasCustomer = state.selectedCustomer != null;

    Future<void> _launchWhatsApp(String phone) async {
      final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
      final whatsappUrl = Uri.parse("https://wa.me/55$cleanPhone");

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Não foi possível abrir o WhatsApp para o número $phone')),
          );
        }
      }
    }

    void _showCustomerDetailsDialog(Customer customer) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.person_pin_circle_outlined, color: Colors.blue),
                SizedBox(width: 8),
                Text('Detalhes do Cliente'),
              ],
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  const Divider(),
                  ListTile(
                    title: const Text('Nome',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle:
                    Text(customer.name, style: theme.textTheme.bodyLarge),
                  ),
                  ListTile(
                    title: const Text('Telefone',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(customer.phone,
                        style: theme.textTheme.bodyLarge),
                  ),
                  ListTile(
                    title: const Text('WhatsApp',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        customer.whatsapp.isEmpty
                            ? 'Não informado'
                            : customer.whatsapp,
                        style: theme.textTheme.bodyLarge),
                    trailing: customer.whatsapp.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.open_in_new,
                          color: Colors.green),
                      tooltip: 'Abrir no WhatsApp',
                      onPressed: () =>
                          _launchWhatsApp(customer.whatsapp),
                    )
                        : null,
                  ),
                  ListTile(
                    title: const Text('Endereço',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        customer.address.isEmpty
                            ? 'Não informado'
                            : customer.address,
                        style: theme.textTheme.bodyLarge),
                  ),
                  ListTile(
                    title: const Text('Observação',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        customer.notes.isEmpty
                            ? 'Nenhuma'
                            : customer.notes,
                        style: theme.textTheme.bodyLarge),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('FECHAR'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecione o cliente para pesquisar o produto.',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (hasCustomer)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                const Icon(Icons.person, color: Colors.blue, size: 40),
                title: Text(
                  state.selectedCustomer!.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(state.selectedCustomer!.phone),
                trailing: Wrap(
                  spacing: 0,
                  children: <Widget>[
                    IconButton(
                      icon:
                      const Icon(Icons.info_outline, color: Colors.grey),
                      tooltip: 'Ver Detalhes do Cliente',
                      onPressed: () {
                        _showCustomerDetailsDialog(state.selectedCustomer!);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.change_circle_outlined,
                          color: Colors.orange),
                      tooltip: 'Trocar Cliente',
                      onPressed: () {
                        _openCustomerSelection(context);
                      },
                    ),
                  ],
                ),
              )
            else
              Center(
                child: FilledButton.tonalIcon(
                  icon: const Icon(Icons.person_search),
                  label: const Text('Selecionar ou Cadastrar Cliente'),
                  onPressed: () {
                    _openCustomerSelection(context);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSearchSection(
      BuildContext context, SalesReadyState state) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecione o produto para o cliente ${state.selectedCustomer!.name}',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Pesquise por nome, código ou preço...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (query) {
            _viewModel.handleIntent(SearchProductsIntent(query));
          },
        ),
        const SizedBox(height: 16),
        if (state.isSearching)
          const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              )),
        if (!state.isSearching && state.searchResults.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.searchResults.length,
            itemBuilder: (context, index) {
              final product = state.searchResults[index];
              return _ProductSearchItem(
                product: product,
                onAddToCart: (quantity) {
                  _viewModel.handleIntent(AddProductToCartIntent(product, quantity));
                },
              );
            },
          ),
        if (!state.isSearching &&
            state.currentSearchQuery.isNotEmpty &&
            state.searchResults.isEmpty)
          const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Nenhum produto encontrado.'),
              )),
      ],
    );
  }

  Widget _buildShoppingCart(SalesReadyState state) {
    final theme = Theme.of(context);
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpansionTile(
            title: Row(
              children: [
                const Icon(Icons.shopping_cart_outlined, color: Colors.black54),
                const SizedBox(width: 8),
                Text(
                  'CARRINHO (${state.cart.length} ${state.cart.length == 1 ? 'item' : 'itens'})',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 8),
            children: state.cart.map((item) {
              final product = state.originalProducts.firstWhere(
                    (p) => p.id == item.productId,
                orElse: () => Product(id: '', name: 'Produto não encontrado', description: '', costPrice: 0, salePrice: 0, stockQuantity: 0, lowStockThreshold: 0, categoryId: ''),
              );

              String truncatedDescription = product.description.length > 90
                  ? '${product.description.substring(0, 90)}...'
                  : product.description;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: ListTile(
                    leading: const Icon(Icons.inventory_2_outlined,
                        color: Colors.grey, size: 26),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                          child: Text(
                            truncatedDescription,
                            style: theme.textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    size: 22),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  _viewModel.handleIntent(
                                      DecrementCartItemIntent(item.productId));
                                },
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${item.quantity}',
                                style: theme.textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon:
                                const Icon(Icons.add_circle_outline, size: 22),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  _viewModel.handleIntent(
                                      IncrementCartItemIntent(item.productId));
                                },
                              ),
                            ],
                          ),
                          Text(
                            '${item.quantity} x R\$ ${item.pricePerUnit.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.black54),
                          ),
                         /*  IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              tooltip: 'Remover item',
                              onPressed: () {
                                _viewModel.handleIntent(
                                    RemoveProductFromCartIntent(item.productId));
                              },
                            ),*/
                        ],
                      ),
                    ),

                  ),
                ),
              );
            }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL', style: theme.textTheme.titleMedium),
              Text(
                'R\$ ${state.cartTotal.toStringAsFixed(2)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Finalizar Venda'),
              onPressed: () {
                _viewModel.handleIntent( FinalizeSaleIntent());
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductSearchItem extends StatefulWidget {
  final Product product;
  final Function(int quantity) onAddToCart;

  const _ProductSearchItem({required this.product, required this.onAddToCart});

  @override
  State<_ProductSearchItem> createState() => __ProductSearchItemState();
}

class __ProductSearchItemState extends State<_ProductSearchItem> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final bool hasStock = widget.product.stockQuantity > 0;
    final bool isStockMaxedOut = _quantity >= widget.product.stockQuantity;
    final bool isLowStock =
        hasStock && widget.product.stockQuantity <= widget.product.lowStockThreshold;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      color: hasStock ? Colors.white : Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              title: Text(widget.product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle:
              Text('R\$ ${widget.product.salePrice.toStringAsFixed(2)}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Estoque:'),
                  Text(
                    '${widget.product.stockQuantity}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isLowStock
                          ? Colors.orange.shade800
                          : (hasStock ? Colors.green.shade700 : Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

                if (hasStock) ...[
                  // Se TEM estoque, mostra os controles de quantidade
                  const Text('Quantidade:'),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      _quantity.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Tooltip(
                    message: isStockMaxedOut
                        ? 'Estoque máximo atingido'
                        : 'Incrementar quantidade',
                    child: IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: !isStockMaxedOut
                          ? () => setState(() => _quantity++)
                          : null,
                    ),
                  ),
                ] else ...[
                  // Se NÃO TEM estoque, mostra a mensagem
                  const Row(
                    children: [
                      Icon(
                        Icons.sentiment_very_dissatisfied, // Ícone de carinha triste
                        color: Colors.red,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Produto esgotado',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
                const Spacer(),
                FilledButton(
                  onPressed: hasStock ? () => widget.onAddToCart(_quantity) : null,
                  child: const Text('Adicionar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
