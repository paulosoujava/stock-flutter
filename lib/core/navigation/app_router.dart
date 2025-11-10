import 'package:go_router/go_router.dart';
import 'package:stock/core/navigation/app_routes.dart';
import 'package:stock/domain/entities/category/category.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/presentation/pages/categories/form/category_form_page.dart';
import 'package:stock/presentation/pages/categories/list/category_list_page.dart';
import 'package:stock/presentation/pages/customer/form/customer_form_page.dart';

import 'package:stock/presentation/pages/customer/list/customer_list_page.dart';
import 'package:stock/presentation/pages/home/home_page.dart';



final appRouter = GoRouter(

  initialLocation: AppRoutes.home,

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
  ],
);
