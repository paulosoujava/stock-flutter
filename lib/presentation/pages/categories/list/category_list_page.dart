// lib/presentation/pages/category/list/category_list_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/core/navigation/app_router.dart';
import 'package:stock/core/navigation/app_routes.dart';
import 'package:stock/domain/entities/category/category.dart';
import 'package:stock/presentation/widgets/confirmation_dialog.dart';
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
    // Obtém a instância do ViewModel via Injeção de Dependência
    _viewModel = getIt<CategoryListViewModel>();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  // Função para mostrar o pop-up de confirmação de exclusão
  void _showDeleteConfirmation(Category category) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Exclusão',
      content: 'Tem certeza de que deseja excluir a categoria "${category.name}"?. Ao excluir esta categoria, ⚠️ TODOS ⚠️ os produtos associados a ela também serão excluídos.',
      confirmText: 'Excluir',
    );

    if (confirmed == true) {
      _viewModel.handleIntent(DeleteCategoryIntent(category.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Categoria "${category.name}" excluída.')),
        );
      }
    }
  }

  // Função para navegar para a tela de formulário
  Future<void> _navigateAndRefresh() async {
    final result = await context.push<bool>(AppRoutes.categoryCreate);
    if (result == true && mounted) {
      _viewModel.handleIntent(FetchCategoriesIntent());
    }
  }

  Future<void> _navigateToEditCategory(Category category) async {
    // Navega para a mesma tela de formulário, mas passa a categoria
    // como um argumento extra para que o formulário possa ser pré-preenchido.
    final result = await context.push<bool>(
      AppRoutes.categoryEdit, // Usaremos uma nova rota para clareza
      extra: category, // O GoRouter permite passar objetos como 'extra'
    );
    // Se o formulário retornou 'true' (sucesso), recarregamos a lista
    if (result == true) {
      _viewModel.handleIntent(FetchCategoriesIntent());
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: _navigateAndRefresh,
            tooltip: 'Nova Categoria',
          ),
        ],
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
            // Se a lista estiver vazia, mostra a tela de "call-to-action"
            if (state.categories.isEmpty) {
              return _buildEmptyState();
            }

            // Se houver dados, mostra a lista
            return ListView.builder(
              itemCount: state.categories.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final category = state.categories[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.label_outline, color: Colors.deepPurple),
                    title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min, // Faz a Row ocupar o mínimo de espaço
                      children: [
                        // --- Ícone de Edição (NOVO) ---
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey),
                          tooltip: 'Editar',
                          onPressed: () {
                            // TODO: Implementar a navegação para a tela de edição
                            print('Editar categoria: ${category.name}');
                            _navigateToEditCategory(category); // Chamaremos esta nova função
                          },
                        ),
                        // --- Ícone de Exclusão (JÁ EXISTENTE) ---
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          tooltip: 'Excluir',
                          onPressed: () => _showDeleteConfirmation(category),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink(); // Estado inesperado
        },
      ),
    );
  }

  // Widget para o estado de lista vazia
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
