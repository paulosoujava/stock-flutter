import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
  // --- LÓGICA ORIGINAL 100% PRESERVADA ---
  late final ReminderListViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ReminderListViewModel>();
    // Carrega os dados na inicialização
    _viewModel.handleIntent(LoadRemindersIntent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
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
  // --- FIM DA LÓGICA ORIGINAL ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder<ReminderListState>(
              stream: _viewModel.state,
              builder: (context, snapshot) {
                final state = snapshot.data;
                if (state is ReminderListLoading || !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ReminderListError) {
                  return Center(
                    child: Text(state.message,
                        style: const TextStyle(color: Colors.red)),
                  );
                }
                if (state is ReminderListLoaded) {
                  if (state.reminders.isEmpty) {
                    return _buildEmptyState();
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        _viewModel.handleIntent(LoadRemindersIntent()),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: state.reminders.length,
                      itemBuilder: (context, index) {
                        final reminder = state.reminders[index];
                        return _ReminderCard(
                          key: ValueKey(reminder.id),
                          reminder: reminder,
                          onEdit: () => _navigateToEditForm(reminder),
                          onDelete: () => _showDeleteConfirmation(reminder),
                          onToggle: () => _viewModel
                              .handleIntent(ToggleReminderStatusIntent(reminder)),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
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
              offset: const Offset(0, 4)),
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
            'Lembretes',
            style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800]),
          ),
          const Spacer(),
          SizedBox(
            width: 300,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar lembrete...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                filled: true,
                contentPadding: EdgeInsets.zero,
                fillColor: Colors.grey[100],
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    // Dispara a busca com texto vazio para limpar o filtro
                    _viewModel.handleIntent(SearchRemindersIntent(''));
                  },
                )
                    : null,
              ),
              onChanged: (query) =>
                  _viewModel.handleIntent(SearchRemindersIntent(query)),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            icon: const Icon(Icons.add_alarm, size: 20),
            label: const Text("Novo Lembrete"),
            onPressed: _navigateToCreateForm,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    bool isSearching = _searchController.text.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSearching ? Icons.search_off : Icons.note_alt_outlined,
                size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              isSearching ? 'Nenhum lembrete encontrado' : 'Nenhum lembrete cadastrado',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Tente uma busca diferente.'
                  : 'Crie seu primeiro lembrete para não se esquecer de nada importante.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (!isSearching) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_alarm),
                label: const Text('Cadastrar Primeiro Lembrete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: _navigateToCreateForm,
              ),
            ]
          ],
        ),
      ),
    );
  }
}

// CARD DE LEMBRETE REDESENHADO
class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _ReminderCard({
    super.key,
    required this.reminder,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = reminder.isCompleted;
    final theme = Theme.of(context);

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: isCompleted ? Colors.green.shade200 : Colors.grey.shade200,
            width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      color: isCompleted ? Colors.green.shade50 : Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox customizado
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                  isCompleted ? theme.primaryColor : Colors.transparent,
                  border: Border.all(
                    color:
                    isCompleted ? theme.primaryColor : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),
              // Conteúdo do lembrete
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color:
                        isCompleted ? Colors.grey[600] : Colors.black87,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (reminder.content.isNotEmpty)
                      Text(
                        reminder.content,
                        style: TextStyle(
                          color:
                          isCompleted ? Colors.grey[500] : Colors.black54,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          fontSize: 15,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          reminder.createdBy,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[700]),
                        ),
                        const Spacer(),
                        Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy', 'pt_BR')
                              .format(reminder.createdAt),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Ações em Menu
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Editar'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: Colors.red),
                      title: Text('Excluir', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
                icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                tooltip: 'Mais opções',
              ),
            ],
          ),
        ),
      ),
    );
  }
}