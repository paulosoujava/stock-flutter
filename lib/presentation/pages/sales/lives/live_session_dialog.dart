// live_session_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

// Ajuste esse import para onde fica seu Product se necessário.
// Exemplo que você forneceu anteriormente usa a classe Product com @HiveType.
// Troque o pacote abaixo caso seu projeto use outro caminho.
import 'package:stock/domain/entities/product/product.dart';

import 'list/live_list_page.dart'; // para LiveModel (use o mesmo LiveModel compartilhado)

// -----------------------------------------------------------------------------
// MODELS LOCAIS / ADAPTERS
// -----------------------------------------------------------------------------
class ProductItem {
  final String id;
  final String name;
  final double salePrice;
  final int stock;
  final String description;

  ProductItem({
    required this.id,
    required this.name,
    required this.salePrice,
    required this.stock,
    required this.description,
  });

  // cria a partir do seu Product (Hive)
  factory ProductItem.fromProduct(Product p) => ProductItem(
    id: p.id,
    name: p.name,
    salePrice: p.salePrice,
    stock: p.stockQuantity,
    description: p.description,
  );
}

class BuyerItem {
  String username;
  int quantity;
  BuyerItem({required this.username, this.quantity = 1});
}

class ProductSaleEntry {
  final ProductItem product;
  final List<BuyerItem> buyers;
  ProductSaleEntry({required this.product, required this.buyers});

  double get subtotal =>
      buyers.fold(0, (s, b) => s + b.quantity) * product.salePrice;
}

// Resultado retornado ao fechar (pode adaptar para salvar em repo)
class LiveSessionResult {
  final List<ProductSaleEntry> history;
  final double total;
  LiveSessionResult({required this.history, required this.total});
}

// -----------------------------------------------------------------------------
// LIVE SESSION DIALOG
// -----------------------------------------------------------------------------
class LiveSessionDialog extends StatefulWidget {
  final LiveModel live;

  /// Opcional: passe a lista de produtos já carregada (ex.: do ViewModel).
  /// Se null, o dialog tentará abrir a box Hive chamada 'products' e carregar.
  final List<Product>? productsFromCaller;

  const LiveSessionDialog({
    super.key,
    required this.live,
    this.productsFromCaller,
  });

  @override
  State<LiveSessionDialog> createState() => _LiveSessionDialogState();
}

class _LiveSessionDialogState extends State<LiveSessionDialog> {
  final currency = NumberFormat.simpleCurrency(locale: 'pt_BR');

  ProductItem? selectedProduct;
  final TextEditingController clientCtrl = TextEditingController();
  int defaultQty = 1;

  final List<BuyerItem> currentBuyers = [];
  final List<ProductSaleEntry> history = [];

  List<ProductItem> availableProducts = [];

  bool _loadingProducts = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    // 1) se o caller passou products, use-os
    if (widget.productsFromCaller != null) {
      availableProducts = widget.productsFromCaller!
          .map((p) => ProductItem.fromProduct(p))
          .toList();
      setState(() => _loadingProducts = false);
      return;
    }

