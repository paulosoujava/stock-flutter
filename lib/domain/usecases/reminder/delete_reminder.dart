import 'package:injectable/injectable.dart';
import 'package:stock/domain/repositories/ireminder_repository.dart';

@injectable
class DeleteReminder {
  final IReminderRepository _repository;
  DeleteReminder(this._repository);

  Future<void> call(String reminderId) => _repository.deleteReminder(reminderId);
}
