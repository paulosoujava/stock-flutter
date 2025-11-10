import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/core/navigation/app_routes.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/presentation/pages/customer/form/customer_form_page.dart';
import 'package:stock/presentation/widgets/customer_card.dart';
import 'customer_list_viewmodel.dart';
import 'customer_list_state.dart';
import 'customer_list_intent.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  late final CustomerListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<CustomerListViewModel>();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation(Customer customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza de que deseja excluir ${customer.name}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
              onPressed: () {
                _viewModel.handleIntent(DeleteCustomerIntent(customer.id));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${customer.name} foi excluído(a).')),
                );
              },
            ),
          ],
        );
      },
    );
  }


  /// Navega para a tela de CRIAÇÃO de cliente e atualiza a lista ao retornar.
  Future<void> _navigateToCreateCustomer() async {
    // 3. Usa context.push para a rota de criação
    final result = await context.push<bool>(AppRoutes.customerCreate);

    // 4. Se o formulário retornou 'true' (sucesso), recarrega a lista
    if (result == true) {
      _viewModel.handleIntent(FetchCustomersIntent());
    }
  }

  /// Navega para a tela de EDIÇÃO de cliente e atualiza a lista ao retornar.
  Future<void> _navigateToEditCustomer(Customer customer) async {
    // 5. Usa context.push para a rota de edição, passando o cliente como 'extra'
    final result = await context.push<bool>(
      AppRoutes.customerEdit,
      extra: customer,
    );

    // 6. Se o formulário retornou 'true', recarrega a lista
    if (result == true) {
      _viewModel.handleIntent(FetchCustomersIntent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            tooltip: 'Adicionar Cliente',
            onPressed: _navigateToCreateCustomer,
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder<CustomerListState>(
        stream: _viewModel.state,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is CustomerListLoadingState || !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerListErrorState) {
            return Center(child: Text(state.message));
          }

          if (state is CustomerListSuccessState) {
            if (state.customers.isEmpty) {
              return const Center(
                child: Text(
                  'Nenhum cliente cadastrado.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }
            return ListView.builder(
              itemCount: state.customers.length,
              itemBuilder: (context, index) {
                final customer = state.customers[index];
                return CustomerCard(
                  customer: customer,
                  onEdit: () => _navigateToEditCustomer(customer),
                  onDelete: () => _showDeleteConfirmation(customer),
                );
              },
            );
          }
          return const SizedBox.shrink(); // Estado inicial ou não esperado
        },
      ),
    );
  }
}
