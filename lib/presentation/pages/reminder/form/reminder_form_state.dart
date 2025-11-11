abstract class ReminderFormState {}

class ReminderFormInitial extends ReminderFormState {}

class ReminderFormLoading extends ReminderFormState {}

class ReminderFormSuccess extends ReminderFormState {}

class ReminderFormError extends ReminderFormState {
  final String message;
  ReminderFormError(this.message);
}
