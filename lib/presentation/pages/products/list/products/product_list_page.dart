import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/core/navigation/app_routes.dart';
import 'package:stock/domain/entities/category/category.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/presentation/widgets/confirmation_dialog.dart';

import 'product_list_intent.dart';
import 'product_list_state.dart';
import 'product_list_viewmodel.dart';

class ProductListPage extends StatefulWidget {
  final Category category;

  const ProductListPage({super.key, required this.category});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  // --- LÓGICA ORIGINAL 100% PRESERVADA ---
  late final ProductListViewModel _viewModel;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ProductListViewModel>();
    _loadProducts();
    _searchController.addListener(() {
      _viewModel.handleIntent(SearchProducts(_searchController.text));
    });
  }

  void _loadProducts() {
    _viewModel.handleIntent(LoadProducts(widget.category.id));
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToCreateProduct() async {
    final result = await context.push<bool>(
      AppRoutes.productCreate,
      extra: widget.category,
    );
    if (result == true) {
      _loadProducts();
    }
  }

  void _navigateToEditProduct(Product product) async {
    final result = await context.push<bool>(
      AppRoutes.productEdit,
      extra: {'product': product, 'category': widget.category},
    );
    if (result == true) {
      _loadProducts();
    }
  }

  void _showDeleteConfirmation(Product product) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Exclusão',
      content: 'Tem certeza de que deseja excluir o produto "${product.name}"?',
      confirmText: 'Excluir',
    );

    if (confirmed == true && mounted) {
      _viewModel.handleIntent(DeleteProductIntent(product.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produto "${product.name}" excluído.')),
      );
      _loadProducts();
    }
  }
  // --- FIM DA LÓGICA ORIGINAL ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder<ProductListState>(
              stream: _viewModel.state,
              builder: (context, snapshot) {
                final state = snapshot.data;

                if (state is ProductListLoading || !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ProductListError) {
                  return Center(child: Text(state.message));
                }

                if (state is ProductListLoaded) {
                  if (state.allProducts.isEmpty) {
                    return _buildEmptyState();
                  }

                  if (state.displayedProducts.isEmpty &&
                      _searchController.text.isNotEmpty) {
                    return Center(
                      child: Text(
                          'Nenhum produto encontrado para "${_searchController.text}"'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadProducts(),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 350,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.2, // Proporção ajustada para o card sem imagem
                      ),
                      itemCount: state.displayedProducts.length,
                      itemBuilder: (context, index) {
                        final product = state.displayedProducts[index];
                        return _ProductCard(
                          product: product,
                          onEdit: () => _navigateToEditProduct(product),
                          onDelete: () => _showDeleteConfirmation(product),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
            tooltip: 'Voltar',
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Produtos da Categoria',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  widget.category.name,
                  style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800]),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 300,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar produto...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                filled: true,
                contentPadding: EdgeInsets.zero,
                fillColor: Colors.grey[100],
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            icon: const Icon(Icons.add, size: 20),
            label: const Text("Novo Produto"),
            onPressed: _navigateToCreateProduct,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Nenhum produto cadastrado',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione o primeiro produto para a categoria "${widget.category.name}".',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar Primeiro Produto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: _navigateToCreateProduct,
            ),
          ],
        ),
      ),
    );
  }
}

// CARD DE PRODUTO REDESENHADO E CORRIGIDO
class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
    NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2);
    final hasStock = product.stockQuantity > 0;
    final isLowStock = hasStock && product.stockQuantity <= product.lowStockThreshold;

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200, width: 1)
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- CABEÇALHO: NOME E AÇÕES ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: ListTile(
                            leading: Icon(Icons.edit_outlined),
                            title: Text('Editar')),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                            leading:
                            Icon(Icons.delete_outline, color: Colors.red),
                            title: Text('Excluir',
                                style: TextStyle(color: Colors.red))),
                      ),
                    ],
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    tooltip: 'Mais opções',
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // --- DESCRIÇÃO ---
              if (product.description.isNotEmpty)
                Text(
                  product.description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

              const Spacer(), // Empurra os próximos itens para o rodapé

              // --- PREÇOS ---
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPriceColumn('Custo', product.costPrice, currencyFormat),
                  _buildPriceColumn('Venda', product.salePrice, currencyFormat, highlight: true),
                ],
              ),

              const Spacer(),

              // --- RODAPÉ: ESTOQUE ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (isLowStock
                      ? Colors.orange.shade700
                      : (hasStock
                      ? Colors.green.shade700
                      : Colors.red))
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLowStock ? Icons.warning_amber_rounded :
                      (hasStock ? Icons.check_circle_outline : Icons.error_outline),
                      size: 16,
                      color: isLowStock ? Colors.orange.shade800 : (hasStock ? Colors.green.shade800 : Colors.red.shade800),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Estoque: ${product.stockQuantity}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isLowStock ? Colors.orange.shade800 : (hasStock ? Colors.green.shade800 : Colors.red.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para exibir os preços
  Widget _buildPriceColumn(String label, double value, NumberFormat format, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        Text(
          format.format(value),
          style: GoogleFonts.poppins(
            fontSize: highlight ? 20 : 16,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            color: highlight ? Colors.deepPurple : Colors.grey[800],
          ),
        ),
      ],
    );
  }
}
