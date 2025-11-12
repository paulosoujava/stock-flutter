import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stock/domain/entities/reminder/reminder.dart';
import 'package:stock/domain/usecases/auth/get_current_user_use_case.dart';
import 'package:stock/domain/usecases/reminder/add_reminder.dart';
import 'package:stock/domain/usecases/reminder/update_reminder.dart';
import 'reminder_form_intent.dart';
import 'reminder_form_state.dart';

@injectable
class ReminderFormViewModel {
  final AddReminder _addReminder;
  final UpdateReminder _updateReminder;
  final GetCurrentUserUseCase _getCurrentUser;

  final _stateController = BehaviorSubject<ReminderFormState>();

  Stream<ReminderFormState> get state => _stateController.stream;

  ReminderFormViewModel(
    this._addReminder,
    this._updateReminder,
    this._getCurrentUser,
  );

  void handleIntent(ReminderFormIntent intent) {
    if (intent is SaveReminderIntent) {
      _saveReminder(intent.reminder);
    }
  }

  Future<void> _saveReminder(Reminder reminder) async {
    _stateController.add(ReminderFormLoading());
    final currentUser = _getCurrentUser();
    if (currentUser == null) {
      _stateController.add(ReminderFormError("Erro: Nenhum usuário autenticado. Faça login novamente."));
      return;
    }
    try {
      final reminderToSave = reminder.copyWith(
        createdBy: currentUser.displayName ?? currentUser.email ?? 'Usuário Desconhecido',
        createdAt: reminder.id.isEmpty ? DateTime.now() : reminder.createdAt,
      );

      if (reminderToSave.id.isEmpty) {
        await _addReminder(reminderToSave);
      } else {
        await _updateReminder(reminderToSave);
      }
      _stateController.add(ReminderFormSuccess());
    } catch (e) {
      _stateController.add(ReminderFormError("Erro ao salvar lembrete."));
    }
  }

  void dispose() {
    _stateController.close();
  }
}
