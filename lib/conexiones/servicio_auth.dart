import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream para saber si hay usuario logueado
  static Stream<User?> get usuarioStream => _auth.authStateChanges();

  // Usuario actual
  static User? get usuario => _auth.currentUser;

  // Login con email y contraseña
  static Future<User?> loginEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  // Registro con email y contraseña
  static Future<User?> registrarEmail(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  // Login con Google
  static Future<User?> loginConGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null; // usuario canceló

    final googleAuth = await googleUser.authentication;

    final cred = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await _auth.signInWithCredential(cred);
    return result.user;
  }

  // Logout
  static Future<void> logout() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}
