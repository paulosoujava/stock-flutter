import 'package:hive/hive.dart';
import 'package:stock/domain/entities/reminder/reminder.dart';
import 'package:stock/domain/repositories/ireminder_repository.dart';
import 'package:uuid/uuid.dart';

const String _kRemindersBox = 'remindersBox';

class ReminderRepositoryImpl implements IReminderRepository {
  Future<Box<Reminder>> _openBox() async {
    return Hive.openBox<Reminder>(_kRemindersBox);
  }

  @override
  Future<void> addReminder(Reminder reminder) async {
    final box = await _openBox();
    final newReminder = reminder.copyWith(id: const Uuid().v4());
    await box.put(newReminder.id, newReminder);
  }

  @override
  Future<void> deleteReminder(String reminderId) async {
    final box = await _openBox();
    await box.delete(reminderId);
  }

  @override
  Future<List<Reminder>> getReminders() async {
    final box = await _openBox();
    final reminders = box.values.toList();
    // Ordena para que os não concluídos apareçam primeiro
    reminders.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return b.createdAt.compareTo(a.createdAt); // Mais recentes primeiro
    });
    return reminders;
  }

  @override
  Future<void> updateReminder(Reminder reminder) async {
    final box = await _openBox();
    await box.put(reminder.id, reminder);
  }
}
