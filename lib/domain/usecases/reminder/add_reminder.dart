import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/reminder/reminder.dart';
import 'package:stock/domain/repositories/ireminder_repository.dart';

@injectable
class AddReminder {
  final IReminderRepository _repository;
  AddReminder(this._repository);

  Future<void> call(Reminder reminder) => _repository.addReminder(reminder);
}
