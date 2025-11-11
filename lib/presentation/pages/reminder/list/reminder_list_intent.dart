import 'package:stock/domain/entities/reminder/reminder.dart';

abstract class ReminderListIntent {}

class LoadRemindersIntent extends ReminderListIntent {}

class SearchRemindersIntent extends ReminderListIntent {
  final String query;
  SearchRemindersIntent(this.query);
}

class ToggleReminderStatusIntent extends ReminderListIntent {
  final Reminder reminder;
  ToggleReminderStatusIntent(this.reminder);
}

class DeleteReminderIntent extends ReminderListIntent {
  final String reminderId;
  DeleteReminderIntent(this.reminderId);
}
