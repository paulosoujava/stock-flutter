import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/core/navigation/app_routes.dart';
import 'package:badges/badges.dart' as badges;

import 'product_category_list_intent.dart';
import 'product_category_list_state.dart';
import 'product_category_list_viewmodel.dart';

class ProductCategoryListPage extends StatefulWidget {
  const ProductCategoryListPage({super.key});

  @override
  State<ProductCategoryListPage> createState() => _ProductCategoryListPageState();
}

class _ProductCategoryListPageState extends State<ProductCategoryListPage> {
  late final ProductCategoryListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ProductCategoryListViewModel>();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  /// Navega para a tela de criação de categoria e atualiza a lista ao retornar com sucesso.
  Future<void> _createCategoryAndRefresh() async {
    // 1. Usa 'await' para esperar a tela de formulário fechar e retornar um valor.
    //    Usa a rota correta 'categoryForm' que definimos em nosso padrão.
    final result = await context.push<bool>(AppRoutes.categoryCreate);

    // 2. Se o valor retornado for 'true' (o que indica que salvou com sucesso)...
    if (result == true) {
      // 3. ...nós disparamos a intenção para buscar as categorias novamente.
      _viewModel.handleIntent(LoadCategoriesWithProductCount());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos por Categoria'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            tooltip: 'Adicionar Novo Produto',
            onPressed: () {
               context.push(AppRoutes.productByCategory);
            },
          ),
        ],
      ),
      body: StreamBuilder<ProductCategoryListState>(
        stream: _viewModel.state,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is ProductCategoryListLoading || !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductCategoryListError) {
            return Center(child: Text(state.message));
          }

          if (state is NoCategoriesFound) {
            return _buildNoCategoriesState();
          }

          if (state is CategoriesWithProductsCountLoaded) {
            final categoriesMap = state.categoriesWithCount;
            if (categoriesMap.isEmpty) return _buildNoCategoriesState();

            final categories = categoriesMap.keys.toList();
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final count = categoriesMap[category]!;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: badges.Badge(
                      badgeContent: Text(
                        count.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      position: badges.BadgePosition.topEnd(top: -12, end: -12),
                      badgeStyle: const badges.BadgeStyle(
                        badgeColor: Colors.deepPurple,
                      ),
                      child: const Icon(Icons.category_outlined, size: 40, color: Colors.teal),
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      context.push(AppRoutes.productList,extra: category);
                      print("Listar produtos da categoria: ${category.name}");
                    },
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

  Widget _buildNoCategoriesState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'Nenhuma categoria encontrada',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Você precisa ter pelo menos uma categoria para poder cadastrar produtos.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Criar Primeira Categoria'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              // 4. O onPressed agora chama a função correta.
              onPressed: _createCategoryAndRefresh,
            ),
          ],
        ),
      ),
    );
  }
}
