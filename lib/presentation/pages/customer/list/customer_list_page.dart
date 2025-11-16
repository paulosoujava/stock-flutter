import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/core/navigation/app_routes.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/presentation/widgets/confirmation_dialog.dart';
import 'package:stock/presentation/widgets/customer_card.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/app_module.dart';
import 'customer_list_intent.dart';
import 'customer_list_state.dart';
import 'customer_list_viewmodel.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  late final CustomerListViewModel _viewModel;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<CustomerListViewModel>();
    // Adiciona um listener para disparar a busca a cada letra digitada
    _searchController.addListener(() {
      _viewModel.handleIntent(SearchCustomerIntent(_searchController.text));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _navigateToCreateCustomer() async {
    final result = await context.push<bool>(AppRoutes.customerCreate);
    if (result == true) {
      _viewModel.handleIntent(FetchCustomersIntent());
    }
  }

  Future<void> _navigateToEditCustomer(Customer customer) async {
    final result =
        await context.push<bool>(AppRoutes.customerEdit, extra: customer);
    if (result == true) {
      _viewModel.handleIntent(FetchCustomersIntent());
    }
  }

  void _showDeleteConfirmation(Customer customer) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Exclusão',
      content:
          'Tem certeza de que deseja excluir o cliente "${customer.name}"?',
      confirmText: 'Excluir',
    );
    if (confirmed == true && mounted) {
      try {
        _viewModel.handleIntent(DeleteCustomerIntent(customer.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cliente "${customer.name}" excluído.')),
        );
        // Após deletar, busca a lista completa novamente
        _viewModel.handleIntent(FetchCustomersIntent());
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Falha ao excluir o cliente.'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar por nome ou CPF',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<CustomerListState>(
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
                  final customers =
                      state.filteredCustomers; // Usa a lista já filtrada

                  if (customers.isEmpty) {
                    return Center(
                      child: Text(
                        _searchController.text.isEmpty
                            ? 'Nenhum cliente cadastrado.'
                            : 'Nenhum cliente encontrado para "${_searchController.text}".',
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return CustomerCard(
                        customer: customer,
                        onEdit: () => _navigateToEditCustomer(customer),
                        onDelete: () => _showDeleteConfirmation(customer),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateCustomer,
        tooltip: 'Adicionar Fornecedor',
        child: const Icon(Icons.add),
      ),
    );
  }
}
