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

import '../../../../core/di/app_module.dart';

class ReminderListPage extends StatefulWidget {
  const ReminderListPage({super.key});

  @override
  State<ReminderListPage> createState() => _ReminderListPageState();
}

class _ReminderListPageState extends State<ReminderListPage> with TickerProviderStateMixin {
  late final ReminderListViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ReminderListViewModel>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToCreateForm() async {
    final bool? result = await context.push<bool>(AppRoutes.reminderCreate);
    if (result == true) {
      _viewModel.handleIntent(LoadRemindersIntent());
    }
  }

  void _navigateToEditForm(Reminder reminder) async {
    final bool? result = await context.push<bool>(
      AppRoutes.reminderCreate,
      extra: reminder,
    );
    if (result == true) {
      _viewModel.handleIntent(LoadRemindersIntent());
    }
  }

  void _showDeleteConfirmation(Reminder reminder) async {
    final bool? confirmed = await showConfirmationDialog(
      context: context,
      title: 'Excluir Lembrete',
      content: 'Tem certeza que deseja excluir "${reminder.title}"?',
      confirmText: 'Excluir',
    );
    if (confirmed == true) {
      _viewModel.handleIntent(DeleteReminderIntent(reminder.id));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lembrete excluído'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco puro
      appBar: AppBar(
        title: const Text(
          'Lembretes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: theme.primaryColor, // Usa a cor primária do seu app
        foregroundColor: Colors.white,
        elevation: 2,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar por título ou conteúdo...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _viewModel.handleIntent(SearchRemindersIntent(''));
                  },
                )
                    : null,
              ),
              onChanged: (query) => _viewModel.handleIntent(SearchRemindersIntent(query)),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text(state.message, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            );
          }
          if (state is ReminderListLoaded) {
            if (state.reminders.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 6,
        child: const Icon(Icons.add_alarm, size: 28),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_alt_outlined, size: 90, color: Colors.grey[400]),
          const SizedBox(height: 24),
          const Text(
            'Nenhum lembrete cadastrado',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            'Clique no botão + para adicionar',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

// === CARD LIMPO E PROFISSIONAL (SEM SWIPE) ===
class _ReminderCard extends StatefulWidget {
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
  State<_ReminderCard> createState() => __ReminderCardState();
}

class __ReminderCardState extends State<_ReminderCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.reminder.isCompleted;
    final theme = Theme.of(context);

    return ScaleTransition(
      scale: _scale,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: isCompleted ? Colors.grey[100] : Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            _controller.forward().then((_) => _controller.reverse());
            widget.onToggle();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                GestureDetector(
                  onTap: widget.onToggle,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? theme.primaryColor : Colors.transparent,
                      border: Border.all(
                        color: isCompleted ? theme.primaryColor : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.reminder.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? Colors.grey[600] : Colors.black87,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.reminder.content,
                        style: TextStyle(
                          color: isCompleted ? Colors.grey[500] : Colors.black54,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 14, color: theme.primaryColor),
                          const SizedBox(width: 4),
                          Text(
                            widget.reminder.createdBy,
                            style: TextStyle(fontSize: 12, color: theme.primaryColor),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.schedule, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd/MM/yyyy', 'pt_BR').format(widget.reminder.createdAt),
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Ações (sem swipe)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      tooltip: 'Editar',
                      onPressed: widget.onEdit,
                    ),
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