    // 2) tentar abrir Hive box 'products' e mapear para ProductItem
    try {
      // certifique-se que Hive.init foi chamado no app principal
      if (Hive.isBoxOpen('products')) {
        final box = Hive.box<Product>('products');
        availableProducts = box.values.map((p) => ProductItem.fromProduct(p)).toList();
      } else {
        final box = await Hive.openBox<Product>('products');
        availableProducts = box.values.map((p) => ProductItem.fromProduct(p)).toList();
      }
    } catch (e) {
      // fallback: lista vazia — (poderíamos criar fakes aqui)
      availableProducts = [];
    } finally {
      setState(() => _loadingProducts = false);
    }
  }

  double get totalLive =>
      history.fold(0.0, (s, e) => s + e.subtotal) +
          (selectedProduct != null ? currentBuyers.fold(0, (sum, b) => sum + b.quantity) * selectedProduct!.salePrice : 0);

  @override
  void dispose() {
    clientCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 980,
        height: 680,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ---------------- Header ----------------
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.live_tv, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(widget.live.title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),

          // info produto selecionado
          if (selectedProduct != null) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(selectedProduct!.name, style: const TextStyle(color: Colors.white)),
                Text(currency.format(selectedProduct!.salePrice),
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            const SizedBox(width: 12),
          ],

          IconButton(
            tooltip: 'Selecionar produto',
            onPressed: _openProductSearch,
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          IconButton(
            tooltip: 'Fechar sessão',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ---------------- Body ----------------
  Widget _buildBody() {
    if (_loadingProducts) {
      return const Center(child: CircularProgressIndicator());
    }

    return Row(
      children: [
        // Left: adicionar compradores / lista compradores do item atual
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Adicionar comprador', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: clientCtrl,
                        decoration: const InputDecoration(
                          labelText: '@instagram',
                          border: OutlineInputBorder(),
                          hintText: '@cliente',
                        ),
                        onSubmitted: (_) => _addBuyer(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 120,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => setState(() => defaultQty = defaultQty > 1 ? defaultQty - 1 : 1),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('$defaultQty'),
                          IconButton(
                            onPressed: () => setState(() => defaultQty++),
                            icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _addBuyer,
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar'),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                Text('Compradores do item', style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
                    child: selectedProduct == null
                        ? const Center(child: Text('Selecione um produto'))
                        : currentBuyers.isEmpty
                        ? const Center(child: Text('Nenhum comprador adicionado'))
                        : ListView.separated(
                      itemBuilder: (_, i) {
                        final b = currentBuyers[i];
                        return ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(b.username),
                          subtitle: Text('Qtd: ${b.quantity} • ${currency.format(selectedProduct!.salePrice)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => setState(() {
                                  if (b.quantity > 1) b.quantity--;
                                  else currentBuyers.removeAt(i);
                                }),
                              ),
                              Text('${b.quantity}'),
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.green),
                                onPressed: () => setState(() => b.quantity++),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editBuyerDialog(b),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => setState(() => currentBuyers.removeAt(i)),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemCount: currentBuyers.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const VerticalDivider(width: 1),

        // Right: histórico (itens já finalizados)
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Histórico da Live', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: history.isEmpty
                      ? const Center(child: Text('Nenhum item registrado'))
                      : ListView.separated(
                    itemCount: history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, idx) {
                      final it = history[idx];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(it.product.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                  Text(currency.format(it.product.salePrice)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Subtotal: ${currency.format(it.subtotal)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              ...it.buyers.map((b) {
                                return Row(
                                  children: [
                                    Expanded(child: Text(b.username)),
                                    Text('x${b.quantity}'),
                                    const SizedBox(width: 12),
                                    IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _editBuyerInHistory(it, b)),
                                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => it.buyers.remove(b))),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- Footer ----------------
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12))),
      child: Row(
        children: [
          // Infos à esquerda
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedProduct != null) Text('${selectedProduct!.name} • ${currency.format(selectedProduct!.salePrice)}'),
                Text('Subtotal do item: ${currency.format(selectedProduct == null ? 0 : currentBuyers.fold(0, (s, b) => s + b.quantity) * selectedProduct!.salePrice)}'),
                const SizedBox(height: 6),
                Text('Total da live: ${currency.format(totalLive)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Ações
          FilledButton.tonal(
            onPressed: _nextItem,
            child: const Text('Próximo Item'),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: _finish,
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Finalizar Live'),
          )
        ],
      ),
    );
  }

  // ---------------- Actions / Helpers ----------------
  void _addBuyer() {
    final name = clientCtrl.text.trim();
    if (name.isEmpty || selectedProduct == null) return;

    // se já existe, incrementa
    final idx = currentBuyers.indexWhere((c) => c.username.toLowerCase() == name.toLowerCase());
    if (idx >= 0) {
      setState(() => currentBuyers[idx].quantity += defaultQty);
    } else {
      setState(() => currentBuyers.add(BuyerItem(username: name, quantity: defaultQty)));
    }
    clientCtrl.clear();
    defaultQty = 1;
  }

  Future<void> _editBuyerDialog(BuyerItem b) async {
    final nameCtrl = TextEditingController(text: b.username);
    final qtyCtrl = TextEditingController(text: b.quantity.toString());
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar comprador'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: '@instagram')),
            const SizedBox(height: 8),
            TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantidade')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Salvar')),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        b.username = nameCtrl.text.trim();
        b.quantity = int.tryParse(qtyCtrl.text) ?? b.quantity;
      });
    }
  }

  Future<void> _editBuyerInHistory(ProductSaleEntry entry, BuyerItem b) async {
    await _editBuyerDialog(b);
    setState(() {}); // recalcula subtotais
  }

  void _nextItem() {
    if (selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione um produto antes de registrar.')));
      return;
    }
    if (currentBuyers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adicione ao menos um comprador.')));
      return;
    }

    // registra no histórico
    final copied = ProductSaleEntry(
      product: selectedProduct!,
      buyers: currentBuyers.map((b) => BuyerItem(username: b.username, quantity: b.quantity)).toList(),
    );

    setState(() {
      history.add(copied);
      selectedProduct = null;
      currentBuyers.clear();
    });

    // abre seleção de produto automaticamente para agilizar o fluxo
    Future.delayed(const Duration(milliseconds: 150), _openProductSearch);
  }

  void _finish() {
    final result = LiveSessionResult(history: List.from(history), total: totalLive);
    Navigator.pop(context, result);
  }

  Future<void> _openProductSearch() async {
    // Mostra dialog com a lista de availableProducts (name + salePrice)
    final picked = await showDialog<ProductItem?>(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: SizedBox(
            width: 520,
            height: 520,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      const Text('Selecionar produto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context, null)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: availableProducts.isEmpty
                      ? const Center(child: Text('Nenhum produto disponível'))
                      : ListView.separated(
                    itemCount: availableProducts.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final p = availableProducts[i];
                      return ListTile(
                        title: Text(p.name),
                        subtitle: Text(p.description),
                        trailing: Text(currency.format(p.salePrice)),
                        onTap: () => Navigator.pop(context, p),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() => selectedProduct = picked);
    }
  }
}
