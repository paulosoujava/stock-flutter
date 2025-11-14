// Ficheiro: lib/presentation/pages/lives_sales/session/live_session_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/presentation/pages/lives_sales/session/live_session_intent.dart';
import 'package:stock/presentation/pages/lives_sales/session/live_session_state.dart';
import 'package:stock/presentation/pages/lives_sales/session/live_session_viewmodel.dart';

class LiveSessionPage extends StatefulWidget {
  final String? liveId;

  const LiveSessionPage({super.key, this.liveId});

  @override
  State<LiveSessionPage> createState() => _LiveSessionPageState();
}

class _LiveSessionPageState extends State<LiveSessionPage> {
  late final LiveSessionViewModel _viewModel;

  final _buyerTextController = TextEditingController();
  final _productSearchController = TextEditingController();

  dynamic _selectedBuyer; // pode ser Customer ou String (nome livre)
  Product? _selectedProduct;
  int _quantity = 1;

  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  int _autocompleteKeyCounter = 0;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<LiveSessionViewModel>();
    if (widget.liveId != null) {
      _viewModel.handleIntent(
          LoadLiveSessionDataIntent(widget.liveId!, forceReload: false));
    }
  }

  @override
  void dispose() {
    // NÃO fechamos o ViewModel para preservar estado entre telas.
    _buyerTextController.dispose();
    _productSearchController.dispose();
    super.dispose();
  }

  void _incrementQuantity(int available) {
    setState(() {
      if (_selectedProduct != null && _quantity < available) {
        _quantity++;
      }
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (_quantity > 1) _quantity--;
    });
  }

  void _clearLocalInputs() {
    _buyerTextController.clear();
    _productSearchController.clear();
    _selectedBuyer = null;
    _selectedProduct = null;
    _quantity = 1;
    _autocompleteKeyCounter++;
    FocusScope.of(context).unfocus();
  }

  // Cria um Customer temporário caso o buyer seja String (nome livre).
  // OBS: assume construtor Customer({required String id, required String name})
  Customer _makeTempCustomerFromName(String name) {
    final id = 'temp-${DateTime.now().millisecondsSinceEpoch}';
    try {
      return Customer(
          id: id,
          name: name,
          cpf: '',
          email: '',
          phone: '',
          whatsapp: '',
          address: '');
    } catch (_) {
      // Se sua classe Customer possuir outro construtor, adapte aqui.
      throw Exception(
          'Adapte _makeTempCustomerFromName para a assinatura do seu Customer.');
    }
  }

  void _onAddPressed(Map<String, int> sessionStock) {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecione um produto.'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    // aceite buyer texto livre: cria Customer temporário
    Customer customer;
    if (_selectedBuyer is Customer) {
      customer = _selectedBuyer as Customer;
    } else if (_selectedBuyer is String) {
      customer = _makeTempCustomerFromName(_selectedBuyer as String);
      // aviso sutil
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Comprador não cadastrado — será registrado como temporário. Cadastre-o ao finalizar.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecione ou digite o @ do comprador.'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    final product = _selectedProduct!;
    final available = sessionStock[product.id] ?? product.stockQuantity;
    if (_quantity <= 0 || _quantity > available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Quantidade inválida ou maior que o estoque.'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    _viewModel.handleIntent(AddSaleItemIntent(
        customer: customer, product: product, quantity: _quantity));
    _clearLocalInputs();
  }

  // agrupa por nome do comprador (usa customer.name)
  Map<String, List<LiveSaleItem>> _groupByBuyer(List<LiveSaleItem> items) {
    final map = <String, List<LiveSaleItem>>{};
    for (final it in items) {
      final name = it.customer.name;
      map.putIfAbsent(name, () => []);
      map[name]!.add(it);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Em Live...'),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              // A sua lógica existente de finalizar a live e navegar
              _viewModel.handleIntent(FinalizeLiveIntent());
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.stop_circle_outlined, size: 18),
            label: const Text('FINALIZAR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700, // Cor de destaque para finalizar
              foregroundColor: Colors.white, // Cor do texto e do ícone
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(
            width: 8,
          )
        ],
      ),
      body: StreamBuilder<LiveSessionState>(
        stream: _viewModel.state,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state == null || state is LiveSessionLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LiveSessionErrorState) {
            return Center(
                child: Text(state.message,
                    style: const TextStyle(color: Colors.red)));
          }

          if (state is LiveSessionWarningState) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.orange));
            });
          }

          if (state is LiveSessionSuccessState) {
            final saleItems = state.saleItems;
            final grouped = _groupByBuyer(saleItems);
            final buyers = grouped.keys.toList();

            return Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: Column(
                children: [
                  _buildSalesInputPanel(state),
                  const Divider(thickness: 2),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: buyers.length,
                      itemBuilder: (context, index) {
                        final buyerName = buyers[index];
                        final items = grouped[buyerName]!;
                        final total =
                            items.fold(0.0, (s, it) => s + it.totalValue);
                        return _buildBuyerCard(
                            buyerName, items, total, state.sessionStock);
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                    color: Colors.grey.shade50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total da Sessão',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 23,
                            )),
                        Text(
                            "💰 ${_currencyFormat.format(saleItems.fold(
                                0.0, (s, it) => s + it.totalValue))} 💰",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 23,
                              color: Colors.green,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Carregando dados da live...'));
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INPUT
  // ---------------------------------------------------------------------------

  Widget _buildSalesInputPanel(LiveSessionSuccessState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBuyerAutocomplete(state),
          const SizedBox(height: 12),
          _buildProductAutocomplete(state, state.sessionStock),
          const SizedBox(height: 8),
          // aviso sutil e botão para marcar cadastro do comprador se for texto livre
          if (_selectedBuyer is String)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Colors.orange, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(
                          'Comprador não cadastrado. Você pode finalizar a venda, e cadastrar depois.',
                          style: const TextStyle(color: Colors.orange))),
                  IconButton(
                    tooltip: 'Marcar para cadastrar depois',
                    icon: const Icon(Icons.person_add, color: Colors.orange),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Marcado para cadastro posterior.'),
                        backgroundColor: Colors.orange,
                      ));
                    },
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          _buildQuantityAndAddButton(state.sessionStock),
        ],
      ),
    );
  }

  Widget _buildBuyerAutocomplete(LiveSessionSuccessState state) {
    final key =
        Key('buyer_${_autocompleteKeyCounter}_${state.saleItems.length}');
    return Autocomplete<Object>(
      key: key,
      optionsBuilder: (value) {
        if (value.text.isEmpty) return const Iterable<Object>.empty();
        final input = value.text.toLowerCase();
        final matches = state.availableCustomers
            .where((c) => c.name.toLowerCase().contains(input));
        return matches.isEmpty ? [value.text] : matches;
      },
      displayStringForOption: (option) =>
          option is Customer ? option.name : option.toString(),
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        _buyerTextController.value = controller.value;
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: '@ do Comprador',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.person),
          ),
        );
      },
      onSelected: (selection) {
        setState(() {
          _selectedBuyer = selection;
          _buyerTextController.text =
              selection is Customer ? selection.name : selection.toString();
        });
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Material(
          elevation: 4,
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: options.map((opt) {
              return ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(opt is Customer ? opt.name : opt.toString()),
                subtitle: opt is Customer
                    ? Text(opt.email ?? '')
                    : const Text('Cliente não cadastrado',
                        style: TextStyle(color: Colors.orange)),
                trailing: opt is Customer
                    ? null
                    : const Icon(Icons.add_circle, color: Colors.green),
                onTap: () => onSelected(opt),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildProductAutocomplete(
      LiveSessionSuccessState state, Map<String, int> sessionStock) {
    final key =
        Key('product_${_autocompleteKeyCounter}_${state.saleItems.length}');
    return Autocomplete<Product>(
      key: key,
      optionsBuilder: (value) {
        if (value.text.isEmpty) return const Iterable<Product>.empty();
        final input = value.text.toLowerCase();
        return state.availableProducts
            .where((p) => p.name.toLowerCase().contains(input));
      },
      displayStringForOption: (p) => p.name,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        _productSearchController.value = controller.value;
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Pesquisar Produto',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.inventory_2),
          ),
        );
      },
      onSelected: (product) {
        setState(() {
          _selectedProduct = product;
          _productSearchController.text = product.name;
        });
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Material(
          elevation: 4,
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: options.map((opt) {
              final available = sessionStock[opt.id] ?? opt.stockQuantity;
              final low = available <= opt.lowStockThreshold && available > 0;
              return ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(opt.name),
                subtitle: Text('Restam: $available'),
                trailing: low
                    ? const Icon(Icons.warning, color: Colors.orange)
                    : null,
                onTap: () => onSelected(opt),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildQuantityAndAddButton(Map<String, int> sessionStock) {
    final availableForSelected = _selectedProduct == null
        ? 0
        : (sessionStock[_selectedProduct!.id] ??
            _selectedProduct!.stockQuantity);

    final canAdd = _selectedProduct != null &&
        (_selectedBuyer is Customer || _selectedBuyer is String) &&
        _quantity > 0 &&
        _quantity <= availableForSelected;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /*Row(
          children: [
            // desabilita botão - se quantidade mínima
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: _quantity > 1 ? _decrementQuantity : null,
            ),
            Text('$_quantity',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // se não há estoque disponível, bloqueia incremento
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: (_selectedProduct == null)
                  ? null
                  : () {
                      final available = sessionStock[_selectedProduct!.id] ??
                          _selectedProduct!.stockQuantity;
                      if (_quantity < available) _incrementQuantity(available);
                    },
            ),
          ],
        ),*/
        ElevatedButton.icon(
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('Adicionar'),
          onPressed: canAdd ? () => _onAddPressed(sessionStock) : null,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // BUYER CARD
  // ---------------------------------------------------------------------------

  Widget _buildBuyerCard(String buyerName, List<LiveSaleItem> items,
      double total, Map<String, int> sessionStock) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        childrenPadding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(buyerName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(
            '${items.length} itens • Total ${_currencyFormat.format(total)}'),
        children: [
          Column(
            children: items.map((item) {
              return Column(
                children: [
                  _buildDashedDivider(),
                  _buildProductLineWithStock(item, sessionStock),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductLineWithStock(
      LiveSaleItem item, Map<String, int> sessionStock) {
    final available =
        sessionStock[item.product.id] ?? item.product.stockQuantity;
    final lowStock =
        available <= item.product.lowStockThreshold && available > 0;
    final outOfStock = available <= 0;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade100,
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 22),
          const SizedBox(width: 10),

          // controls
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: item.quantity > 1
                ? () {
                    final newQty = item.quantity - 1;
                    _viewModel.handleIntent(UpdateSaleItemQuantityIntent(
                        customer: item.customer,
                        product: item.product,
                        newQuantity: newQty));
                  }
                : null,
          ),
          Text('${item.quantity}x', style: const TextStyle(fontSize: 15)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            onPressed: outOfStock
                ? null
                : () {
                    final newQty = item.quantity + 1;
                    _viewModel.handleIntent(UpdateSaleItemQuantityIntent(
                        customer: item.customer,
                        product: item.product,
                        newQuantity: newQty));
                  },
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name,
                    style: const TextStyle(fontSize: 15),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                if (outOfStock)
                  Text('Sem estoque',
                      style:
                          TextStyle(color: Colors.red.shade700, fontSize: 12))
                else if (lowStock)
                  Text('Estoque baixo: restam $available',
                      style:
                          const TextStyle(color: Colors.orange, fontSize: 12))
                else
                  Text('Restam: $available',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_currencyFormat.format(item.totalValue),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green)),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  _viewModel.handleIntent(RemoveSaleItemIntent(
                      customer: item.customer, product: item.product));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashedDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dashWidth = 6.0;
          const dashSpace = 4.0;
          final dashCount =
              (constraints.maxWidth / (dashWidth + dashSpace)).floor();

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              dashCount,
              (_) => Container(
                width: dashWidth,
                height: 1,
                color: Colors.grey.shade400,
              ),
            ),
          );
        },
      ),
    );
  }
}
