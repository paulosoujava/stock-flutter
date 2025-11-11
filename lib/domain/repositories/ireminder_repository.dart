import 'package:stock/domain/entities/reminder/reminder.dart';

abstract class IReminderRepository {
  Future<List<Reminder>> getReminders();
  Future<void> addReminder(Reminder reminder);
  Future<void> updateReminder(Reminder reminder);
  Future<void> deleteReminder(String reminderId);
}
