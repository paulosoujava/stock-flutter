import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stock/core/di/injection.dart';
import 'package:stock/core/navigation/app_routes.dart';
import 'package:stock/domain/entities/reminder/reminder.dart';
import 'package:stock/presentation/pages/reminder/list/reminder_list_intent.dart';
import 'package:stock/presentation/pages/reminder/list/reminder_list_state.dart';
import 'package:stock/presentation/pages/reminder/list/reminder_list_viewmodel.dart';
import 'package:stock/presentation/widgets/confirmation_dialog.dart';

class ReminderListPage extends StatefulWidget {
  const ReminderListPage({super.key});

  @override
  State<ReminderListPage> createState() => _ReminderListPageState();
}

class _ReminderListPageState extends State<ReminderListPage> {
  late final ReminderListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ReminderListViewModel>();
  }

  void _navigateToCreateForm() async {
    final bool? result = await context.push<bool>(AppRoutes.reminderCreate);
    if (result == true) {
      _viewModel.handleIntent(LoadRemindersIntent());
    }
  }

  void _navigateToEditForm(Reminder reminder) async {
    final bool? result = await context.push<bool>(
      AppRoutes.reminderCreate, // Reutiliza a mesma rota/tela do formulário
      extra: reminder,
    );
    if (result == true) {
      _viewModel.handleIntent(LoadRemindersIntent());
    }
  }

  void _showDeleteConfirmation(Reminder reminder) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Exclusão',
      content: 'Tem certeza que deseja excluir o lembrete "${reminder.title}"?',
      confirmText: 'Excluir',
    );
    if (confirmed == true) {
      _viewModel.handleIntent(DeleteReminderIntent(reminder.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lembretes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Pesquisar por título ou conteúdo...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
              ),
              onChanged: (query) =>
                  _viewModel.handleIntent(SearchRemindersIntent(query)),
            ),
          ),
        ),
      ),
      body: StreamBuilder<ReminderListState>(
        stream: _viewModel.state,
        builder: (context, snapshot) {
          final state = snapshot.data;

          if (state is ReminderListLoading || !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ReminderListError) {
            return Center(child: Text(state.message));
          }
          if (state is ReminderListLoaded) {
            if (state.reminders.isEmpty) {
              return const Center(child: Text('Nenhum lembrete cadastrado.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 80), // Espaço para o FAB
              itemCount: state.reminders.length,
              itemBuilder: (context, index) {
                final reminder = state.reminders[index];
                return _ReminderCard(
                  reminder: reminder,
                  onEdit: () => _navigateToEditForm(reminder),
                  onDelete: () => _showDeleteConfirmation(reminder),
                  onToggle: () => _viewModel.handleIntent(ToggleReminderStatusIntent(reminder)),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateForm,
        tooltip: 'Adicionar Lembrete',
        child: const Icon(Icons.add_alarm),
      ),
    );
  }
}

// Widget privado para o Card do Lembrete
class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _ReminderCard({
    required this.reminder,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = reminder.isCompleted;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: isCompleted ? Colors.grey[300] : Colors.white,
      child: ListTile(
        leading: IconButton(
          icon: Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? Colors.green : Colors.grey,
          ),
          onPressed: onToggle,
          tooltip: isCompleted ? 'Marcar como não concluído' : 'Marcar como concluído',
        ),
        title: Text(
          reminder.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reminder.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(decoration: isCompleted ? TextDecoration.lineThrough : null),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  "Criado por: ${reminder.createdBy}",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  ' em: ${DateFormat('dd/MM/yy').format(reminder.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_note, color: Colors.blue),
              tooltip: 'Editar',
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Excluir',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
