import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stock/domain/entities/reminder/reminder.dart';
import 'package:stock/domain/usecases/reminder/delete_reminder.dart';
import 'package:stock/domain/usecases/reminder/get_reminders.dart';
import 'package:stock/domain/usecases/reminder/update_reminder.dart';
import 'reminder_list_intent.dart';
import 'reminder_list_state.dart';

@lazySingleton
class ReminderListViewModel {
  final GetReminders _getReminders;
  final UpdateReminder _updateReminder;
  final DeleteReminder _deleteReminder;
  List<Reminder> _originalReminders = [];

  final _stateController = BehaviorSubject<ReminderListState>();
  Stream<ReminderListState> get state => _stateController.stream;

  ReminderListViewModel(
      this._getReminders,
      this._updateReminder,
      this._deleteReminder,
      ) {
    handleIntent(LoadRemindersIntent());
  }

  void handleIntent(ReminderListIntent intent) {
    switch (intent) {
      case LoadRemindersIntent():
        _loadReminders();
      case SearchRemindersIntent():
        _searchReminders(intent.query);
      case ToggleReminderStatusIntent():
        _toggleStatusAndReload(intent.reminder);
      case DeleteReminderIntent():
        _deleteAndReload(intent.reminderId);
    }
  }

  Future<void> _loadReminders() async {
    _stateController.add(ReminderListLoading());
    try {
      final reminders = await _getReminders();
      _originalReminders = reminders;
      _stateController.add(ReminderListLoaded(reminders));
    } catch (e) {
      _stateController.add(ReminderListError("Erro ao carregar lembretes."));
    }
  }

  void _searchReminders(String query) {
    if (query.isEmpty) {
      _stateController.add(ReminderListLoaded(_originalReminders));
      return;
    }
    final lowerCaseQuery = query.toLowerCase();
    final filteredList = _originalReminders.where((reminder) {
      return reminder.title.toLowerCase().contains(lowerCaseQuery) ||
          reminder.content.toLowerCase().contains(lowerCaseQuery);
    }).toList();
    _stateController.add(ReminderListLoaded(filteredList));
  }

  Future<void> _toggleStatusAndReload(Reminder reminder) async {
    try {
      final updatedReminder = reminder.copyWith(isCompleted: !reminder.isCompleted);
      await _updateReminder(updatedReminder);
      _loadReminders(); // Recarrega a lista para refletir a nova ordem
    } catch (e) {
      _stateController.add(ReminderListError("Erro ao atualizar status."));
    }
  }

  Future<void> _deleteAndReload(String reminderId) async {
    try {
      await _deleteReminder(reminderId);
      _loadReminders(); // Recarrega a lista após deletar
    } catch (e) {
      _stateController.add(ReminderListError("Erro ao deletar lembrete."));
    }
  }

  @disposeMethod
  void dispose() {
    _stateController.close();
  }
}
