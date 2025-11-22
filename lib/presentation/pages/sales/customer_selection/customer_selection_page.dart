import 'package:flutter/material.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import '../../../../core/di/app_module.dart';
import 'customer_selection_intent.dart';
import 'customer_selection_state.dart';
import 'customer_selection_view_model.dart';

class CustomerSelectionPage extends StatefulWidget {
  const CustomerSelectionPage({super.key});

  @override
  State<CustomerSelectionPage> createState() => _CustomerSelectionPageState();
}

class _CustomerSelectionPageState extends State<CustomerSelectionPage> {
  late final CustomerSelectionViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<CustomerSelectionViewModel>()
      ..handleIntent(LoadAllCustomersIntent());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Pesquisar por nome ou telefone...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (query) {
                _viewModel.handleIntent(FilterCustomersIntent(query));
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder<CustomerSelectionState>(
        stream: _viewModel.state,
        builder: (context, snapshot) {
          final state = snapshot.data;
          if (state is CustomerSelectionLoading || !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CustomerSelectionError) {
            return Center(child: Text(state.message));
          }
          if (state is CustomerSelectionLoaded) {
            if (state.filteredCustomers.isEmpty) {
              return const Center(child: Text('Nenhum cliente encontrado.'));
            }
            return ListView.builder(
              itemCount: state.filteredCustomers.length,
              itemBuilder: (context, index) {
                final customer = state.filteredCustomers[index];
                return _buildCustomerTile(context, customer);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }


  Widget _buildCustomerTile(BuildContext context, Customer customer) {
    final theme = Theme.of(context);
    final hasPhone = customer.phone.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Ação de selecionar o cliente
          Navigator.of(context).pop(customer);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar com a inicial do nome
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                child: Text(
                  customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Nome e telefone
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (hasPhone) ...[
                      const SizedBox(height: 4),
                      Text(
                        customer.phone,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ],
                ),
              ),
              // Ícone indicando que é um item selecionável
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }

}
