import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/navigation/app_router.dart';
import 'package:stock/core/navigation/app_routes.dart';
import 'package:stock/presentation/widgets/action_card.dart';
import 'package:stock/presentation/widgets/confirmation_dialog.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Função para tratar o clique no botão de logoff
  void _onLogoffPressed(BuildContext context) async {
    final shouldLogoff = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Logoff',
      content: 'Tem certeza de que deseja sair da sua conta?',
      confirmText: 'Sair',
    );
    if (shouldLogoff == true) {
      // TODO: Implementar a lógica de logoff (limpar token, etc.)
      // e navegar para a tela de login.
      print("Usuário confirmou o logoff.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Exemplo com 2 abas: "Ações" e "Relatórios"
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
            // Cor do ícone e do texto da aba ATIVA.
            labelColor: Colors.white,
            // Cor do ícone e do texto das abas INATIVAS.
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            // Cor e espessura da linha indicadora que fica embaixo da aba ativa.
            indicatorColor: Colors.white,
            indicatorWeight: 3.0,
            // Opcional: para garantir que o efeito "splash" ao tocar na aba seja visível.
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.white.withOpacity(0.2);
                }
                return null; // Defer to the default splash color
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
            // Conteúdo da primeira aba: "Ações"
            _buildActionsTab(context),
            // Conteúdo da segunda aba: "Relatórios" (placeholder)
            const Center(
              child: Text(
                'Área de Relatórios em construção',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget que constrói o conteúdo da aba "Ações"
  Widget _buildActionsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gerenciamento',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ActionCard(
            title: 'Clientes',
            description: 'Cadastre, edite e visualize sua base de clientes.',
            icon: Icons.people_alt,
            iconColor: Colors.blue.shade700,
            onTap: () {
              // Navegação usando GoRouter para a tela de lista de clientes
              context.push(AppRoutes.customerList);
            },
          ),
          ActionCard(
            title: 'Categorias',
            description: 'Gerencie as categorias dos seus produtos.',
            icon: Icons.category,
            iconColor: Colors.teal.shade700,
            onTap: () {
              // Navegação usando GoRouter para a tela de lista de categorias
              context.push(AppRoutes.categoryList);
            },
          ),
          ActionCard(
            title: 'Produtos',
            description: 'Controle seu estoque, preços e categorias.',
            icon: Icons.inventory_2,
            iconColor: Colors.orange.shade800,
            onTap: () {
              // TODO: Navegar para a tela de lista de produtos
              print("Navegar para Produtos");
            },
          ),
          ActionCard(
            title: 'Vendas',
            description: 'Registre novas vendas e consulte o histórico.',
            icon: Icons.point_of_sale,
            iconColor: Colors.green.shade700,
            onTap: () {
              // TODO: Navegar para a tela de vendas
              print("Navegar para Vendas");
            },
          ),
        ],
      ),
    );
  }
}
