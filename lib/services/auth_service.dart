import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  // Stream para escuchar cambios de sesión
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Iniciar sesión con email y contraseña reales de Firebase Auth
  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Registrar nuevo usuario
  Future<UserCredential> register(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
  }
}
