// lib/presentation/pages/login/login_viewmodel.dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stock/domain/usecases/auth/sign_in_use_case.dart'; // 1. IMPORTE O NOVO USECASE
import 'login_intent.dart';
import 'login_state.dart';

@injectable
class LoginViewModel {

  final SignInUseCase _signInUseCase;
  final _stateController = BehaviorSubject<LoginState>.seeded(LoginInitial());
  Stream<LoginState> get state => _stateController.stream;


  LoginViewModel(this._signInUseCase);

  void handleIntent(LoginIntent intent) {
    if (intent is SignInWithEmailAndPasswordIntent) {
      _signIn(intent.email, intent.password);
    }
  }

  Future<void> _signIn(String email, String password) async {
    _stateController.add(LoginLoading());
    try {
      await _signInUseCase(
        email: email,
        password: password,
      );
      _stateController.add(LoginSuccess());
   } on FirebaseAuthException catch (e) {
      _stateController.add(LoginError(_mapAuthErrorToMessage(e.code)));
    } catch (e, s) {
      print('ERRO NO LOGIN: $e');
      print('STACKTRACE: $s');
      _stateController.add(LoginError("Ocorreu um erro inesperado."));
    }
  }

  String _mapAuthErrorToMessage(String code) {
    print('_mapAuthErrorToMessage: $code');
    switch (code) {
      case 'invalid-email':
        return 'O formato do e-mail é inválido.';
      case 'user-disabled':
        return 'Este usuário foi desabilitado.';
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'invalid-credential':
        return 'Credenciais inválidas. Verifique seu e-mail e senha.';
      default:
        return 'Falha na autenticação. Por favor, tente novamente.';
    }
  }

  void dispose() {
    _stateController.close();
  }
}
