import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetCurrentUserUseCase {
final FirebaseAuth _firebaseAuth;

GetCurrentUserUseCase(this._firebaseAuth);

// O UseCase retorna o usuário atual ou null se ninguém estiver logado.
User? call() {
  return _firebaseAuth.currentUser;
}
}
