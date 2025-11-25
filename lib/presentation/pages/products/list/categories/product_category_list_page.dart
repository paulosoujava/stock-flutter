import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/category/category.dart';
import '../../../../../core/navigation/app_routes.dart';
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
  // --- LÓGICA ORIGINAL 100% PRESERVADA ---
  late final ProductCategoryListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ProductCategoryListViewModel>();
    // Carrega os dados na inicialização
    _viewModel.handleIntent(LoadCategoriesWithProductCount());
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _createCategoryAndRefresh() async {
    final result = await CategoryFormPage.showAsModal(context);
    if (result == true) {
      _viewModel.handleIntent(LoadCategoriesWithProductCount());
    }
  }

  void _navigateToProductList(Category category) {
    context.push(AppRoutes.productList, extra: category);
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
            child: StreamBuilder<ProductCategoryListState>(
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

                  return RefreshIndicator(
                    onRefresh: () async => _viewModel.handleIntent(LoadCategoriesWithProductCount()),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const double maxCardWidth = 380.0;
                        final crossAxisCount = (constraints.maxWidth / maxCardWidth).floor().clamp(1, 4);

                        return GridView.builder(
                          padding: const EdgeInsets.all(24.0),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 2.8,
                          ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final count = categoriesMap[category]!;

                            return _CategoryCard(
                              category: category,
                              productCount: count,
                              onTap: () => _navigateToProductList(category),
                            );
                          },
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
          Text(
            'Produtos por Categoria',
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
            onPressed: _createCategoryAndRefresh,
          ),
        ],
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
            Icon(Icons.search_off_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Nenhuma categoria encontrada',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700]),
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
              onPressed: _createCategoryAndRefresh,
            ),
          ],
        ),
      ),
    );
  }
}

// NOVO CARD DE CATEGORIA REDESENHADO
class _CategoryCard extends StatelessWidget {
  final Category category;
  final int productCount;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.productCount,
    required this.onTap,
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
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.deepPurple.withOpacity(0.1),
                child:
                const Icon(Icons.category_outlined, color: Colors.deepPurple),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$productCount ${productCount == 1 ? "produto" : "produtos"}',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey.shade400,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}