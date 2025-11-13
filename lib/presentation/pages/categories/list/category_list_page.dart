import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/core/navigation/app_routes.dart';
import 'package:stock/domain/entities/category/category.dart';
import 'package:stock/presentation/widgets/category_card.dart';
import 'package:stock/presentation/widgets/confirmation_dialog.dart';
import 'package:badges/badges.dart' as badges;

import 'category_list_intent.dart';
import 'category_list_state.dart';
import 'category_list_viewmodel.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  late final CategoryListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<CategoryListViewModel>();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation(Category category) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Exclusão',
      content: 'Tem certeza de que deseja excluir a categoria "${category.name}"?\n\n'
          '⚠️ Ao excluir esta categoria, TODOS os produtos associados a ela também serão excluídos.',
      confirmText: 'Excluir',
    );
    if (confirmed == true && mounted) {
      _viewModel.handleIntent(DeleteCategoryIntent(category.id));
    }
  }

  Future<void> _navigateAndRefresh() async {
    // CORREÇÃO DA ROTA: Usa a rota de formulário padronizada.
    final result = await context.push<bool>(AppRoutes.categoryCreate);
    if (result == true && mounted) {
      _viewModel.handleIntent(FetchCategoriesAndCountIntent());
    }
  }

  Future<void> _navigateToEditCategory(Category category) async {
    final result = await context.push<bool>(
      AppRoutes.categoryEdit,
      extra: category,
    );
    if (result == true) {
      _viewModel.handleIntent(FetchCategoriesAndCountIntent());
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Categorias'),
      ),
      body: StreamBuilder<CategoryListState>(
        stream: _viewModel.state,
        builder: (context, snapshot) {
          final state = snapshot.data;
          if (state is CategoryListLoadingState || !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CategoryListErrorState) {
            return Center(child: Text(state.message));
          }
          if (state is CategoryListSuccessState) {
            final categoriesMap = state.categoriesWithCount;
            if (categoriesMap.isEmpty) {
              return _buildEmptyState();
            }
            final categories = categoriesMap.keys.toList();
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final count = categoriesMap[category]!;

                return CategoryCard(
                  category: category,
                  productCount: count,
                  onTap: () => _navigateToEditCategory(category),
                  trailing: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _navigateToEditCategory(category);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(category);
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
                );
              },
            );
          }
          return _buildEmptyState();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateAndRefresh,
        tooltip: 'Adicionar categoria',
        child: const Icon(Icons.add),
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
            Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'Nenhuma categoria cadastrada.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'As categorias são essenciais para organizar seus produtos.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar Primeira Categoria'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: _navigateAndRefresh,
            ),
          ],
        ),
      ),
    );
  }
}
