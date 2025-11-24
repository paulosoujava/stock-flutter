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
  // --- NENHUMA ALTERAÇÃO NA LÓGICA INTERNA ---
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
    _tempCustomerSavedSubscription = getIt<EventBus>().stream.listen((event) {
      if (event is RegisterEvent) _viewModel.loading();
    });
  }

  @override
  void dispose() {
    _tempCustomerSavedSubscription?.cancel();
    super.dispose();
  }
  // --- FIM DA LÓGICA INTERNA ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder<LiveListState>(
              stream: _viewModel.state,
              builder: (context, snapshot) {
                final state = snapshot.data ?? LiveListLoading();

                if (state is LiveListLoading) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.deepPurple));
                }

                if (state is LiveListError) {
                  return _buildErrorState(state.message);
                }

                if (state is LiveListLoaded) {
                  if (state.lives.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _viewModel.loadLives(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: state.lives.length,
                      itemBuilder: (_, i) {
                        final live = state.lives[i];
                        final isActive = state.activeLive?.id == live.id;
                        return _LiveCardModern(
                          key: ValueKey(live.id),
                          live: live,
                          isActive: isActive,
                          viewModel: _viewModel,
                          currency: _currency,
                          dateFormat: _dateFormat,
                        );
                      },
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  // Header da página redesenhado
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            icon: const Icon(Icons.add_circle, size: 20),
            label: const Text("Nova Live"),
            onPressed: _showCreateDialog,
          ),
        ],
      ),
    );
  }

  // Diálogo de criação redesenhado
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
            Text('Agendar Nova Live',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView( // Garante que não quebre em telas menores
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                        labelText: 'Título da Live',
                        border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(
                    controller: descriptionController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                        labelText: 'Descrição (opcional)',
                        border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(
                  controller: goalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Meta de Faturamento',
                      border: OutlineInputBorder(),
                      prefixText: 'R\$ '),
                  onChanged: (value) {
                    var text = value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (text.isEmpty) return;
                    final number = double.parse(text) / 100;
                    final formatted = NumberFormat.currency(locale: 'pt_BR', symbol: '').format(number);
                    goalController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  },
                ),
                const SizedBox(height: 16),
                StatefulBuilder(builder: (context, setStateDialog) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300)),
                    leading: const Padding(
                      padding: EdgeInsets.only(left: 12.0),
                      child: Icon(Icons.calendar_today, color: Colors.deepPurple),
                    ),
                    title: Text(
                        'Data e hora: ${_dateFormat.format(selectedDate)}',
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    trailing: const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.edit_calendar),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)));
                      if (date != null && context.mounted) {
                        final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(selectedDate));
                        if (time != null) {
                          setStateDialog(() => selectedDate = DateTime(date.year,
                              date.month, date.day, time.hour, time.minute));
                        }
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            icon: const Icon(Icons.rocket_launch, color: Colors.white, size: 18),
            label:
            const Text("Agendar Live", style: TextStyle(color: Colors.white)),
            onPressed: () {
              final title = titleController.text.trim();
              final goalCents = int.tryParse(goalController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

              if (title.isEmpty || goalCents < 100) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Preencha título e meta válida (mínimo R\$ 1,00)')));
                return;
              }

              _viewModel.handleIntent(CreateLiveIntent(
                  title,
                  descriptionController.text.trim(),
                  selectedDate,
                  goalCents));
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  // Widgets de estado da tela principal (lógica preservada)
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.live_tv_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              'Nenhuma live criada ainda',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              'Toque no botão "Nova Live" no topo da tela para começar',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Erro ao carregar lives', style: Theme.of(context).textTheme.titleMedium),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// CARD MODERNO E LIMPO (LÓGICA INTERNA 100% PRESERVADA)
class _LiveCardModern extends StatefulWidget {
  final Live live;
  final bool isActive;
  final LiveListViewModel viewModel;
  final NumberFormat currency;
  final DateFormat dateFormat;

  const _LiveCardModern(
      {super.key,
        required this.live,
        required this.isActive,
        required this.viewModel,
        required this.currency,
        required this.dateFormat});

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
    final goalAchieved = live.goalAchieved;

    return Card(
      elevation: widget.isActive ? 8.0 : 2.0,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: widget.isActive
            ? const BorderSide(color: Colors.deepPurple, width: 2)
            : BorderSide(color: Colors.grey[200]!),
      ),
      shadowColor: widget.isActive
          ? Colors.deepPurple.withOpacity(0.3)
          : Colors.black.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com Status e Ações
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _StatusBadge(status: live.status, isActive: widget.isActive),
                  const Spacer(),
                  _buildCardActions(),
                ],
              ),
              const SizedBox(height: 16),

              // Título e Descrição
              Text(live.title,
                  style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800])),
              if (live.description?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(live.description!,
                      style: TextStyle(
                          color: Colors.grey[600], fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ),
              const SizedBox(height: 24),

              // Progresso da Meta
              Text(
                'Faturado: ${widget.currency.format(totalFaturado)} / Meta: ${widget.currency.format(live.goalAmount / 100)}',
                style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(
                    goalAchieved ? Colors.green : Colors.deepPurple),
                minHeight: 12,
                borderRadius: BorderRadius.circular(6),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Footer com Data e Indicador de Expansão
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getCardFooterText(),
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.grey[600]),
                ],
              ),

              // Conteúdo Expandido (se _expanded for true)
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _expanded
                    ? Column(
                  children: [
                    const Divider(height: 32),
                    _buildExpansionContent(live: live, currency: widget.currency),
                  ],
                )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS INTERNOS DO CARD (Lógica Preservada) ---

  String _getCardFooterText() {
    final live = widget.live;
    switch (live.status) {
      case LiveStatus.scheduled:
        return 'Agendada para ${widget.dateFormat.format(live.scheduledDate)}';
      case LiveStatus.inProgress:
        return 'Iniciada em ${widget.dateFormat.format(live.startDate!)}';
      case LiveStatus.finished:
        return 'Finalizada em ${widget.dateFormat.format(live.endDate!)}';
    }
  }

  Widget _buildCardActions() {
    final live = widget.live;
    switch (live.status) {
      case LiveStatus.scheduled:
        return Row(
          children: [
            IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Excluir Live',
                onPressed: () => CustomDialog.show(
                    context: context,
                    title: 'Excluir Live?',
                    content:
                    'Tem certeza que deseja excluir a live "${live.title}"?',
                    onConfirm: () =>
                        widget.viewModel.handleIntent(DeleteLiveIntent(live.id)))),
            const SizedBox(width: 8),
            FilledButton.icon(
                icon: const Icon(Icons.play_arrow, size: 20),
                label: const Text('Iniciar Agora'),
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white),
                onPressed: () {
                  widget.viewModel.handleIntent(StartLiveIntent(live.id));
                  context.push('/live-sale/${live.id}');
                }),
          ],
        );
      case LiveStatus.inProgress:
        return FilledButton.icon(
          icon: const Icon(Icons.sensors, size: 20),
          label: const Text('Entrar na Live'),
          style: FilledButton.styleFrom(
              backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
          onPressed: () => context.push('/live-sale/${live.id}'),
        );
      case LiveStatus.finished:
        return const SizedBox.shrink(); // Nenhuma ação para lives finalizadas
    }
  }

  Widget _buildExpansionContent({required Live live, required NumberFormat currency}) {
    // A lógica interna deste FutureBuilder é 100% a mesma do seu código original
    return FutureBuilder<List<Sale>>(
      future: getIt<ISaleRepository>().getAllSales(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final salesThisLive =
        snapshot.data!.where((sale) => sale.liveId == live.id).toList();

        if (salesThisLive.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Nenhuma venda registrada nesta live ainda.',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),
          );
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

        final uniqueCustomers = uniqueProductSales.values
            .expand((e) => e)
            .map((b) => b['id']!.isNotEmpty ? b['id']! : b['name']!)
            .toSet();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people_alt, color: Colors.deepPurple, size: 20),
                      const SizedBox(width: 8),
                      Text(
                          '${uniqueCustomers.length} comprador${uniqueCustomers.length > 1 ? 'es' : ''} único${uniqueCustomers.length > 1 ? 's' : ''}',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.attach_money, color: Colors.green, size: 20),
                      const SizedBox(width: 4),
                      Text('Total: ${currency.format(salesThisLive.fold(0.0, (sum, s) => sum + s.totalAmount))}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Vendas por Produto', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...uniqueProductSales.entries.map((e) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shopping_bag_outlined, color: Colors.deepPurple),
                        const SizedBox(width: 12),
                        Expanded(child: Text(e.key, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15))),
                        Text('${e.value.length} unid.', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 24),
                    Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: e.value
                            .map((b) => CustomerChip(buyer: b, live: live))
                            .toList()),
                  ],
                ),
              ),
            )),
          ],
        );
      },
    );
  }
}

// BADGE DE STATUS (Design levemente ajustado)
class _StatusBadge extends StatelessWidget {
  final LiveStatus status;
  final bool isActive;
  const _StatusBadge({required this.status, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final Map<LiveStatus, ({String text, Color color, IconData icon})> config = {
      LiveStatus.scheduled: (
      text: 'Agendada',
      color: Colors.orange.shade700,
      icon: Icons.schedule
      ),
      LiveStatus.inProgress: (
      text: 'AO VIVO',
      color: Colors.red.shade600,
      icon: Icons.circle
      ),
      LiveStatus.finished: (
      text: 'Finalizada',
      color: Colors.grey.shade600,
      icon: Icons.check_circle
      ),
    };

    final c = config[status]!;
    final isLive = status == LiveStatus.inProgress;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: c.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (isLive)
        // Efeito de "pulsar" para a bolinha ao vivo
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.8, end: 1.2),
            duration: const Duration(milliseconds: 700),
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Icon(c.icon, size: 10, color: c.color),
          )
        else
          Icon(c.icon, size: 14, color: c.color),
        const SizedBox(width: 8),
        Text(c.text.toUpperCase(),
            style: TextStyle(
                color: c.color, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5)),
      ]),
    );
  }
}