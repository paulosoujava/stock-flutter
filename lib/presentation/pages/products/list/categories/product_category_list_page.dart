import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/core/navigation/app_routes.dart';
import 'package:badges/badges.dart' as badges;
import 'package:stock/domain/entities/category/category.dart';
import 'package:stock/presentation/widgets/category_card.dart';

import '../../../../../core/di/app_module.dart';
import '../../../categories/form/category_form_page.dart';
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

  Future<void> _createCategoryAndRefresh() async {
    //final result = await context.push<bool>(AppRoutes.categoryCreate);
    final result = await CategoryFormPage.showAsModal(
      context, // Passa o objeto 'category' a ser editado.
    );
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

            return LayoutBuilder(
              builder: (context, constraints) {
                // Definimos a largura máxima de cada card.
                const double maxCardWidth = 350.0;
                // Calculamos quantas colunas cabem na tela.
                // O mínimo é 1 coluna (em celulares na vertical).
                final crossAxisCount = (constraints.maxWidth / maxCardWidth).floor().clamp(1, 4);

                return GridView.builder(
                  // Padding para a grade não ficar colada nas bordas
                  padding: const EdgeInsets.all(24.0),

                  // Configuração da grade
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount, // Número de colunas calculado
                    crossAxisSpacing: 20,           // Espaçamento horizontal entre os cards
                    mainAxisSpacing: 20,            // Espaçamento vertical entre os cards
                    childAspectRatio: 2.8,          // Proporção (largura/altura) do card
                  ),

                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final count = categoriesMap[category]!;

                    // Chamando o nosso novo e melhorado CategoryCard
                    return CategoryCard(
                      category: category,
                      productCount: count,
                      onTap: () => _navigateToProductList(category),
                      actions: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.grey.shade400, // Cor um pouco mais suave
                        size: 18,
                      ),
                    );
                  },
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
