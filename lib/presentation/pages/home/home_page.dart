import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/core/navigation/app_routes.dart';
import 'package:stock/presentation/pages/home/home_intent.dart';
import 'package:stock/presentation/pages/home/home_state.dart';
import 'package:stock/presentation/pages/home/home_view_model.dart';
import 'package:stock/presentation/pages/live/list/live_list_screen.dart.dart';
import 'package:stock/presentation/pages/sales/report/sales_report_page.dart';
import 'package:stock/presentation/widgets/action_card.dart';
import 'package:stock/presentation/widgets/action_item.dart';
import 'package:stock/presentation/widgets/confirmation_dialog.dart';
import 'package:stock/presentation/widgets/help_dialog.dart';
import 'package:stock/presentation/widgets/low_stock_alert_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeViewModel _viewModel;
  late final StreamSubscription<HomeState> _stateSubscription;

  static const List<ActionItem> _actionItems = [
    ActionItem(
      title: 'Clientes',
      description:
      'Gerencie seus clientes com rapidez e praticidade.',
      icon: Icons.people_alt,
      iconColor: Colors.blue,
      route: AppRoutes.customerList,
    ),
    ActionItem(
      title: 'Categorias',
      description:
      'Organize seus produtos por categorias.',
      icon: Icons.category,
      iconColor: Colors.teal,
      route: AppRoutes.categoryList,
    ),
    ActionItem(
      title: 'Produtos',
      description:
      'Controle estoque, preços e disponibilidade.',
      icon: Icons.inventory_2,
      iconColor: Colors.orange,
      route: AppRoutes.productByCategory,
    ),
    ActionItem(
      title: 'Vendas',
      description:
      'Registre e acompanhe transações.',
      icon: Icons.point_of_sale,
      iconColor: Colors.green,
      route: AppRoutes.orderCreate,
    ),
    ActionItem(
      title: 'Fornecedores',
      description:
      'Gerencie parceiros e contatos.',
      icon: Icons.recent_actors_outlined,
      iconColor: Colors.deepOrange,
      route: AppRoutes.supplierList,
    ),
    ActionItem(
      title: 'Lembretes',
      description:
      'Crie anotações importantes.',
      icon: Icons.today_outlined,
      iconColor: Colors.purple,
      route: AppRoutes.reminderList,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<HomeViewModel>();
    _listenToStateChanges();
    _viewModel.handleIntent(LoadInitialDataIntent());
  }

  void _listenToStateChanges() {
    _stateSubscription = _viewModel.state.listen((state) {
      if (!mounted) return;

      if (state is HomeLogoutSuccessState) {
        context.go(AppRoutes.login);
      } else if (state is HomeErrorState) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _stateSubscription.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: theme.colorScheme.primary,
          title: const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () => HelpDialog.show(context),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _onLogoffPressed(context),
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(55),
            child: Container(
              color: theme.colorScheme.primary,
              child: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: "Ações", icon: Icon(Icons.dashboard_customize)),
                  Tab(text: "Relatórios", icon: Icon(Icons.bar_chart)),
                  Tab(text: "Lives", icon: Icon(Icons.live_tv)),
                ],
              ),
            ),
          ),
        ),

        body: TabBarView(
          children: [
            StreamBuilder<HomeState>(
              stream: _viewModel.state,
              builder: (context, snapshot) {
                final state = snapshot.data;
                return _buildActionsTab(context, state);
              },
            ),
            const SalesReportPage(),
            LiveListScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsTab(BuildContext context, HomeState? state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 6),
          child: const Text(
            "Olá, seja bem-vindo 👋",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(22, 0, 22, 16),
          child: Text(
            "O que você deseja fazer hoje?",
            style: TextStyle(
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
        ),

        if (state is HomeSuccessState && state.lowStockInfo.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LowStockAlertCard(
              lowStockInfoList: state.lowStockInfo,
            ),
          ),

        if (state is HomeErrorState)
          Padding(
            padding: const EdgeInsets.all(6),
            child: Text(
              state.errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),

        const SizedBox(height: 10),

        Expanded(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 22,
                  mainAxisSpacing: 22,
                  mainAxisExtent: 180,
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
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                "Versão 1.0.0",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _onLogoffPressed(BuildContext context) async {
    final shouldLogoff = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Logoff',
      content: 'Deseja realmente sair?',
      confirmText: 'Sair',
    );
    if (shouldLogoff == true) {
      _viewModel.handleIntent(SignOutIntent());
    }
  }
}
