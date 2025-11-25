import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
  // --- LÓGICA ORIGINAL 100% PRESERVADA ---
  late final HomeViewModel _viewModel;
  late final StreamSubscription<HomeState> _stateSubscription;

  static const List<ActionItem> _actionItems = [
    ActionItem(
      title: 'Clientes',
      description: 'Gerencie seus clientes com rapidez e praticidade.',
      icon: Icons.people_alt,
      iconColor: Colors.blue,
      route: AppRoutes.customerList,
    ),
    ActionItem(
      title: 'Categorias',
      description: 'Organize seus produtos por categorias.',
      icon: Icons.category,
      iconColor: Colors.teal,
      route: AppRoutes.categoryList,
    ),
    ActionItem(
      title: 'Produtos',
      description: 'Controle estoque, preços e disponibilidade.',
      icon: Icons.inventory_2,
      iconColor: Colors.orange,
      route: AppRoutes.productByCategory,
    ),
    ActionItem(
      title: 'Vendas',
      description: 'Registre e acompanhe transações.',
      icon: Icons.point_of_sale,
      iconColor: Colors.green,
      route: AppRoutes.orderCreate,
    ),
    ActionItem(
      title: 'Fornecedores',
      description: 'Gerencie parceiros e contatos.',
      icon: Icons.business_center,
      iconColor: Colors.deepOrange,
      route: AppRoutes.supplierList,
    ),
    ActionItem(
      title: 'Lembretes',
      description: 'Crie anotações importantes.',
      icon: Icons.note_alt,
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
  // --- FIM DA LÓGICA ORIGINAL ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[100], // Fundo mais suave
        appBar: AppBar(
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey[800],
          title: Text(
            'Dashboard',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () => HelpDialog.show(context),
              tooltip: 'Ajuda',
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _onLogoffPressed(context),
              tooltip: 'Sair',
            ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            labelColor: theme.primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: theme.primaryColor, width: 3),
              insets: const EdgeInsets.symmetric(horizontal: 16.0),
            ),
            tabs: const [
              Tab(child: _TabItem(title: "Ações", icon: Icons.dashboard_customize)),
              Tab(child: _TabItem(title: "Relatórios", icon: Icons.bar_chart)),
              Tab(child: _TabItem(title: "Lives", icon: Icons.live_tv)),
            ],
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
            const LiveListScreen(),
          ],
        ),
      ),
    );
  }

  // ABA DE AÇÕES REDESENHADA
  Widget _buildActionsTab(BuildContext context, HomeState? state) {
    final String formattedDate = DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(DateTime.now());

    return CustomScrollView(
      slivers: [
        // Cabeçalho de Boas-Vindas
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo(a)!',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  formattedDate[0].toUpperCase() + formattedDate.substring(1),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Alerta de Estoque Baixo
        if (state is HomeSuccessState && state.lowStockInfo.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: LowStockAlertCard(lowStockInfoList: state.lowStockInfo),
            ),
          ),

        if (state is HomeErrorState)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                state.errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),

        // Grid de Ações Responsivo
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 380, // Largura máxima do card
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 1.6, // Proporção ajustada
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final item = _actionItems[index];
                Future<void> onTapAction() async {
                  // Lógica original preservada
                  if (item.title == 'Produtos' ||
                      item.title == 'Categorias' ||
                      item.title == 'Clientes' ||
                      item.title == 'Vendas') {
                    await context.push(item.route);
                    _viewModel.handleIntent(LoadInitialDataIntent());
                  } else {
                    context.push(item.route);
                  }
                }

                return ActionCard(
                  title: item.title,
                  description: item.description,
                  icon: item.icon,
                  iconColor: item.iconColor,
                  onTap: onTapAction,
                );
              },
              childCount: _actionItems.length,
            ),
          ),
        ),

        // Rodapé com Versão
        SliverFillRemaining(
          hasScrollBody: false,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "Versão 1.0.0",
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Widget auxiliar para os itens da TabBar
class _TabItem extends StatelessWidget {
  final String title;
  final IconData icon;

  const _TabItem({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
    );
  }
}
