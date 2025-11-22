import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/core/navigation/app_routes.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/presentation/pages/customer/form/customer_form_intent.dart';
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

class _CustomerListPageState extends State<CustomerListPage>
    with TickerProviderStateMixin {
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
    super.dispose();
  }

  Future<void> _navigateToCreateCustomer() async {
    final result = await context.push<bool>(AppRoutes.customerCreate);
    if (result == true) {
      _viewModel.handleIntent( FetchCustomersIntent());
    }
  }

  Future<void> _navigateToEditCustomer(Customer customer) async {
    final result = await context.push<bool>(AppRoutes.customerEdit, extra: customer);
    if (result == true) {
      _viewModel.handleIntent( FetchCustomersIntent());
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
        _viewModel.handleIntent( FetchCustomersIntent());
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.filter_list, size: 28, color: Colors.black87),
                    SizedBox(width: 12),
                    Text(
                      'Filtrar por nível',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    _viewModel.handleIntent( FilterByTierIntent(null));
                  },
                ),
                _buildFilterOption(
                  title: 'Ouro',
                  icon: Icons.emoji_events,
                  color: Colors.amber.shade700,
                  isSelected: currentFilter == 'ouro',
                  onTap: () {
                    Navigator.pop(context);
                    _viewModel.handleIntent( FilterByTierIntent('ouro'));
                  },
                ),
                _buildFilterOption(
                  title: 'Prata',
                  icon: Icons.military_tech,
                  color: Colors.blueGrey.shade600,
                  isSelected: currentFilter == 'prata',
                  onTap: () {
                    Navigator.pop(context);
                    _viewModel.handleIntent( FilterByTierIntent('prata'));
                  },
                ),
                _buildFilterOption(
                  title: 'Bronze',
                  icon: Icons.workspace_premium,
                  color: Colors.brown.shade600,
                  isSelected: currentFilter == 'bronze',
                  onTap: () {
                    Navigator.pop(context);
                    _viewModel.handleIntent( FilterByTierIntent('bronze'));
                  },
                ),
                const SizedBox(height: 24),
              ],
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
        actions: [
          // ÍCONE DE FILTRO COM BADGE DINÂMICO (AGORA FUNCIONA!)
          StreamBuilder<CustomerListState>(
            stream: _viewModel.state,
            builder: (context, snapshot) {
              final hasActiveFilter = snapshot.hasData &&
                  snapshot.data is CustomerListSuccessState &&
                  (snapshot.data as CustomerListSuccessState).selectedTierKeyword != null;

              return IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.tune, size: 28),
                    if (hasActiveFilter)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                tooltip: 'Filtrar por nível',
                onPressed: _showFilterDialog,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Cadastrar cliente',
            onPressed: _navigateToCreateCustomer,
          ),
          const SizedBox(width: 12),
        ],
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
                    _viewModel.handleIntent( SearchCustomerIntent(''));
                  },
                )
                    : null,
              ),
            ),
          ),
        ),
      ),
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
                  Text(state.message, style: const TextStyle(color: Colors.black54)),
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
            Opacity(
              opacity: 0.5,
              child: Icon(
                Icons.people_alt_outlined,
                size: 90,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhum cliente',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Text(
              _searchController.text.isEmpty && _viewModel.currentTierFilter == null
                  ? 'Cadastre seu primeiro cliente para começar.'
                  : 'Nenhum cliente encontrado com os filtros aplicados.',
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToCreateCustomer,
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar Novo Cliente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
// CUSTOMER CARD (igual ao anterior, mantido 100%)
// ===================================================================

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

class _CustomerCardState extends State<_CustomerCard> {
  void _showCustomerDetails() {
    showDialog(
      context: context,
      builder: (dialogContext) => CustomerDetailsDialog(customer: widget.customer),
    );
  }

  Future<void> _launchWhatsApp(String phone) async {
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

  bool _isGold(String? notes) => (notes ?? '').toLowerCase().contains('ouro');
  bool _isSilver(String? notes) => (notes ?? '').toLowerCase().contains('prata');
  bool _isBronze(String? notes) => (notes ?? '').toLowerCase().contains('bronze');

  Color _getBorderColor() {
    if (_isGold(widget.customer.notes)) return Colors.amber.shade600;
    if (_isSilver(widget.customer.notes)) return Colors.blueGrey.shade400;
    if (_isBronze(widget.customer.notes)) return Colors.brown.shade400;
    return Colors.transparent;
  }

  Color _getBackgroundColor() {
    if (_isGold(widget.customer.notes)) return Colors.amber.shade50;
    if (_isSilver(widget.customer.notes)) return Colors.blueGrey.shade50;
    if (_isBronze(widget.customer.notes)) return const Color(0xFFEFEBE9);
    return Colors.white;
  }

  IconData _getTierIcon() {
    if (_isGold(widget.customer.notes)) return Icons.emoji_events;
    if (_isSilver(widget.customer.notes)) return Icons.military_tech;
    if (_isBronze(widget.customer.notes)) return Icons.workspace_premium;
    return Icons.person;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = _getBorderColor();
    final backgroundColor = _getBackgroundColor();
    final tierIcon = _getTierIcon();
    final hasTier = borderColor != Colors.transparent;

    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: hasTier ? 2 : 0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _showCustomerDetails,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: hasTier
                    ? borderColor.withOpacity(0.2)
                    : theme.primaryColor.withOpacity(0.1),
                child: hasTier
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
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    if (widget.customer.instagram?.isNotEmpty == true)
                      Text(
                        '@${widget.customer.instagram}',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.customer.whatsapp.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.message, color: Colors.green),
                      tooltip: 'WhatsApp',
                      onPressed: () => _launchWhatsApp(widget.customer.whatsapp),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.orange),
                    tooltip: 'Editar',
                    onPressed: widget.onEdit,
                  ),
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