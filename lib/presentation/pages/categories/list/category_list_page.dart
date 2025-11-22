import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/core/navigation/app_routes.dart';
import 'package:stock/domain/entities/category/category.dart';
import 'package:stock/presentation/widgets/category_card.dart';
import 'package:stock/presentation/widgets/confirmation_dialog.dart';
import 'package:badges/badges.dart' as badges;

import '../../../../core/di/app_module.dart';
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

    //final result = await context.push<bool>(AppRoutes.categoryCreate);

    final result = await CategoryFormPage.showAsModal(context);

    if (result == true && mounted) {
      _viewModel.handleIntent(FetchCategoriesAndCountIntent());
    }
  }

  Future<void> _navigateToEditCategory(Category category) async {
    /*final result = await context.push<bool>(
      AppRoutes.categoryEdit,
      extra: category,
    );*/
    final result = await CategoryFormPage.showAsModal(
      context,
      category: category, // Passa o objeto 'category' a ser editado.
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
          actions: [
            IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Cadastrar categoria',
                onPressed:_navigateAndRefresh),
            SizedBox(
              width: 20,
            )
          ]
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

            return LayoutBuilder(
              builder: (context, constraints) {
                // Definimos a largura ideal/máxima para cada card.
                const double maxCardWidth = 400.0;

                // Calculamos quantas colunas de cards cabem na largura atual da tela.
                // .clamp(1, 4) garante que teremos no mínimo 1 e no máximo 4 colunas.
                final crossAxisCount = (constraints.maxWidth / maxCardWidth).floor().clamp(1, 4);

                return GridView.builder(
                  // Adicionamos um padding generoso para a grade não colar nas bordas.
                  padding: const EdgeInsets.all(24.0),

                  // Configuração da grade.
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount, // O número de colunas que calculamos.
                    crossAxisSpacing: 20,           // Espaçamento horizontal entre os cards.
                    mainAxisSpacing: 20,            // Espaçamento vertical entre os cards.
                    childAspectRatio: 3.5,          // Proporção (largura/altura). Ajuste se necessário.
                  ),

                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final count = categoriesMap[category]!;

                    return CategoryCard(
                      category: category,
                      productCount: count,
                      // Ação principal de clique no card continua sendo a edição.
                      onTap: () => _navigateToEditCategory(category),

                      // As ações de ícone se encaixam perfeitamente no novo layout.
                      actions: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Tooltip(
                            message: 'Editar Categoria',
                            child: IconButton(
                              icon: Icon(Icons.edit_outlined, color: Theme.of(context).primaryColor),
                              onPressed: () => _navigateToEditCategory(category),
                              splashRadius: 20,
                            ),
                          ),
                          Tooltip(
                            message: 'Excluir Categoria',
                            child: IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.red.shade600),
                              onPressed: () => _showDeleteConfirmation(category),
                              splashRadius: 20,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );

          }
          return _buildEmptyState();
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
