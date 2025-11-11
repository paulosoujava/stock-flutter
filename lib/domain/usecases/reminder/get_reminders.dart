import 'package:injectable/injectable.dart';
import 'package:stock/domain/entities/reminder/reminder.dart';
import 'package:stock/domain/repositories/ireminder_repository.dart';

@injectable
class GetReminders {
  final IReminderRepository _repository;
  GetReminders(this._repository);

  Future<List<Reminder>> call() => _repository.getReminders();
}
