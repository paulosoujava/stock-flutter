import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/core/navigation/app_routes.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/presentation/widgets/confirmation_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../widgets/dialog_customer_details.dart';
import 'customer_list_intent.dart';
import 'customer_list_state.dart';
import 'customer_list_viewmodel.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage>
    with TickerProviderStateMixin {
  late final CustomerListViewModel _viewModel;
  final _searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _viewModel = getIt<CustomerListViewModel>();

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
      title: 'Excluir Cliente',
      content: 'Tem certeza que deseja excluir "${customer.name}"?',
      confirmText: 'Excluir',
    );
    if (confirmed == true && mounted) {
      try {
        _viewModel.handleIntent(DeleteCustomerIntent(customer.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cliente "${customer.name}" excluído.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: const StadiumBorder(),
          ),
        );
        _viewModel.handleIntent(FetchCustomersIntent());
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Falha ao excluir o cliente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
          title: const Text(
            'Clientes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Pesquisar por nome, CPF ou telefone...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _viewModel.handleIntent(SearchCustomerIntent(''));
                    },
                  )
                      : null,
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Cadastrar cliente',
                onPressed: () {
                  _navigateToCreateCustomer();
                }),
            SizedBox(
              width: 20,
            )
          ]),
      body: StreamBuilder<CustomerListState>(
        stream: _viewModel.state,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is CustomerListLoadingState || !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CustomerListErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text(state.message,
                      style: const TextStyle(color: Colors.black54)),
                ],
              ),
            );
          }
          if (state is CustomerListSuccessState) {
            final customers = state.filteredCustomers;

            if (customers.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final customer = customers[index];
                return _CustomerCard(
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone mais sutil com opacidade
            Opacity(
              opacity: 0.5,
              child: Icon(
                Icons.people_alt_outlined,
                size: 90,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),

            // Título principal
            const Text(
              'Nenhum cliente',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),

            // Subtítulo contextual
            Text(
              _searchController.text.isEmpty
                  ? 'Cadastre seu primeiro cliente para começar.'
                  : 'Nenhum cliente encontrado para "${_searchController.text}".',
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // --- Botão de Ação ---
            ElevatedButton.icon(
              onPressed: _navigateToCreateCustomer,
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar Novo Cliente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
// CUSTOMER CARD MODIFICADO
// ===================================================================

enum CustomerTier { none, bronze, silver, gold }

class _CustomerCard extends StatefulWidget {
  final Customer customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CustomerCard({
    required this.customer,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_CustomerCard> createState() => _CustomerCardState();
}

class _CustomerCardState extends State<_CustomerCard>{

  @override
  void dispose() {
    super.dispose();
  }

  void _showCustomerDetails() {
    showDialog(
      context: context,
      builder: (dialogContext) =>
          CustomerDetailsDialog(customer: widget.customer),
    );
  }

  Future<void> _launchWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse("https://wa.me/55$cleanPhone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o WhatsApp')),
        );
      }
    }
  }

  // --- FUNÇÕES DE ESTILO ---
  CustomerTier _getTier(String? notes) {
    final lowerCaseNotes = notes?.toLowerCase() ?? '';
    if (lowerCaseNotes.contains('ouro')) return CustomerTier.gold;
    if (lowerCaseNotes.contains('prata')) return CustomerTier.silver;
    if (lowerCaseNotes.contains('bronze')) return CustomerTier.bronze;
    return CustomerTier.none;
  }

  Color _getBorderColor(CustomerTier tier) {
    switch (tier) {
      case CustomerTier.gold:
        return Colors.amber.shade600;
      case CustomerTier.silver:
        return Colors.blueGrey.shade400;
      case CustomerTier.bronze:
        return Colors.brown.shade400;
      default:
        return Colors.transparent; // Sem borda para o padrão
    }
  }

  Color _getBackgroundColor(CustomerTier tier) {
    switch (tier) {
      case CustomerTier.gold:
        return Colors.amber.shade50;
      case CustomerTier.silver:
        return Colors.blueGrey.shade50;
      case CustomerTier.bronze:
        return const Color(0xFFEFEBE9); // Um tom de marrom claro
      default:
        return Colors.white; // Fundo padrão do Card
    }
  }


  IconData _getTierIcon(CustomerTier tier) {
    switch (tier) {
      case CustomerTier.gold:
        return Icons.emoji_events;
      case CustomerTier.silver:
        return Icons.military_tech;
      case CustomerTier.bronze:
        return Icons.workspace_premium;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tier = _getTier(widget.customer.notes);
    final borderColor = _getBorderColor(tier);
    final backgroundColor = _getBackgroundColor(tier);
    final tierIcon = _getTierIcon(tier);

    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // Adiciona a borda colorida
        side: BorderSide(color: borderColor, width: tier == CustomerTier.none ? 0 : 2),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _showCustomerDetails,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: borderColor != Colors.transparent ? borderColor.withOpacity(0.2) : theme.primaryColor.withOpacity(0.1),
                child: tier != CustomerTier.none
                    ? Icon(tierIcon, color: borderColor, size: 28)
                    : Text(
                  widget.customer.name.isNotEmpty
                      ? widget.customer.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.customer.name.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    /*if (widget.customer.phone.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.phone,
                              size: 14, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(widget.customer.phone,
                              style: const TextStyle(fontSize: 13)),
                        ],
                      ),*/
                    if (widget.customer.instagram?.isNotEmpty == true)
                      Text('@${widget.customer.instagram}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              // === TODOS OS BOTÕES VISÍVEIS NO CARD ===
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // WhatsApp
                  if (widget.customer.whatsapp.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.message, color: Colors.green),
                      tooltip: 'WhatsApp',
                      onPressed: () =>
                          _launchWhatsApp(widget.customer.whatsapp),
                    ),

                  // Editar
                  IconButton(
                    icon:
                    const Icon(Icons.edit_outlined, color: Colors.orange),
                    tooltip: 'Editar',
                    onPressed: widget.onEdit,
                  ),
                  // Excluir
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Excluir',
                    onPressed: widget.onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
