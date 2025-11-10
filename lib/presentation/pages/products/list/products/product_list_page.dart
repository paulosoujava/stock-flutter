import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  late final ProductListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ProductListViewModel>();
    _loadProducts();
  }

  void _loadProducts() {
    _viewModel.handleIntent(LoadProducts(widget.category.id));
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  /// Navega para o formulário para CRIAR um novo produto.
  void _navigateToCreateProduct() async {
    final result = await context.push<bool>(
      AppRoutes.productCreate,
      extra: widget.category,
    );
    if (result == true) {
      _loadProducts();
    }
  }

  /// Navega para o formulário para EDITAR um produto existente.
  void _navigateToEditProduct(Product product) async {
    final result = await context.push<bool>(
      AppRoutes.productEdit,
      extra: {
        'product': product,
        'category': widget.category,
      },
    );
    if (result == true) {
      _loadProducts();
    }
  }

  /// Mostra um diálogo de confirmação antes de DELETAR um produto.
  void _showDeleteConfirmation(Product product) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Exclusão',
      content: 'Tem certeza de que deseja excluir o produto "${product.name}"?',
      confirmText: 'Excluir',
    );

    if (confirmed == true && mounted) {
       _viewModel.handleIntent(DeleteProductIntent(product.id));
      print("Deletar produto: ${product.id}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produto "${product.name}" excluído.')),
      );
      // Recarrega a lista após a exclusão
      _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            tooltip: 'Adicionar Produto',
            onPressed: _navigateToCreateProduct,
          ),
        ],
      ),
      body: StreamBuilder<ProductListState>(
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
            if (state.products.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final product = state.products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(
                          'Qtd: ${product.stockQuantity}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'R\$ ${product.salePrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _navigateToEditProduct(product);
                            } else if (value == 'delete') {
                              _showDeleteConfirmation(product);
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: ListTile(
                                leading: Icon(Icons.edit_outlined),
                                title: Text('Editar'),
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete_outline, color: Colors.red),
                                title: Text('Excluir', style: TextStyle(color: Colors.red)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
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
            const Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'Nenhum produto cadastrado',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: _navigateToCreateProduct,
            ),
          ],
        ),
      ),
    );
  }
}

