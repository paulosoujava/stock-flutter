import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/reminder/reminder.dart';
import 'package:stock/presentation/pages/reminder/form/reminder_form_intent.dart';
import 'package:stock/presentation/pages/reminder/form/reminder_form_state.dart';
import 'package:stock/presentation/pages/reminder/form/reminder_form_viewmodel.dart';

class ReminderFormPage extends StatefulWidget {
  final Reminder? reminderToEdit;
  const ReminderFormPage({super.key, this.reminderToEdit});

  @override
  State<ReminderFormPage> createState() => _ReminderFormPageState();
}

class _ReminderFormPageState extends State<ReminderFormPage> {
  // --- LÓGICA ORIGINAL 100% PRESERVADA ---
  late final ReminderFormViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late bool _isEditing;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ReminderFormViewModel>();
    _isEditing = widget.reminderToEdit != null;

    _titleController = TextEditingController(text: widget.reminderToEdit?.title);
    _contentController =
        TextEditingController(text: widget.reminderToEdit?.content);

    _viewModel.state.listen((state) {
      if (!mounted) return;
      if (state is ReminderFormSuccess) {
        context.pop(true); // Retorna 'true' para a lista recarregar
      }
      if (state is ReminderFormError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
              content: Text(state.message), backgroundColor: Colors.red));
      }
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final reminder = Reminder(
        id: widget.reminderToEdit?.id ?? '',
        title: _titleController.text,
        content: _contentController.text,
        isCompleted: widget.reminderToEdit?.isCompleted ?? false,
        createdAt: widget.reminderToEdit?.createdAt ?? DateTime.now(),
        createdBy: widget.reminderToEdit?.createdBy ?? '',
      );
      _viewModel.handleIntent(SaveReminderIntent(reminder));
    }
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
            child: StreamBuilder<ReminderFormState>(
              stream: _viewModel.state,
              builder: (context, snapshot) {
                final state = snapshot.data;
                if (state is ReminderFormLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Layout centralizado para Desktop
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Card(
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: _buildFormFields(),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
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
            offset: const Offset(0, 4),
          ),
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
            _isEditing ? 'Editar Lembrete' : 'Novo Lembrete',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            icon: const Icon(Icons.save, size: 20),
            label: const Text("Salvar"),
            onPressed: _saveForm,
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Título',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            validator: (value) =>
            value!.isEmpty ? 'O título é obrigatório' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: 'O que lembrar?',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.notes),
              alignLabelWithHint: true,
            ),
            maxLines: 8, // Aumentado para mais espaço
            keyboardType: TextInputType.multiline,
            validator: (value) =>
            value!.isEmpty ? 'O conteúdo é obrigatório' : null,
          ),
        ],
      ),
    );
  }
}