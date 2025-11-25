import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/category/category.dart';
import 'package:stock/presentation/widgets/confirmation_dialog.dart';
import '../../../../core/navigation/app_routes.dart';
import '../form/category_form_page.dart';
import 'category_list_intent.dart';
import 'category_list_state.dart';
import 'category_list_viewmodel.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  // --- LÓGICA ORIGINAL PRESERVADA ---
  late final CategoryListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<CategoryListViewModel>();
    _viewModel.handleIntent(FetchCategoriesAndCountIntent());
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
    final result = await CategoryFormPage.showAsModal(context);
    if (result == true && mounted) {
      _viewModel.handleIntent(FetchCategoriesAndCountIntent());
    }
  }

  Future<void> _navigateToEditCategory(Category category) async {
    final result = await CategoryFormPage.showAsModal(
      context,
      category: category,
    );
    if (result == true) {
      _viewModel.handleIntent(FetchCategoriesAndCountIntent());
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
            child: StreamBuilder<CategoryListState>(
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

                  return RefreshIndicator(
                    onRefresh: () async => _viewModel.handleIntent(FetchCategoriesAndCountIntent()),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const double maxCardWidth = 380.0;
                        final crossAxisCount = (constraints.maxWidth / maxCardWidth).floor().clamp(1, 5);

                        return GridView.builder(
                          padding: const EdgeInsets.all(24.0),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 2.2, // Proporção ajustada para o novo design
                          ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final count = categoriesMap[category]!;

                            return _CategoryCard(
                              category: category,
                              productCount: count,
                              onTap: () =>context.push(AppRoutes.productList, extra: category),
                              onEdit: () => _navigateToEditCategory(category),
                              onDelete: () => _showDeleteConfirmation(category),
                            );
                          },
                        );
                      },
                    ),
                  );
                }
                return _buildEmptyState();
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
          Text(
            'Categorias',
            style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800]),
          ),
          const Spacer(),
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
            label: const Text("Nova Categoria"),
            onPressed: _navigateAndRefresh,
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
            Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Nenhuma categoria cadastrada',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700]),
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
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: _navigateAndRefresh,
            ),
          ],
        ),
      ),
    );
  }
}


class _CategoryCard extends StatelessWidget {
  final Category category;
  final int productCount;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.productCount,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com nome e ações
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.deepPurple.withOpacity(0.1),
                    child: const Icon(Icons.category_outlined,
                        color: Colors.deepPurple),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category.name,
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Menu de Ações
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
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
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    tooltip: 'Mais opções',
                  ),
                ],
              ),
              const Spacer(),
              // Rodapé com contagem de produtos
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 16, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    Text(
                      '$productCount ${productCount == 1 ? "produto" : "produtos"}',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700]),
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
}
