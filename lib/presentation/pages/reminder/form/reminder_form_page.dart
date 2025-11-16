import 'package:flutter/material.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/domain/entities/reminder/reminder.dart';
import 'package:stock/presentation/pages/reminder/form/reminder_form_intent.dart';
import 'package:stock/presentation/pages/reminder/form/reminder_form_state.dart';
import 'package:stock/presentation/pages/reminder/form/reminder_form_viewmodel.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/app_module.dart';

class ReminderFormPage extends StatefulWidget {
  final Reminder? reminderToEdit;
  const ReminderFormPage({super.key, this.reminderToEdit});

  @override
  State<ReminderFormPage> createState() => _ReminderFormPageState();
}

class _ReminderFormPageState extends State<ReminderFormPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Lembrete' : 'Novo Lembrete'),

        actions: const [],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveForm,
        label: const Text('Salvar'),
        icon: const Icon(Icons.save),
      ),
      body: StreamBuilder<ReminderFormState>(
          stream: _viewModel.state,
          builder: (context, snapshot) {

            final state = snapshot.data;
            if (state is ReminderFormLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
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
                            maxLines: 6,
                            keyboardType: TextInputType.multiline,
                            validator: (value) =>
                            value!.isEmpty ? 'O conteúdo é obrigatório' : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
