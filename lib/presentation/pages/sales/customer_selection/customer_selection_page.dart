import 'package:flutter/material.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/customer/customer.dart';
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
        title: const Text('Selecionar Cliente'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
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
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(customer.name),
                  subtitle: Text(customer.phone),
                  onTap: () {
                    // Ao selecionar, retorna o cliente para a tela anterior
                    Navigator.of(context).pop(customer);
                  },
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
