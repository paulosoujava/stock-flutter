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


  // A lista de ações da grade é estática e pode ficar aqui.
  static const List<ActionItem> _actionItems = [
    ActionItem(
      title: 'Clientes',
      description:
      'Cadastre, edite e visualize seus clientes de forma rápida e prática, mantendo sua base sempre organizada e atualizada.',
      icon: Icons.people_alt,
      iconColor: Colors.blue,
      route: AppRoutes.customerList,
    ),
    ActionItem(
      title: 'Categorias',
      description:
      'Gerencie as categorias de seus produtos, organize seu estoque e facilite a navegação e busca de itens no seu sistema.',
      icon: Icons.category,
      iconColor: Colors.teal,
      route: AppRoutes.categoryList,
    ),
    ActionItem(
      title: 'Produtos',
      description:
      'Controle seu estoque, preços e categorias de produtos, garantindo um gerenciamento eficiente e preciso de suas mercadorias.',
      icon: Icons.inventory_2,
      iconColor: Colors.orange,
      route: AppRoutes.productByCategory,
    ),
    ActionItem(
      title: 'Vendas',
      description:
      'Registre novas vendas, consulte o histórico de transações e mantenha o controle total das operações comerciais.',
      icon: Icons.point_of_sale,
      iconColor: Colors.green,
      route: AppRoutes.orderCreate,
    ),
    ActionItem(
      title: 'Fornecedores',
      description:
      'Cadastre e gerencie seus fornecedores, mantendo suas informações sempre organizadas para otimizar o processo de compra.',
      icon: Icons.recent_actors_outlined,
      iconColor: Colors.deepOrange,
      route: AppRoutes.supplierList,
    ),
    ActionItem(
      title: 'Lembretes',
      description:
      'Crie lembretes para não esquecer de tarefas importantes, como prazos e compromissos, e se mantenha organizado.',
      icon: Icons.today_outlined,
      iconColor: Colors.purple,
      route: AppRoutes.reminderList,
    ),

    /*ActionItem(
      title: 'Vendas em Live',
      description: 'Gerencie e conduza suas vendas ao vivo.',
      icon: Icons.live_tv,
      iconColor: Colors.redAccent,
      route: AppRoutes.liveList, // Use a rota que definimos
    ),*/
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              tooltip: 'Ajuda',
              onPressed: () => HelpDialog.show(context),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
              onPressed: () => _onLogoffPressed(context),
            ),
            SizedBox(width: 8),
          ],
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withAlpha(130),
            indicatorColor: Colors.green,
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
              Tab(icon: Icon(Icons.live_tv), text: 'Lives')
            ],
          ),
        ),
        body: TabBarView(
          children: [
            /**********************************************************************
            //HOME
            **********************************************************************/
            StreamBuilder<HomeState>(
              stream: _viewModel.state,
              builder: (context, snapshot) {
                final state = snapshot.data;
                return _buildActionsTab(context, state);
              },
            ),
            /**********************************************************************
            //REPORT
            **********************************************************************/
            const SalesReportPage(),
            /**********************************************************************
            //LIVE
            **********************************************************************/
            LiveListScreen()
          ],
        ),
      ),
    );
  }

  Widget _buildActionsTab(BuildContext context, HomeState? state) {
    return Column(
      children: [
        // 🔔 Header: alertas e erros fora do scroll
        if (state is HomeSuccessState && state.lowStockInfo.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: LowStockAlertCard(
              lowStockInfoList: state.lowStockInfo,
            ),
          ),

        if (state is HomeErrorState)
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Text(
              state.errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),

        // 🔄 Carregando (ocupa tudo exceto o footer)
        if (state is HomeLoadingState)
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          )
        else
        // 🟦 Conteúdo principal scrollável
          Expanded(
            child: SingleChildScrollView(
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
          ),

        // 📌 FOOTER FIXO
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            "Versão 1.0.0",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
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
      _viewModel.handleIntent(SignOutIntent());
    }
  }
}
