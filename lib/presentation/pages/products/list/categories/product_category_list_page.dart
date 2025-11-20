import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/core/navigation/app_routes.dart';
import 'package:badges/badges.dart' as badges;
import 'package:stock/domain/entities/category/category.dart';
import 'package:stock/presentation/widgets/category_card.dart';

import '../../../../../core/di/app_module.dart';
import 'product_category_list_intent.dart';
import 'product_category_list_state.dart';
import 'product_category_list_viewmodel.dart';

class ProductCategoryListPage extends StatefulWidget {
  const ProductCategoryListPage({super.key});

  @override
  State<ProductCategoryListPage> createState() =>
      _ProductCategoryListPageState();
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
    // Usa 'await' para esperar a tela de formulário fechar e retornar um valor.
    //    Usa a rota correta 'categoryForm' que definimos em nosso padrão.
    final result = await context.push<bool>(AppRoutes.categoryCreate);

    // Se o valor retornado for 'true' (o que indica que salvou com sucesso)...
    if (result == true) {
      // ...nós disparamos a intenção para buscar as categorias novamente.
      _viewModel.handleIntent(LoadCategoriesWithProductCount());
    }
  }

  void _navigateToProductList(Category category) {
    context.push(AppRoutes.productList, extra: category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produtos por Categoria'),
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
                return CategoryCard(
                  category: category,
                  productCount: count,
                  onTap: () => _navigateToProductList(category),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.grey,
                    size: 20,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
