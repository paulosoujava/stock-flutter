// lib/domain/usecases/auth/sign_out_use_case.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:stock/domain/repositories/ilogin_repository.dart';

@injectable
class SignOutUseCase {
  final ILoginRepository _repository;

  SignOutUseCase(this._repository);

  Future<void> call() {
    return _repository.signOut();
  }
}
