import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateLiveDialog extends StatefulWidget {
  final void Function({required String title, required double goal, required DateTime dateTime}) onConfirm;

  const CreateLiveDialog({super.key, required this.onConfirm});

  @override
  State<CreateLiveDialog> createState() => _CreateLiveDialogState();
}

class _CreateLiveDialogState extends State<CreateLiveDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController goalCtrl = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  late AnimationController anim;
  late Animation<double> scale;

  @override
  void initState() {
    super.initState();
    anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    scale = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
    anim.forward();
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (result != null) setState(() => selectedDate = result);
  }

  Future<void> pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (result != null) setState(() => selectedTime = result);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scale,
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.video_call, size: 30, color: Colors.deepPurple),
            SizedBox(width: 10),
            Text("Criar nova Live", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  labelText: "Meta de Faturamento (R\$)",
                  prefixIcon: Icon(Icons.star),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: pickDate,
                      icon: const Icon(Icons.calendar_month),
                      label: Text(
                        selectedDate == null
                            ? "Escolher Data"
                            : DateFormat('dd/MM/yyyy').format(selectedDate!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: pickTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(
                        selectedTime == null
                            ? "Escolher Hora"
                            : selectedTime!.format(context),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          FilledButton.icon(
            onPressed: () {
              if (titleCtrl.text.isEmpty || goalCtrl.text.isEmpty || selectedDate == null || selectedTime == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Preencha todos os campos!")),
                );
                return;
              }

              final dateTime = DateTime(
                selectedDate!.year,
                selectedDate!.month,
                selectedDate!.day,
                selectedTime!.hour,
                selectedTime!.minute,
              );

              widget.onConfirm(
                title: titleCtrl.text,
                goal: double.tryParse(goalCtrl.text) ?? 0,
                dateTime: dateTime,
              );

              Navigator.pop(context);
            },
            icon: const Icon(Icons.check_circle),
            label: const Text("Criar Live"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    anim.dispose();
    super.dispose();
  }
}
