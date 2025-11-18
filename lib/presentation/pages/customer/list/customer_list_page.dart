import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/core/navigation/app_routes.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/presentation/widgets/confirmation_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/app_module.dart';
import '../../../widgets/url_launcher_utils.dart';
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
                return _AnimatedCustomerCard(
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_alt_outlined, size: 90, color: Colors.grey[400]),
          const SizedBox(height: 24),
          const Text(
            'Nenhum cliente cadastrado',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? 'Toque no botão para adicionar'
                : 'Nenhum cliente encontrado para "${_searchController.text}"',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// === CARD COM TODOS OS BOTÕES + CLIQUE PARA DETALHES ===
class _AnimatedCustomerCard extends StatefulWidget {
  final Customer customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AnimatedCustomerCard({
    required this.customer,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_AnimatedCustomerCard> createState() => __AnimatedCustomerCardState();
}

class __AnimatedCustomerCardState extends State<_AnimatedCustomerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.ease));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showCustomerDetails() {
    showDialog(
      context: context,
      builder: (dialogContext) =>
          _CustomerDetailsDialog(customer: widget.customer),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScaleTransition(
      scale: _scale,
      child: Card(
        elevation: 4,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _controller.forward().then((_) => _controller.reverse());
            _showCustomerDetails(); // CLIQUE ABRE DETALHES
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  child: Text(
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
                        widget.customer.name,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      if (widget.customer.phone.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.phone,
                                size: 14, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(widget.customer.phone,
                                style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      if (widget.customer.cpf.isNotEmpty)
                        Text('CPF: ${widget.customer.cpf}',
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
      ),
    );
  }
}

// === DIÁLOGO DE DETALHES (COMPLETO) ===
class _CustomerDetailsDialog extends StatelessWidget {
  final Customer customer;

  const _CustomerDetailsDialog({required this.customer});

  Future<void> _launchWhatsApp(BuildContext context, String phone) async {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  child: Text(
                    customer.name.isNotEmpty
                        ? customer.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if (customer.cpf.isNotEmpty)
                        Text('CPF: ${customer.cpf}',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _infoRow('Telefone', customer.phone, Icons.phone,
                color: Colors.green),
            _infoRow(
              'WhatsApp',
              customer.whatsapp.isEmpty ? 'Não informado' : customer.whatsapp,
              Icons.message,
              color: Colors.green,
              trailing: customer.whatsapp.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.open_in_new, color: Colors.green),
                      onPressed: () =>
                          _launchWhatsApp(context, customer.whatsapp),
                      tooltip: 'Abrir WhatsApp',
                    )
                  : null,
            ),
            _infoRow(
              'Endereço',
              customer.address.isEmpty ? 'Não informado' : customer.address,
              Icons.location_on,
              color: Colors.blue,
              trailing: customer.address.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.map, color: Colors.blue),
                      onPressed: () =>
                          UrlLauncherUtils.launchMap(context, customer.address),
                      tooltip: 'Abrir no mapa',
                    )
                  : null,
            ),
            _infoRow(
              'Endereço',
              customer.address1!.isEmpty ? 'Não informado' : customer.address1 ??  "",
              Icons.location_on,
              color: Colors.blue,
              trailing: customer.address.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.map, color: Colors.blue),
                      onPressed: () => UrlLauncherUtils.launchMap(
                          context, customer.address1?? ""),
                      tooltip: 'Abrir no mapa',
                    )
                  : null,
            ),
            _infoRow(
              'Endereço',
              customer.address.isEmpty ? 'Não informado' : customer.address2 ?? "",
              Icons.location_on,
              color: Colors.blue,
              trailing: customer.address.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.map, color: Colors.blue),
                      onPressed: () => UrlLauncherUtils.launchMap(
                          context, customer.address2 ?? ""),
                      tooltip: 'Abrir no mapa',
                    )
                  : null,
            ),
            _infoRow(
                'Observações', customer.notes ?? 'Sem observações', Icons.note),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('FECHAR',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon,
      {Color? color, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: color ?? Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text('$label:',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                    child: Text(value,
                        style: const TextStyle(color: Colors.black87))),
                if (trailing != null) SizedBox(height: 36, child: trailing),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
