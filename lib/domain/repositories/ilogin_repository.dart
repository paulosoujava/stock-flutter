
abstract class ILoginRepository {
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,  });
  Future<void> signOut();
}
