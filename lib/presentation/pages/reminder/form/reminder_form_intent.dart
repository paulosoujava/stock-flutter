import 'package:stock/domain/entities/reminder/reminder.dart';

abstract class ReminderFormIntent {}class SaveReminderIntent extends ReminderFormIntent {
  final Reminder reminder;
  SaveReminderIntent(this.reminder);
}
