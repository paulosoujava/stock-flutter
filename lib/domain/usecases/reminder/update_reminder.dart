import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/reminder/reminder.dart';
import 'package:stock/domain/repositories/ireminder_repository.dart';

@injectable
class UpdateReminder {
  final IReminderRepository _repository;
  UpdateReminder(this._repository);

  Future<void> call(Reminder reminder) => _repository.updateReminder(reminder);
}
