// lib/presentation/pages/login/login_intent.dart
abstract class LoginIntent {}

class SignInWithEmailAndPasswordIntent extends LoginIntent {
  final String email;
  final String password;

  SignInWithEmailAndPasswordIntent({required this.email, required this.password});
}
