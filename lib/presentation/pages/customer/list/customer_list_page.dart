import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/core/navigation/app_routes.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/presentation/widgets/confirmation_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/events/event_bus.dart';
import '../../../widgets/dialog_customer_details.dart';
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
  StreamSubscription? _customerSavedSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<CustomerListViewModel>();
    _searchController.addListener(() {
      _viewModel.handleIntent(SearchCustomerIntent(_searchController.text));
    });
    final eventBus = getIt<EventBus>();
    _customerSavedSubscription = eventBus.stream.listen((event) {
      if (event is RegisterEvent) {
        _viewModel.handleIntent(FetchCustomersIntent());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    _customerSavedSubscription?.cancel();
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

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StreamBuilder<CustomerListState>(
        stream: _viewModel.state,
        builder: (context, snapshot) {
          final currentFilter = snapshot.data is CustomerListSuccessState
              ? (snapshot.data as CustomerListSuccessState).selectedTierKeyword
              : null;

          return Container(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.filter_list,
                          size: 28, color: Colors.black87),
                      SizedBox(width: 12),
                      Text(
                        'Filtrar por nível',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildFilterOption(
                    title: 'Todos os clientes',
                    icon: Icons.people,
                    color: Colors.grey.shade600,
                    isSelected: currentFilter == null,
                    onTap: () {
                      Navigator.pop(context);
                      _viewModel.handleIntent(FilterByTierIntent(null));
                    },
                  ),
                  _buildFilterOption(
                    title: 'Ouro',
                    icon: Icons.emoji_events,
                    color: Colors.amber.shade700,
                    isSelected: currentFilter == 'ouro',
                    onTap: () {
                      Navigator.pop(context);
                      _viewModel.handleIntent(FilterByTierIntent('ouro'));
                    },
                  ),
                  _buildFilterOption(
                    title: 'Prata',
                    icon: Icons.military_tech,
                    color: Colors.blueGrey.shade600,
                    isSelected: currentFilter == 'prata',
                    onTap: () {
                      Navigator.pop(context);
                      _viewModel.handleIntent(FilterByTierIntent('prata'));
                    },
                  ),
                  _buildFilterOption(
                    title: 'Bronze',
                    icon: Icons.workspace_premium,
                    color: Colors.brown.shade600,
                    isSelected: currentFilter == 'bronze',
                    onTap: () {
                      Navigator.pop(context);
                      _viewModel.handleIntent(FilterByTierIntent('bronze'));
                    },
                  ),
                  const SizedBox(height: 14),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterOption({
    required String title,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 28),
          ],
        ),
      ),
    );
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
            child: StreamBuilder<CustomerListState>(
              stream: _viewModel.state,
              builder: (context, snapshot) {
                final state = snapshot.data;

                if (state is CustomerListLoadingState || !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is CustomerListErrorState) {
                  return Center(
                    child: Text(state.message, style: const TextStyle(color: Colors.red)),
                  );
                }
                if (state is CustomerListSuccessState) {
                  if (state.filteredCustomers.isEmpty) {
                    return _buildEmptyState(state);
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _viewModel.handleIntent(FetchCustomersIntent()),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 450,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.3,
                      ),
                      itemCount: state.filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = state.filteredCustomers[index];
                        return _CustomerCard(
                          key: ValueKey(customer.id),
                          customer: customer,
                          onEdit: () => _navigateToEditCustomer(customer),
                          onDelete: () => _showDeleteConfirmation(customer),
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
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
            tooltip: 'Voltar',
          ),
          const SizedBox(width: 16),
          Text(
            'Clientes',
            style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800]),
          ),
          const Spacer(),
          SizedBox(
            width: 300,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar por nome, CPF ou @...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                filled: true,
                contentPadding: EdgeInsets.zero,
                fillColor: Colors.grey[100],
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 16),
          StreamBuilder<CustomerListState>(
            stream: _viewModel.state,
            builder: (context, snapshot) {
              final state = snapshot.data;
              final filter = state is CustomerListSuccessState ? state.selectedTierKeyword : null;

              return Badge(
                isLabelVisible: filter != null,
                label: Text(filter ?? ''),
                child: IconButton(
                  tooltip: 'Filtrar por nível',
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterDialog,
                ),
              );
            },
          ),
          const SizedBox(width: 35),
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
            label: const Text("Novo Cliente"),
            onPressed: _navigateToCreateCustomer,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(CustomerListSuccessState state) {
    final hasSearch = _searchController.text.isNotEmpty;
    final hasFilter = state.selectedTierKeyword != null;

    String title;
    String subtitle;

    if(hasSearch || hasFilter) {
      title = 'Nenhum cliente encontrado';
      subtitle = 'Tente ajustar sua busca ou o filtro aplicado.';
    } else {
      title = 'Nenhum cliente cadastrado';
      subtitle = 'Comece adicionando seu primeiro cliente para gerenciar.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700]),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (!hasSearch && !hasFilter) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Cadastrar Primeiro Cliente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: _navigateToCreateCustomer,
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CustomerCard({
    required this.customer,
    required this.onEdit,
    required this.onDelete, required ValueKey<String> key,
  });

  void _showCustomerDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => CustomerDetailsDialog(customer: customer),
    );
  }

  Future<void> _launchWhatsApp(BuildContext context, String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse("https://wa.me/55$cleanPhone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o WhatsApp')),
      );
    }
  }

  ({Color color, IconData icon, String label}) _getTierInfo() {
    final notes = (customer.notes ?? '').toLowerCase();
    if (notes.contains('ouro')) {
      return (
      color: Colors.amber.shade700,
      icon: Icons.emoji_events,
      label: 'OURO'
      );
    }
    if (notes.contains('prata')) {
      return (
      color: Colors.blueGrey.shade400,
      icon: Icons.military_tech,
      label: 'PRATA'
      );
    }
    if (notes.contains('bronze')) {
      return (
      color: Colors.brown.shade400,
      icon: Icons.workspace_premium,
      label: 'BRONZE'
      );
    }
    return (color: Colors.grey, icon: Icons.person, label: 'PADRÃO');
  }
  String _formatPhone(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length == 11) {
      return '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2, 7)}-${digitsOnly.substring(7)}';
    }
    if (digitsOnly.length == 10) {
      return '(${digitsOnly.substring(0, 2)}) ${digitsOnly.substring(2, 6)}-${digitsOnly.substring(6)}';
    }
    return phone;
  }
  @override
  Widget build(BuildContext context) {
    final tier = _getTierInfo();
    final hasTier = tier.label != 'PADRÃO';

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: hasTier ? tier.color.withOpacity(0.5) : Colors.grey.shade200,
            width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showCustomerDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: tier.color.withOpacity(0.1),
                    child: Icon(tier.icon, color: tier.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasTier)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: tier.color,
                                borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              tier.label,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          customer.name,
                          style: GoogleFonts.poppins(
                              fontSize: 18, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildDetailRow(
                icon: Icons.phone_outlined,
                value:
                customer.phone.isEmpty ? 'Não informado' : _formatPhone(customer.phone),
              ),
              const Spacer(),
              const Divider(),
              _buildDetailRow(
                icon: Icons.email_outlined,
                value:
                customer.email.isEmpty ? 'Não informado' : customer.email,
              ),
              const Spacer(),
              const Divider(),
              if (customer.instagram?.isNotEmpty ?? false)
                _buildDetailRow(
                  icon: Icons.alternate_email,
                  value: '@${customer.instagram!}',
                ),
              const Spacer(),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (customer.whatsapp.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.message, color: Colors.green),
                      tooltip: 'WhatsApp',
                      onPressed: () => _launchWhatsApp(context, customer.whatsapp),
                    ),
                  IconButton(
                    icon:
                    const Icon(Icons.edit_outlined, color: Colors.orange),
                    tooltip: 'Editar',
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon:
                    const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Excluir',
                    onPressed: onDelete,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}