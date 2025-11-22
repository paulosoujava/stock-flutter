// presentation/pages/live/live_list_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stock/domain/entities/customer/customer.dart';
import 'package:stock/domain/entities/live/live.dart';
import 'package:stock/domain/entities/sale/sale.dart';
import 'package:stock/domain/repositories/isale_repository.dart';
import 'package:stock/presentation/widgets/custom_dialog.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/events/event_bus.dart';
import '../sale/widget/customer_chip.dart';
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
  StreamSubscription? _tempCustomerSavedSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<LiveListViewModel>();
    _viewModel.loadLives();
    _tempCustomerSavedSubscription = getIt<EventBus>().stream.listen((event) {
      if (event is RegisterEvent) _viewModel.loading();
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Nova Live", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: _showCreateDialog,
      ),
      body: StreamBuilder<LiveListState>(
        stream: _viewModel.state,
        builder: (context, snapshot) {
          final state = snapshot.data ?? LiveListLoading();

          if (state is LiveListLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }

          if (state is LiveListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erro ao carregar lives', style: Theme.of(context).textTheme.titleMedium),
                  Text(state.message, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          if (state is LiveListLoaded) {
            if (state.lives.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.live_tv_outlined, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 24),
                      Text(
                        'Nenhuma live criada ainda',
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toque no botão + para começar sua primeira live',
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: state.lives.length,
              itemBuilder: (_, i) {
                final live = state.lives[i];
                final isActive = state.activeLive?.id == live.id;
                return _LiveCardModern(
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
        title: Row(
          children: [
            const Icon(Icons.live_tv, color: Colors.deepPurple),
            const SizedBox(width: 12),
            Text('Nova Live', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Título da Live', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: 'Descrição (opcional)', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(
              controller: goalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Meta', border: OutlineInputBorder(), hintText: 'Ex: 5000,00'),
              onChanged: (value) {
                var text = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (text.isEmpty) text = '0';
                final formatted = _currency.format(int.parse(text) / 100);
                goalController.value = TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
              },
            ),
            const SizedBox(height: 16),
            StatefulBuilder(builder: (context, setStateDialog) {
              return ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                title: Text('Data e hora: ${_dateFormat.format(selectedDate)}', style: const TextStyle(fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.edit_calendar),
                onTap: () async {
                  final date = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                  if (date != null) {
                    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(selectedDate));
                    if (time != null) {
                      setStateDialog(() => selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                    }
                  }
                },
              );
            }),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            icon: const Icon(Icons.live_tv, color: Colors.white),
            label: const Text("Criar Live", style: TextStyle(color: Colors.white)),
            onPressed: () {
              final title = titleController.text.trim();
              final goalCents = int.tryParse(goalController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

              if (title.isEmpty || goalCents < 100) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha título e meta válida (mínimo R\$ 1,00)')));
                return;
              }

              _viewModel.handleIntent(CreateLiveIntent(title, descriptionController.text.trim(), selectedDate, goalCents));
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}

// CARD MODERNO E LIMPO
class _LiveCardModern extends StatefulWidget {
  final Live live;
  final bool isActive;
  final LiveListViewModel viewModel;
  final NumberFormat currency;
  final DateFormat dateFormat;

  const _LiveCardModern({required this.live, required this.isActive, required this.viewModel, required this.currency, required this.dateFormat});

  @override
  State<_LiveCardModern> createState() => _LiveCardModernState();
}

class _LiveCardModernState extends State<_LiveCardModern> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final live = widget.live;
    final progress = live.goalAmount > 0 ? live.achievedAmount / live.goalAmount : 0.0;
    final totalFaturado = live.achievedAmount / 100;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: widget.isActive ? Colors.deepPurple.withOpacity(0.2) : Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
        ],
        border: widget.isActive ? Border.all(color: Colors.deepPurple, width: 2) : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho
                  Row(
                    children: [
                      _StatusBadge(status: live.status, isActive: widget.isActive),
                      const Spacer(),
                      if (live.status == LiveStatus.scheduled) ...[
                        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => CustomDialog.show(context: context, title: 'Excluir?', content: 'Não pode ser desfeito', onConfirm: () => widget.viewModel.handleIntent(DeleteLiveIntent(live.id)))),
                        FilledButton.tonal(onPressed: () {
                          widget.viewModel.handleIntent(StartLiveIntent(live.id));
                          context.push('/live-sale/${live.id}');
                        }, child: const Text('Iniciar Live')),
                      ],
                      if (live.status == LiveStatus.inProgress)
                        FilledButton(onPressed: () => context.push('/live-sale/${live.id}'), child: const Text('Entrar na Live')),
                      if (live.status == LiveStatus.finished)
                        Text('Finalizada • ${DateFormat('dd/MM HH:mm').format(live.endDate!)}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Título e descrição
                  Text(live.title, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                  if (live.description?.isNotEmpty == true)
                    Padding(padding: const EdgeInsets.only(top: 4), child: Text(live.description!, style: TextStyle(color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis)),

                  const SizedBox(height: 20),

                  // Meta e progresso
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Meta: ${widget.currency.format(live.goalAmount / 100)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(widget.currency.format(totalFaturado), style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: live.goalAchieved ? Colors.green.shade700 : Colors.deepPurple)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(live.goalAchieved ? Colors.green : Colors.deepPurple),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        live.startDate != null
                            ? 'Iniciada em ${widget.dateFormat.format(live.startDate!)}'
                            : 'Agendada para ${widget.dateFormat.format(live.scheduledDate)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey[600]),
                    ],
                  ),

                  // Conteúdo expandido
                  if (_expanded) ...[
                    const Divider(height: 40),
                    _buildExpansionContent(live: live, currency: widget.currency),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionContent({required Live live, required NumberFormat currency}) {
    return FutureBuilder<List<Sale>>(
      future: getIt<ISaleRepository>().getAllSales(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final salesThisLive = snapshot.data!.where((sale) {
          final saleDate = sale.saleDate;
          final start = live.startDate;
          final end = live.endDate ?? DateTime.now();
          return start != null && saleDate.isAfter(start.subtract(const Duration(minutes: 2))) && saleDate.isBefore(end.add(const Duration(minutes: 10)));
        }).toList();

        if (salesThisLive.isEmpty) {
          return const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Text('Nenhuma venda registrada nesta live', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic), textAlign: TextAlign.center));
        }

        final Map<String, List<Map<String, String>>> productSales = {};
        for (final sale in salesThisLive) {
          for (final item in sale.items) {
            final productName = item.productName;
            final customerName = sale.customerName.replaceAll(' (não cadastrado)', '');
            final customerId = sale.customerId;
            productSales.putIfAbsent(productName, () => []);
            productSales[productName]!.add({'name': customerName, 'id': customerId});
          }
        }

        final uniqueProductSales = productSales.map((product, buyers) {
          final unique = <String, Map<String, String>>{};
          for (var b in buyers) {
            final key = b['id']!.isNotEmpty ? b['id']! : b['name']!;
            unique[key] = b;
          }
          return MapEntry(product, unique.values.toList());
        });

        final uniqueCustomers = uniqueProductSales.values.expand((e) => e).map((b) => b['id']!.isNotEmpty ? b['id']! : b['name']!).toSet();

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(Icons.people_alt, color: Colors.deepPurple),
                  const SizedBox(width: 12),
                  Text('${uniqueCustomers.length} comprador${uniqueCustomers.length > 1 ? 'es' : ''} único${uniqueCustomers.length > 1 ? 's' : ''}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('Total: ${currency.format(salesThisLive.fold(0.0, (sum, s) => sum + s.totalAmount))}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...uniqueProductSales.entries.map((e) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shopping_bag_outlined, color: Colors.deepPurple),
                      const SizedBox(width: 8),
                      Expanded(child: Text(e.key, style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                      Text('${e.value.length} venda${e.value.length > 1 ? 's' : ''}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: e.value.map((b) => CustomerChip(buyer: b, live: live)).toList()),
                ],
              ),
            )),
          ],
        );
      },
    );
  }
}

// Status Badge (melhorado)
class _StatusBadge extends StatelessWidget {
  final LiveStatus status;
  final bool isActive;
  const _StatusBadge({required this.status, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final Map<LiveStatus, ({String text, Color color, IconData icon})> config = {
      LiveStatus.scheduled: (text: 'Agendada', color: Colors.orange.shade700, icon: Icons.schedule),
      LiveStatus.inProgress: (text: 'AO VIVO', color: Colors.green.shade600, icon: Icons.circle),
      LiveStatus.finished: (text: 'Finalizada', color: Colors.grey.shade600, icon: Icons.check_circle),
    };

    final c = config[status]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: c.color.withOpacity(isActive ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(30),
        border: isActive ? Border.all(color: c.color, width: 1.5) : null,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(c.icon, size: 16, color: c.color),
        const SizedBox(width: 6),
        Text(c.text, style: TextStyle(color: c.color, fontWeight: FontWeight.bold, fontSize: 13)),
      ]),
    );
  }
}
