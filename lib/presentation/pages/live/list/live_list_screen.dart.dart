// presentation/pages/live/live_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/entities/live/live.dart';
import 'package:stock/domain/entities/sale/sale.dart';
import 'package:stock/domain/repositories/isale_repository.dart';
import 'package:stock/presentation/widgets/custom_dialog.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/navigation/app_routes.dart';
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

  final NumberFormat _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy • HH:mm', 'pt_BR');

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<LiveListViewModel>();
    _viewModel.loadLives();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      /*appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Minhas Lives', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        actions: [
          //IconButton(icon: const Icon(Icons.refresh, color: Colors.black54), onPressed: _viewModel.loadLives),
        ],
      ),*/
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: _showCreateDialog,
        child:  Icon(Icons.add, size: 28, color: Colors.white),
      ),
      body: StreamBuilder<LiveListState>(
        stream: _viewModel.state,
        builder: (context, snapshot) {
          final state = snapshot.data ?? LiveListLoading();

          if (state is LiveListLoading) return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          if (state is LiveListError) {
            return Center(child: Text('Erro: ${state.message}'));
          }

          if (state is LiveListLoaded) {
            if (state.lives.isEmpty) {
              return const Center(child: Text('Nenhuma live criada ainda.\nToque no + para começar', textAlign: TextAlign.center));
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
        title: const Text('Nova Live', style: TextStyle(fontWeight: FontWeight.bold)),
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
                decoration: InputDecoration(
                  labelText: 'Meta',
                  prefixText: 'R\$ ',
                  border: const OutlineInputBorder(),
                  hintText: 'Ex: 5000,00',
                ),
                onChanged: (value) {
                  var text = value.replaceAll(RegExp(r'[^0-9]'), '');
                  if (text.isEmpty) text = '0';
                  final formatted = _currency.format(int.parse(text) / 100);
                  goalController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                },
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setStateDialog) {
                  return ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text('Data e hora: ${_dateFormat.format(selectedDate)}'),
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
                            selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
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
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            onPressed: () {
              final title = titleController.text.trim();
              final description = descriptionController.text.trim();
              final goalText = goalController.text.replaceAll(RegExp(r'[^0-9]'), '');
              final goalCents = goalText.isEmpty ? 0 : int.parse(goalText);

              if (title.isEmpty || goalCents < 100) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preencha título e meta válida (mínimo R\$ 1,00)')),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Live criada com sucesso!')),
              );
            },
            child: const Text('Criar Live', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _LiveCardClean extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final status = live.status;
    final goalReached = live.goalAchieved;

    return Card(
      elevation: isActive ? 12 : 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(live.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                _StatusBadge(status: status, isActive: isActive),
              ],
            ),
            const SizedBox(height: 8),
            Text(live.description, style: TextStyle(color: Colors.grey[600])),

            const SizedBox(height: 20),

            // STATUS ESPECÍFICOS
            if (status == LiveStatus.scheduled)
              Row(children: [const Icon(Icons.calendar_today, size: 18, color: Colors.orange), const SizedBox(width: 8), Text(dateFormat.format(live.scheduledDate))]),

            if (status == LiveStatus.inProgress) ...[
              _buildRow('Meta', currency.format(live.goalAmount / 100)),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: live.achievedAmount / live.goalAmount.clamp(1, double.infinity), color: Colors.deepPurple, backgroundColor: Colors.grey[300]),
              const SizedBox(height: 8),
              _buildRow('Faturado', currency.format(live.achievedAmount / 100)),
            ],

            if (status == LiveStatus.finished) ...[
              Row(
                children: [
                  Icon(goalReached ? Icons.celebration : Icons.check_circle, color: goalReached ? Colors.green : Colors.grey[700]),
                  const SizedBox(width: 8),
                  Text(goalReached ? 'Meta batida!' : 'Live finalizada', style: TextStyle(fontWeight: FontWeight.w600, color: goalReached ? Colors.green : null)),
                  const Spacer(),
                  Text('Faturado: ${currency.format(live.achievedAmount / 100)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              // RESUMO DE VENDAS POR PRODUTO
              FutureBuilder<List<Sale>>(
                future: getIt<ISaleRepository>().getSalesByMonth(live.endDate!.year, live.endDate!.month),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox(height: 60, child: LinearProgressIndicator());

                  final sales = snapshot.data!
                      .where((s) => s.saleDate.isAfter(live.startDate!) && s.saleDate.isBefore(live.endDate!.add(const Duration(minutes: 5))))
                      .toList();

                  if (sales.isEmpty) return const Text('Nenhuma venda registrada', style: TextStyle(color: Colors.grey));

                  final Map<String, List<Sale>> salesByProduct = {};
                  for (var sale in sales) {
                    for (var item in sale.items) {
                      salesByProduct.putIfAbsent(item.productName, () => []);
                      salesByProduct[item.productName]!.add(sale);
                    }
                  }

                  return Column(
                    children: salesByProduct.entries.map((entry) {
                      final productName = entry.key;
                      final buyers = entry.value.map((s) => {'name': s.customerName, 'id': s.customerId}).toList();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.shopping_bag_outlined, size: 18),
                                const SizedBox(width: 8),
                                Text(productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                const Spacer(),
                                Text('${buyers.length} venda${buyers.length > 1 ? 's' : ''}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: buyers.map((buyer) {
                                final name = buyer['name'] as String;
                                final id = buyer['id'] as String;
                                final isRegistered = id.isNotEmpty && !id.startsWith('temp_');

                                return GestureDetector(
                                  onTap: () {
                                    if (isRegistered) {
                                      // Abre perfil do cliente já cadastrado
                                      context.push(AppRoutes.customerCreate, extra: id);
                                    } else {
                                      // Cria cliente temporário e abre formulário
                                      final tempCustomer = Customer(
                                        id: '',
                                        name: name.replaceAll(' (não cadastrado)', ''),
                                        instagram: name.contains('@') ? name.split('@').last.split(' ').first : '',
                                        cpf: '', email: '', phone: '', whatsapp: '', address: '', address1: null, address2: null,
                                      );
                                      context.push(AppRoutes.customerEdit, extra: tempCustomer);
                                    }
                                  },
                                  child: Chip(
                                    avatar: Icon(
                                      isRegistered ? Icons.person : Icons.person_add,
                                      size: 16,
                                      color: isRegistered ? Colors.green : Colors.orange[700],
                                    ),
                                    label: Text(name.replaceAll(' (não cadastrado)', ''), style: const TextStyle(fontSize: 12)),
                                    backgroundColor: isRegistered ? Colors.green[50] : Colors.orange[50],
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],

            const SizedBox(height: 20),

            // AÇÕES
            Row(mainAxisAlignment: MainAxisAlignment.end, children: _buildActions(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.grey)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]);
  }

  List<Widget> _buildActions(BuildContext context) {
    switch (live.status) {
      case LiveStatus.scheduled:
        return [
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => CustomDialog.show(context: context, title: 'Excluir?', content: 'Não pode ser desfeito', onConfirm: () => viewModel.handleIntent(DeleteLiveIntent(live.id)))),
          FilledButton.tonal(onPressed: () { viewModel.handleIntent(StartLiveIntent(live.id)); context.push('/live-sale/${live.id}'); }, child: const Text('Iniciar')),
        ];
      case LiveStatus.inProgress:
        return [
          FilledButton(onPressed: () => context.push('/live-sale/${live.id}'), child: const Text('Entrar na Live')),
          const SizedBox(width: 8),
          OutlinedButton(onPressed: () => CustomDialog.show(context: context, title: 'Finalizar?', content: 'Não poderá mais vender', onConfirm: () => viewModel.handleIntent(FinishLiveIntent(live.id))), child: const Text('Finalizar', style: TextStyle(color: Colors.red))),
        ];
      case LiveStatus.finished:
        return [Text('Finalizada em ${DateFormat('dd/MM HH:mm').format(live.endDate!)}', style: TextStyle(color: Colors.grey[600], fontSize: 12))];
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final LiveStatus status;
  final bool isActive;
  const _StatusBadge({required this.status, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final config = {
      LiveStatus.scheduled: (text: 'Agendada', color: Colors.orange, icon: Icons.schedule),
      LiveStatus.inProgress: (text: 'Em Live', color: Colors.green, icon: Icons.circle),
      LiveStatus.finished: (text: 'Finalizada', color: Colors.grey, icon: Icons.check_circle),
    }[status]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: config.color.withOpacity(isActive ? 0.2 : 0.1), borderRadius: BorderRadius.circular(20), border: isActive ? Border.all(color: config.color) : null),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(config.icon, size: 14, color: config.color), const SizedBox(width: 6), Text(config.text, style: TextStyle(color: config.color, fontWeight: FontWeight.bold, fontSize: 12))]),
    );
  }
}