// presentation/pages/live/live_list_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/entities/live/live.dart';
import 'package:stock/domain/entities/sale/sale.dart';
import 'package:stock/domain/repositories/isale_repository.dart';
import 'package:stock/presentation/widgets/custom_dialog.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/events/event_bus.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../domain/repositories/icustomer_repository.dart';
import 'live_list_intent.dart';
import 'live_list_state.dart';
import 'live_list_view_model.dart';

class LiveListScreen extends StatefulWidget {
  const LiveListScreen({super.key});

  @override
  State<LiveListScreen> createState() => _LiveListScreenState();
}

class _LiveListScreenState extends State<LiveListScreen> {
  late final LiveListViewModel _viewModel;

  final NumberFormat _currency =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy • HH:mm', 'pt_BR');
  StreamSubscription? _tempCustomerSavedSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<LiveListViewModel>();
    _viewModel.loadLives();
    final eventBus = getIt<EventBus>();
    _tempCustomerSavedSubscription = eventBus.stream.listen((event) {
      print('EVENTO RECEBIDO: Cliente temporário salvo');
      _viewModel.loading();
    });
  }

  @override
  void dispose() {
    _tempCustomerSavedSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
      body: StreamBuilder<LiveListState>(
        stream: _viewModel.state,
        builder: (context, snapshot) {
          final state = snapshot.data ?? LiveListLoading();

          if (state is LiveListLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple));
          }
          if (state is LiveListError) {
            return Center(child: Text('Erro: ${state.message}'));
          }

          if (state is LiveListLoaded) {
            if (state.lives.isEmpty) {
              return const Center(
                child: Text(
                  'Nenhuma live criada ainda.\nToque no + para começar',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.lives.length,
              itemBuilder: (_, i) {
                final live = state.lives[i];
                final isActive = state.activeLive?.id == live.id;
                return _LiveCardClean(
                  live: live,
                  isActive: isActive,
                  viewModel: _viewModel,
                  currency: _currency,
                  dateFormat: _dateFormat,
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  void _showCreateDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final goalController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 2));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nova Live',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Título da Live',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: goalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Meta',
                  border: OutlineInputBorder(),
                  hintText: 'Ex: 5000,00',
                ),
                onChanged: (value) {
                  var text = value.replaceAll(RegExp(r'[^0-9]'), '');
                  if (text.isEmpty) text = '0';
                  final formatted = _currency.format(int.parse(text) / 100);
                  goalController.value = TextEditingValue(
                    text: formatted,
                    selection:
                        TextSelection.collapsed(offset: formatted.length),
                  );
                },
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setStateDialog) {
                  return ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                        'Data e hora: ${_dateFormat.format(selectedDate)}'),
                    trailing: const Icon(Icons.edit_calendar),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDate),
                        );
                        if (time != null) {
                          setStateDialog(() {
                            selectedDate = DateTime(date.year, date.month,
                                date.day, time.hour, time.minute);
                          });
                        }
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            onPressed: () {
              final title = titleController.text.trim();
              final description = descriptionController.text.trim();
              final goalText =
                  goalController.text.replaceAll(RegExp(r'[^0-9]'), '');
              final goalCents = goalText.isEmpty ? 0 : int.parse(goalText);

              if (title.isEmpty || goalCents < 100) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Preencha título e meta válida (mínimo R\$ 1,00)')),
                );
                return;
              }

              _viewModel.handleIntent(
                CreateLiveIntent(
                  title,
                  description,
                  selectedDate,
                  goalCents,
                ),
              );
              Navigator.pop(ctx);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              // Para a Row ocupar apenas o espaço necessário
              children: [
                Icon(Icons.live_tv, color: Colors.white),
                // Ícone
                SizedBox(width: 8),
                // Espaçamento entre o ícone e o texto
                Text("Criar live", style: TextStyle(color: Colors.white)),
                // Texto
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveCardClean extends StatefulWidget {
  final Live live;
  final bool isActive;
  final LiveListViewModel viewModel;
  final NumberFormat currency;
  final DateFormat dateFormat;

  const _LiveCardClean({
    required this.live,
    required this.isActive,
    required this.viewModel,
    required this.currency,
    required this.dateFormat,
  });

  @override
  State<_LiveCardClean> createState() => _LiveCardCleanState();
}

class _LiveCardCleanState extends State<_LiveCardClean> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final live = widget.live;
    final progress =
        live.goalAmount > 0 ? live.achievedAmount / live.goalAmount : 0.0;
    final totalFaturado = live.achievedAmount / 100;

    return Card(
      elevation: widget.isActive ? 8 : 2,
      shadowColor: widget.isActive ? Colors.deepPurple.withOpacity(0.3) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          live.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          live.description ?? 'Sem descrição',
                          style: TextStyle(color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: live.status, isActive: widget.isActive),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Meta: ${widget.currency.format(live.goalAmount / 100)}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text(
                    widget.currency.format(totalFaturado),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: live.goalAchieved
                          ? Colors.green.shade700
                          : Colors.deepPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation(
                    live.goalAchieved ? Colors.green : Colors.deepPurple),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    live.startDate != null
                        ? 'Iniciada em ${widget.dateFormat.format(live.startDate!)}'
                        : 'Agendada para ${widget.dateFormat.format(live.scheduledDate)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Icon(_expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down),
                ],
              ),

              // CONTEÚDO EXPANDIDO - AQUI ESTÁ A CORREÇÃO PRINCIPAL
              if (_expanded) ...[
                const Divider(height: 32),
                _buildExpansionContent(live: live, currency: widget.currency),
                const SizedBox(height: 20),
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: _buildActions(context, live)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionContent(
      {required Live live, required NumberFormat currency}) {
    return FutureBuilder<List<Sale>>(
      future: getIt<ISaleRepository>().getAllSales(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final salesThisLive = snapshot.data!.where((sale) {
          final saleDate = sale.saleDate;
          final start = live.startDate;
          final end = live.endDate ?? DateTime.now();
          return start != null &&
              saleDate.isAfter(start.subtract(const Duration(minutes: 2))) &&
              saleDate.isBefore(end.add(const Duration(minutes: 10)));
        }).toList();

        if (salesThisLive.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Nenhuma venda registrada nesta live',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          );
        }

        final Map<String, List<Map<String, String>>> productSales = {};
        for (final sale in salesThisLive) {
          for (final item in sale.items) {
            final productName = item.productName;
            final customerName =
                sale.customerName.replaceAll(' (não cadastrado)', '');
            final customerId = sale.customerId;

            productSales.putIfAbsent(productName, () => []);
            productSales[productName]!
                .add({'name': customerName, 'id': customerId});
          }
        }

        // Remove duplicatas por produto
        final uniqueProductSales = productSales.map((product, buyers) {
          print(buyers);
          final unique = <String, Map<String, String>>{};
          for (var b in buyers) {
            final key = b['id']!.isNotEmpty ? b['id']! : b['name']!;
            unique[key] = b;
          }
          return MapEntry(product, unique.values.toList());
        });

        // Compradores únicos
        final uniqueCustomers = <String>{};
        for (final buyers in uniqueProductSales.values) {
          for (final b in buyers) {
            final key = b['id']!.isNotEmpty ? b['id']! : b['name']!;
            uniqueCustomers.add(key);
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.people_alt_outlined,
                      color: Colors.deepPurple),
                  const SizedBox(width: 10),
                  Text(
                    '${uniqueCustomers.length} comprador${uniqueCustomers.length != 1 ? 'es' : ''} único${uniqueCustomers.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  Text(
                    'Total: ${currency.format(salesThisLive.fold(0.0, (sum, s) => sum + s.totalAmount))}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...uniqueProductSales.entries.map((entry) {
              final productName = entry.key;
              final buyers = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shopping_bag_outlined, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(productName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15))),
                        Text(
                            '${buyers.length} venda${buyers.length > 1 ? 's' : ''}'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: buyers.map((buyer) {
                        return CustomerChip(buyer: buyer);
                      }).toList(),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  List<Widget> _buildActions(BuildContext context, Live live) {
    switch (live.status) {
      case LiveStatus.scheduled:
        return [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => CustomDialog.show(
              context: context,
              title: 'Excluir?',
              content: 'Não pode ser desfeito',
              onConfirm: () =>
                  widget.viewModel.handleIntent(DeleteLiveIntent(live.id)),
            ),
          ),
          FilledButton.tonal(
            onPressed: () {
              widget.viewModel.handleIntent(StartLiveIntent(live.id));
              context.push('/live-sale/${live.id}');
            },
            child: const Text('Iniciar'),
          ),
        ];
      case LiveStatus.inProgress:
        return [
          FilledButton(
              onPressed: () => context.push('/live-sale/${live.id}'),
              child: const Text('Entrar na Live')),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => CustomDialog.show(
              context: context,
              title: 'Finalizar?',
              content: 'Não poderá mais vender',
              onConfirm: () =>
                  widget.viewModel.handleIntent(FinishLiveIntent(live.id)),
            ),
            child: const Text('Finalizar', style: TextStyle(color: Colors.red)),
          ),
        ];
      case LiveStatus.finished:
        return [
          Text(
            'Finalizada em ${DateFormat('dd/MM HH:mm').format(live.endDate!)}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          )
        ];
    }
  }
}

class CustomerChip extends StatefulWidget {
  final Map<String, dynamic> buyer;

  const CustomerChip({super.key, required this.buyer});

  @override
  State<CustomerChip> createState() => _CustomerChipState();
}

class _CustomerChipState extends State<CustomerChip> {
  // Guarda o resultado da busca para não repetir a chamada
  Future<Customer?>? _customerFuture;

  @override
  void initState() {
    super.initState();
    // Inicia a busca pelos dados do cliente assim que o widget é criado
    _customerFuture = _fetchCustomerData();
  }

  Widget _infoRow(IconData? icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
          ] else
            const SizedBox(width: 32),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Future<Customer?> _fetchCustomerData() {
    final name = widget.buyer['name'] as String;
    final id = widget.buyer['id'] as String;
    final customerRepo = getIt<ICustomerRepository>();
    return customerRepo.getCustomersByIdOrInstagram(id, name);
  }

  @override
  Widget build(BuildContext context) {
    // FutureBuilder espera o resultado da busca e constrói a UI de acordo
    return FutureBuilder<Customer?>(
      future: _customerFuture,
      builder: (context, snapshot) {
        // Enquanto os dados estão sendo carregados, mostra um chip de 'loading'
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Chip(
            label: SizedBox(
                width: 20, height: 10, child: LinearProgressIndicator()),
          );
        }

        final fullCustomer = snapshot.data;
        final name = widget.buyer['name'] as String;
        final id = widget.buyer['id'] as String;
        final isRegistered = (fullCustomer != null &&
            fullCustomer.id.isNotEmpty &&
            !fullCustomer.id.startsWith('temp_'));

        // Constrói o Chip final quando os dados chegam
        return GestureDetector(
          onTap: () {
            if (isRegistered && fullCustomer != null) {
              // --- Lógica para mostrar o AlertDialog (cliente registrado) ---
              // (copiado do seu código original)
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.deepPurple.shade100,
                        child: Text(
                          fullCustomer.name[0].toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          fullCustomer.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (fullCustomer.instagram != null &&
                              fullCustomer.instagram!.isNotEmpty)
                            _infoRow(Icons.alternate_email,
                                '@${fullCustomer.instagram}'),
                          if (fullCustomer.phone != null &&
                              fullCustomer.phone!.isNotEmpty)
                            _infoRow(Icons.phone, fullCustomer.phone!),
                          if (fullCustomer.whatsapp != null &&
                              fullCustomer.whatsapp!.isNotEmpty)
                            _infoRow(Icons.whatshot, fullCustomer.whatsapp!),
                          if (fullCustomer.email != null &&
                              fullCustomer.email!.isNotEmpty)
                            _infoRow(Icons.email, fullCustomer.email!),
                          if (fullCustomer.cpf != null &&
                              fullCustomer.cpf!.isNotEmpty)
                            _infoRow(Icons.badge, fullCustomer.cpf!),
                          if (fullCustomer.address != null &&
                              fullCustomer.address!.isNotEmpty) ...[
                            _infoRow(Icons.home, fullCustomer.address!),
                            if (fullCustomer.address1 != null)
                              _infoRow(null, fullCustomer.address1!),
                            if (fullCustomer.address2 != null)
                              _infoRow(null, fullCustomer.address2!),
                          ],
                          if (fullCustomer.notes != null &&
                              fullCustomer.notes!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Observações:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(fullCustomer.notes!,
                                      style:
                                          TextStyle(color: Colors.grey[700])),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Fechar')),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push(AppRoutes.customerEdit,
                            extra: fullCustomer);
                      },
                    ),
                  ],
                ),
              );
            } else {
              // --- Lógica para abrir a tela de edição (cliente não registrado) ---
              // (copiado do seu código original)
              String raw = name.replaceAll(' (não cadastrado)', '').trim();
              String instagram = raw.startsWith('@') ? raw.substring(1) : raw;
              instagram = instagram.split(' ').first;

              final tempCustomer = Customer(
                id: '',
                name: raw.replaceAll('@', '').split(' ').first,
                instagram: instagram,
                cpf: '',
                email: '',
                phone: '',
                whatsapp: '',
                address: '',
                address1: null,
                address2: null,
              );
              context.push(AppRoutes.customerEdit, extra: tempCustomer);
            }
          },
          child: Chip(
            avatar: Icon(
              isRegistered ? Icons.person : Icons.person_add,
              size: 16,
              color:
                  isRegistered ? Colors.green.shade700 : Colors.orange.shade700,
            ),
            label: Text(name, style: const TextStyle(fontSize: 12)),
            backgroundColor:
                isRegistered ? Colors.green[50] : Colors.orange[50],
          ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final LiveStatus status;
  final bool isActive;

  const _StatusBadge({required this.status, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final config = {
      LiveStatus.scheduled: (
        text: 'Agendada',
        color: Colors.orange,
        icon: Icons.schedule
      ),
      LiveStatus.inProgress: (
        text: 'Em Live',
        color: Colors.green,
        icon: Icons.circle
      ),
      LiveStatus.finished: (
        text: 'Finalizada',
        color: Colors.grey,
        icon: Icons.check_circle
      ),
    }[status]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withOpacity(isActive ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: isActive ? Border.all(color: config.color) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.color),
          const SizedBox(width: 6),
          Text(config.text,
              style: TextStyle(
                  color: config.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ],
      ),
    );
  }
}
