import 'package:stock/domain/entities/reminder/reminder.dart';

abstract class ReminderListState {}

class ReminderListInitial extends ReminderListState {}

class ReminderListLoading extends ReminderListState {}

class ReminderListError extends ReminderListState {
  final String message;
  ReminderListError(this.message);
}

class ReminderListLoaded extends ReminderListState {
  final List<Reminder> reminders;
  ReminderListLoaded(this.reminders);
}
