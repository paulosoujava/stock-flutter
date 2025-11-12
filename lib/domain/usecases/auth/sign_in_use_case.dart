// lib/domain/usecases/auth/sign_in_use_case.dart
import 'package:injectable/injectable.dart';
import 'package:stock/domain/repositories/ilogin_repository.dart';

@injectable
class SignInUseCase {
  final ILoginRepository _repository;

  SignInUseCase(this._repository);

  Future<void> call({required String email, required String password}) {
    return _repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
