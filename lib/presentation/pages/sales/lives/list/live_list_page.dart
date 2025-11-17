import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../widgets/confirmation_dialog.dart';
import '../live_session_dialog.dart';

class LiveModel {
  final String id;
  final String title;
  final double goal;
  final double totalSold;
  final DateTime date;
  final String status; // agendada, em_live, finalizada
  final List<ProductSale> sales;

  LiveModel({
    required this.id,
    required this.title,
    required this.goal,
    required this.totalSold,
    required this.date,
    required this.status,
    required this.sales,
  });
}

class ProductSale {
  final String productName;
  final List<String> buyers;

  ProductSale({
    required this.productName,
    required this.buyers,
  });
}

class LiveListPage extends StatefulWidget {
  const LiveListPage({super.key});

  @override
  State<LiveListPage> createState() => _LiveListPageState();
}

class _LiveListPageState extends State<LiveListPage> {
  final List<LiveModel> lives = [
    LiveModel(
      id: "1",
      title: "Live de Ofertas🔥",
      goal: 2000,
      totalSold: 1800,
      date: DateTime.now().add(const Duration(days: 1)),
      status: "agendada",
      sales: [
        ProductSale(productName: "Camiseta Nike", buyers: ["@jose", "@ana"]),
        ProductSale(productName: "Boné Puma", buyers: ["@maria"]),
      ],
    ),
    LiveModel(
      id: "2",
      title: "Mega Live Black Friday 💣",
      goal: 5000,
      totalSold: 3500,
      date: DateTime.now(),
      status: "em_live",
      sales: [
        ProductSale(productName: "Tênis Adidas", buyers: ["@joao", "@batista", "@aline"]),
        ProductSale(productName: "Calça Jeans", buyers: ["@paulo"]),
      ],
    ),
    LiveModel(
      id: "3",
      title: "Live Festa Premium ✨",
      goal: 3000,
      totalSold: 3800,
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: "finalizada",
      sales: [
        ProductSale(productName: "Jaqueta", buyers: ["@caique", "@julia"]),
        ProductSale(productName: "Short", buyers: ["@marcos", "@lara", "@bia"]),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: lives.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, i) => _LiveTile(
          item: lives[i],
          onDelete: () async{
            final confirm = await showConfirmationDialog(
              context: context,
              title: "Remover Live",
              content: "Tem certeza que deseja excluir esta live?",
              confirmText: "Excluir",
            );

            if (confirm == true) {
              setState(() {
                setState(() => lives.removeAt(i));
              });
            }

          },
          onHistory: () => _openHistory(lives[i]),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Nova Live"),
        onPressed: _openCreateLiveDialog,
      ),
    );
  }

  void _openHistory(LiveModel live) {
    showDialog(
      context: context,
      builder: (_) => _HistoryDialog(live: live),
    );
  }

  void _openCreateLiveDialog() {
    showDialog(
      context: context,
      builder: (_) => const _CreateLiveDialog(),
    );
  }
}

//
//
//                TILE DA LIVE — CORRIGIDO 🔥
//
class _LiveTile extends StatelessWidget {
  final LiveModel item;
  final VoidCallback onDelete;
  final VoidCallback onHistory;

  const _LiveTile({
    required this.item,
    required this.onDelete,
    required this.onHistory,
  });

  Color get statusColor {
    switch (item.status) {
      case "agendada": return Colors.blue;
      case "em_live": return Colors.orange;
      default: return Colors.green;
    }
  }

  IconData get statusIcon {
    switch (item.status) {
      case "agendada": return Icons.schedule;
      case "em_live": return Icons.wifi_tethering;
      default: return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final percent = (item.totalSold / item.goal).clamp(0, 1);
    final metaBatida = item.totalSold >= item.goal;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              if (item.status != "finalizada")
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: onDelete,
                ),
            ],
          ),

          const SizedBox(height: 8),
          Text("Data: ${DateFormat('dd/MM/yyyy – HH:mm').format(item.date)}"),

          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: 8,
            color: metaBatida ? Colors.green : Colors.blue,
            backgroundColor: Colors.grey.shade300,
          ),

          const SizedBox(height: 6),
          Text(
            "R\$ ${item.totalSold.toStringAsFixed(2)} / Meta: R\$ ${item.goal.toStringAsFixed(2)}",
          ),

          if (metaBatida) ...[
            const SizedBox(height: 12),
            Row(children: const [
              Icon(Icons.emoji_events, color: Colors.amber, size: 30),
              SizedBox(width: 10),
              Text("Meta Atingida!",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ]),
          ],

          const SizedBox(height: 16),
          _buildActionButton(context),
        ],
      ),
    );
  }

  //
  // BOTÃO CORRIGIDO — AGORA TEM CONTEXT ✔
  //
  Widget _buildActionButton(BuildContext context) {
    switch (item.status) {
      case "agendada":
        return FilledButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: const Text("Iniciar"),
          style: FilledButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {},
        );

      case "em_live":
        return FilledButton.icon(
          icon: const Icon(Icons.live_tv),
          label: const Text("Ir para Live"),
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed:(){_openLiveSession(context, item);},
        );

      case "finalizada":
        return FilledButton.icon(
          icon: const Icon(Icons.history),
          label: const Text("Histórico"),
          style: FilledButton.styleFrom(backgroundColor: Colors.grey.shade700),
          onPressed: onHistory,
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
void _openLiveSession(BuildContext context, LiveModel live) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => LiveSessionDialog(live: live),
  );
}

//
//                  POPUP HISTÓRICO
//
class _HistoryDialog extends StatelessWidget {
  final LiveModel live;
  const _HistoryDialog({required this.live});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Histórico - ${live.title}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            ...live.sales.map((p) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.productName,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),

                ...p.buyers.map((b) => Row(
                  children: [
                    Text(b, style: const TextStyle(fontSize: 15)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                      onPressed: () {},
                    ),
                  ],
                )),
                const SizedBox(height: 14),
              ],
            )),

            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                child: const Text("Fechar"),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
//              POPUP DE CRIAÇÃO — COM ANIMAÇÃO
//
class _CreateLiveDialog extends StatefulWidget {
  const _CreateLiveDialog();

  @override
  State<_CreateLiveDialog> createState() => _CreateLiveDialogState();
}

class _CreateLiveDialogState extends State<_CreateLiveDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _scale;

  final titleCtrl = TextEditingController();
  final goalCtrl = TextEditingController();
  DateTime? date;
  TimeOfDay? time;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scale = CurvedAnimation(parent: _anim, curve: Curves.easeOutBack);
    _anim.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 550,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: const [
                  Icon(Icons.video_call, color: Colors.purple, size: 28),
                  SizedBox(width: 10),
                  Text("Nova Live",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),

              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: "Título da Live",
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: goalCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Meta em R\$",
                  prefixIcon: Icon(Icons.flag),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.calendar_month),
                      label: Text(
                        date == null
                            ? "Escolher Data"
                            : DateFormat("dd/MM/yyyy").format(date!),
                      ),
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2050),
                          initialDate: DateTime.now(),
                        );
                        if (d != null) setState(() => date = d);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        time == null
                            ? "Escolher Hora"
                            : time!.format(context),
                      ),
                      onPressed: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (t != null) setState(() => time = t);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              Align(
                alignment: Alignment.bottomRight,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Criar Live"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
