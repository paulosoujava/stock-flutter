import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/navigation/app_routes.dart';
import 'package:stock/domain/entities/category/category.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/entities/product/product.dart';
import 'package:stock/presentation/pages/categories/form/category_form_page.dart';
import 'package:stock/presentation/pages/categories/list/category_list_page.dart';
import 'package:stock/presentation/pages/customer/form/customer_form_page.dart';

import 'package:stock/presentation/pages/customer/list/customer_list_page.dart';
import 'package:stock/presentation/pages/home/home_page.dart';
import 'package:stock/presentation/pages/products/form/product_form_page.dart';
import 'package:stock/presentation/pages/products/list/categories/product_category_list_page.dart';
import 'package:stock/presentation/pages/products/list/products/product_list_page.dart';
import 'package:stock/presentation/pages/sales/sales_page.dart';
import 'package:stock/presentation/widgets/error_route_page.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  observers: [GoRouterObserver()],
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),

//CUSTOMER
    GoRoute(
      path: AppRoutes.customerList,
      builder: (context, state) => const CustomerListPage(),
    ),
    GoRoute(
      path: AppRoutes.customerCreate,
      builder: (context, state) => const CustomerCreatePage(),
    ),
    GoRoute(
      path: AppRoutes.customerEdit,
      builder: (context, state) {
        final customer = state.extra as Customer?;
        return CustomerCreatePage(customerToEdit: customer);
      },
    ),
//CATEGORY
    GoRoute(
      path: AppRoutes.categoryList,
      builder: (context, state) => const CategoryListPage(),
    ),
    GoRoute(
      path: AppRoutes.categoryCreate,
      builder: (context, state) => const CategoryCreatePage(),
    ),
    GoRoute(
      path: AppRoutes.categoryEdit,
      builder: (context, state) {
        // Recupera o objeto Category passado como 'extra'
        final category = state.extra as Category?;
        return CategoryCreatePage(categoryToEdit: category);
      },
    ),
//PRODUCTS
    GoRoute(
      path: AppRoutes.productByCategory,
      builder: (context, state) => const ProductCategoryListPage(),
    ),
    GoRoute(
      path: AppRoutes.productCreate,
      builder: (context, state) {
        // Ao criar um produto, a categoria é passada como 'extra'.
        final category = state.extra as Category?;
        if (category != null) {
          return ProductFormPage(category: category);
        }
        return const ErrorRoutePage(
            errorMessage: 'Erro: Categoria não encontrada.');
      },
    ),
    GoRoute(
      path: AppRoutes.productEdit,
      builder: (context, state) {
        // Ao editar, um mapa com o produto E a categoria são passados como 'extra'.
        final data = state.extra as Map<String, dynamic>?;
        if (data != null &&
            data['product'] is Product &&
            data['category'] is Category) {
          final product = data['product'] as Product;
          final category = data['category'] as Category;
          return ProductFormPage(category: category, productToEdit: product);
        }
        return const ErrorRoutePage(
            errorMessage: 'Erro: Categoria não encontrada.');
      },
    ),
    GoRoute(
        path: AppRoutes.productList,
        builder: (context, state) {
          final categoryToShow = state.extra as Category?;
          if (categoryToShow != null) {
            return ProductListPage(category: categoryToShow);
          }
          return const ErrorRoutePage(
              errorMessage: 'Erro: Categoria não encontrada.');
        }),

    //ORDER
    GoRoute(
      path: AppRoutes.orderCreate,
      builder: (context, state) => const SalesPage(),
    )
  ],
);

/// Observador para o GoRouter para logar as transições de rota.
class GoRouterObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('GoRouter didPush: ${route.settings.name}');
  }
}
