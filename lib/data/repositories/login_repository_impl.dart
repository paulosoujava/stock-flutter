// lib/data/repositories/login_repository_impl.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:stock/domain/repositories/ilogin_repository.dart';

@LazySingleton(as: ILoginRepository)
class LoginRepositoryImpl implements ILoginRepository {
  final FirebaseAuth _firebaseAuth;

  LoginRepositoryImpl(this._firebaseAuth);

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // A lógica de try-catch foi movida para o ViewModel,
    // o repositório apenas executa a chamada ou falha.
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
