import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/core/navigation/app_routes.dart';
import 'package:stock/domain/entities/supplier/supplier.dart';
import 'package:stock/presentation/pages/supplier/list/supplier_list_intent.dart';
import 'package:stock/presentation/pages/supplier/list/supplier_list_state.dart';
import 'package:stock/presentation/pages/supplier/list/supplier_list_viewmodel.dart';
import 'package:stock/presentation/widgets/confirmation_dialog.dart';

class SupplierListPage extends StatefulWidget {
  const SupplierListPage({super.key});

  @override
  State<SupplierListPage> createState() => _SupplierListPageState();
}

class _SupplierListPageState extends State<SupplierListPage> {
  late final SupplierListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<SupplierListViewModel>();
  }

  void _navigateToCreateForm() async {
    final bool? result = await context.push<bool>(AppRoutes.supplierCreate);
    if (result == true) {
      _viewModel.handleIntent(LoadSuppliersIntent());
    }
  }

  void _navigateToEditForm(Supplier supplier) async {
    final bool? result = await context.push<bool>(
      AppRoutes.supplierCreate, // Reutiliza a mesma rota/tela do formulário
      extra: supplier,
    );
    if (result == true) {
      _viewModel.handleIntent(LoadSuppliersIntent());
    }
  }

  void _showDeleteConfirmation(Supplier supplier) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Exclusão',
      content: 'Tem certeza que deseja excluir o fornecedor "${supplier.name}"?',
      confirmText: 'Excluir',
    );
    if (confirmed == true) {
      _viewModel.handleIntent(DeleteSupplierIntent(supplier.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fornecedores'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Pesquisar por nome, telefone ou e-mail...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
              ),
              onChanged: (query) =>
                  _viewModel.handleIntent(SearchSuppliersIntent(query)),
            ),
          ),
        ),
      ),
      body: StreamBuilder<SupplierListState>(
        stream: _viewModel.state,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is SupplierListLoading || !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SupplierListError) {
            return Center(child: Text(state.message));
          }
          if (state is SupplierListLoaded) {
            if (state.suppliers.isEmpty) {
              return const Center(child: Text('Nenhum fornecedor cadastrado.'));
            }
            return ListView.builder(
              itemCount: state.suppliers.length,
              itemBuilder: (context, index) {
                final supplier = state.suppliers[index];
                return _SupplierCard(
                  supplier: supplier,
                  onEdit: () => _navigateToEditForm(supplier),
                  onDelete: () => _showDeleteConfirmation(supplier),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateForm,
        tooltip: 'Adicionar Fornecedor',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Widget privado para o Card do Fornecedor
class _SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SupplierCard({
    required this.supplier,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.business, size: 40, color: Colors.grey),
        title: Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(supplier.phone),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_note, color: Colors.blue),
              tooltip: 'Editar',
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Excluir',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
