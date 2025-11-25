// lib/presentation/pages/supplier/list/supplier_list_page.dart
import 'package:flutter/material.dart';import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
  // --- LÓGICA ORIGINAL PRESERVADA ---
  late final SupplierListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<SupplierListViewModel>();
    // A inicialização do viewModel agora é feita no builder, se necessário,
    // ou pode ser mantida aqui, dependendo da necessidade de carregar os dados
    // na primeira construção do widget. Mantendo como no original.
    _viewModel.handleIntent(LoadSuppliersIntent());
  }

  void _navigateToCreateForm() async {
    final bool? result = await context.push<bool>(AppRoutes.supplierCreate);
    if (result == true) {
      _viewModel.handleIntent(LoadSuppliersIntent());
    }
  }

  void _navigateToEditForm(Supplier supplier) async {
    final bool? result = await context.push<bool>(
      AppRoutes.supplierCreate,
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
      content:
      'Tem certeza que deseja excluir o fornecedor "${supplier.name}"?',
      confirmText: 'Excluir',
    );
    if (confirmed == true) {
      _viewModel.handleIntent(DeleteSupplierIntent(supplier.id));
    }
  }
  // --- FIM DA LÓGICA ORIGINAL ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder<SupplierListState>(
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
                    return _buildEmptyState();
                  }
                  // Usando GridView como solicitado
                  return RefreshIndicator(
                    onRefresh: () async => _viewModel.handleIntent(LoadSuppliersIntent()),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400, // Largura máxima de cada card
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.8, // Proporção para o conteúdo do card
                      ),
                      itemCount: state.suppliers.length,
                      itemBuilder: (context, index) {
                        final supplier = state.suppliers[index];
                        return _SupplierCard(
                          supplier: supplier,
                          onEdit: () => _navigateToEditForm(supplier),
                          onDelete: () => _showDeleteConfirmation(supplier),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  // Novo Header para um visual mais limpo
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // BOTÃO DE VOLTAR ADICIONADO AQUI
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
            tooltip: 'Voltar',
          ),
          const SizedBox(width: 16),
          Text(
            'Fornecedores',
            style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800]),
          ),
          const Spacer(),
          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                filled: true,
                contentPadding: EdgeInsets.zero,
                fillColor: Colors.grey[100],
              ),
              onChanged: (query) =>
                  _viewModel.handleIntent(SearchSuppliersIntent(query)),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            icon: const Icon(Icons.add, size: 20),
            label: const Text("Novo Fornecedor"),
            onPressed: _navigateToCreateForm,
          ),
        ],
      ),
    );
  }

  // Widget de estado vazio, levemente reestilizado
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_center_outlined,
                size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text('Nenhum fornecedor cadastrado',
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700]),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Mantenha os contatos dos fornecedores, adicionando-os agora.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar Primeiro Fornecedor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: _navigateToCreateForm,
            ),
          ],
        ),
      ),
    );
  }
}

// Card redesenhado para GridView, sem ExpansionTile
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
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEdit, // O card inteiro é clicável para editar
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com nome, ícone e botão de excluir
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                      backgroundColor: Colors.deepPurple.withOpacity(0.1),
                      child: Icon(Icons.business_center_outlined,
                          color: Colors.deepPurple)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      supplier.name,
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red, size: 22),
                      tooltip: 'Excluir',
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints()),
                ],
              ),
              const Spacer(),
              // Detalhes de contato
              _buildDetailRow(
                icon: Icons.phone_outlined,
                value: supplier.phone.isEmpty ? 'Não informado' : supplier.phone,
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                icon: Icons.email_outlined,
                value: supplier.email.isEmpty ? 'Não informado' : supplier.email,
              ),
              const SizedBox(height: 8),
              // Indicador de observação
              if (supplier.observation.isNotEmpty)
                _buildDetailRow(
                  icon: Icons.notes_outlined,
                  value: supplier.observation,
                  isNote: true,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para criar as linhas de detalhe no novo card
  Widget _buildDetailRow({required IconData icon, required String value, bool isNote = false}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isNote ? Colors.blueGrey : Colors.grey[700],
              fontStyle: isNote ? FontStyle.italic : FontStyle.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
