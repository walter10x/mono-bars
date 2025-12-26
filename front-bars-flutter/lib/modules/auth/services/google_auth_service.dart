import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Servicio para autenticación con Google usando Firebase
/// 
/// VENTAJAS DE FIREBASE AUTH:
/// - Cualquier usuario puede usar Google Sign-In
/// - No necesitas añadir usuarios de prueba manualmente
/// - Gestión automática de tokens
class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Inicia el flujo de login con Google
  /// Retorna el ID Token de Firebase si es exitoso, null si el usuario cancela
  Future<String?> signIn() async {
    try {
      // 1. Iniciar login con Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // Usuario canceló el login
        print('❌ Usuario canceló el login de Google');
        return null;
      }

      // 2. Obtener credenciales de autenticación de Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Crear credencial de Firebase con los tokens de Google
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Autenticar en Firebase con la credencial
      final UserCredential userCredential = 
          await _firebaseAuth.signInWithCredential(credential);

      // 5. Obtener el ID Token de Firebase para enviar al backend
      final idToken = await userCredential.user?.getIdToken();

      print('✅ Login con Google exitoso');
      print('📧 Email: ${userCredential.user?.email}');
      print('👤 Nombre: ${userCredential.user?.displayName}');

      return idToken;
    } catch (e) {
      print('❌ Error en Google Sign-In: $e');
      return null;
    }
  }

  /// Cierra sesión de Google y Firebase
  Future<void> signOut() async {
    await Future.wait([
      _googleSignIn.signOut(),
      _firebaseAuth.signOut(),
    ]);
  }

  /// Verifica si hay usuario logueado
  bool get isSignedIn => _firebaseAuth.currentUser != null;

  /// Obtiene el usuario actual de Firebase
  User? get currentUser => _firebaseAuth.currentUser;
}

/// Provider para GoogleAuthService
final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService();
});
