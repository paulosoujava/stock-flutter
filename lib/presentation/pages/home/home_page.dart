import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/core/navigation/app_routes.dart';
import 'package:stock/presentation/pages/home/home_intent.dart';
import 'package:stock/presentation/pages/home/home_state.dart';
import 'package:stock/presentation/pages/home/home_view_model.dart';
import 'package:stock/presentation/pages/sales/report/sales_report_page.dart';

import 'package:stock/presentation/widgets/action_card.dart';
import 'package:stock/presentation/widgets/action_item.dart';
import 'package:stock/presentation/widgets/confirmation_dialog.dart';
import 'package:stock/presentation/widgets/low_stock_alert_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeViewModel _viewModel;

  // A lista de ações da grade é estática e pode ficar aqui.
  static const List<ActionItem> _actionItems = [
    ActionItem(
      title: 'Clientes',
      description: 'Cadastre, edite e visualize sua base de clientes.',
      icon: Icons.people_alt,
      iconColor: Colors.blue,
      route: AppRoutes.customerList,
    ),
    ActionItem(
      title: 'Categorias',
      description: 'Gerencie as categorias dos seus produtos.',
      icon: Icons.category,
      iconColor: Colors.teal,
      route: AppRoutes.categoryList,
    ),
    ActionItem(
      title: 'Produtos',
      description: 'Controle seu estoque, preços e categorias.',
      icon: Icons.inventory_2,
      iconColor: Colors.orange,
      route: AppRoutes.productByCategory,
    ),
    ActionItem(
      title: 'Vendas',
      description: 'Registre novas vendas e consulte o histórico.',
      icon: Icons.point_of_sale,
      iconColor: Colors.green,
      route: AppRoutes.orderCreate,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<HomeViewModel>();
    _viewModel.handleIntent(LoadInitialDataIntent());
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
              onPressed: () => _onLogoffPressed(context),
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            indicatorColor: Colors.white,
            indicatorWeight: 3.0,
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.white.withOpacity(0.2);
                }
                return null;
              },
            ),
            tabs: const [
              Tab(icon: Icon(Icons.touch_app), text: 'Ações'),
              Tab(icon: Icon(Icons.bar_chart), text: 'Relatórios'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Aba de Ações
            StreamBuilder<HomeState>(
              stream: _viewModel.state,
              builder: (context, snapshot) {
                final state = snapshot.data;
                return _buildActionsTab(context, state);
              },
            ),
            // 2. CORREÇÃO: Aba de Relatórios agora mostra a página de relatório
            const SalesReportPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsTab(BuildContext context, HomeState? state) {
    return Column(
      children: [
        if (state is HomeSuccessState && state.lowStockInfo.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: LowStockAlertCard(
              lowStockInfoList: state.lowStockInfo,
            ),
          ),
        if (state is HomeLoadingState)
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          ),
        if (state is HomeErrorState)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              state.errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        if (state is! HomeLoadingState)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                mainAxisExtent: 140,
              ),
              itemCount: _actionItems.length,
              itemBuilder: (context, index) {
                final item = _actionItems[index];

                VoidCallback onTapAction;

                if (item.title == 'Produtos' ||
                    item.title == 'Categorias' ||
                    item.title == 'Clientes' ||
                    item.title == 'Vendas') {
                  onTapAction = () async {
                    await context.push(item.route);
                    _viewModel.handleIntent(LoadInitialDataIntent());
                  };
                } else {
                  onTapAction = () => context.push(item.route);
                }

                return ActionCard(
                  title: item.title,
                  description: item.description,
                  icon: item.icon,
                  iconColor: item.iconColor,
                  onTap: onTapAction,
                );
              },
            ),
          ),
      ],
    );
  }

  void _onLogoffPressed(BuildContext context) async {
    final shouldLogoff = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Logoff',
      content: 'Tem certeza de que deseja sair da sua conta?',
      confirmText: 'Sair',
    );
    if (shouldLogoff == true) {
      // TODO: Implementar a lógica de logoff e navegar.
      print("Usuário confirmou o logoff.");
    }
  }
}
