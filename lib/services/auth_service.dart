import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/logger.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<DocumentSnapshot?> getUserData(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data() as Map<String, dynamic>;

        // Verificar si el usuario es profesor y está desactivado
        if (userData['rol'] == 'profesor' && userData['isActive'] == false) {
          AppLogger.log('Intento de acceso de profesor desactivado: $email', prefix: 'AUTH:');
          throw 'Tu cuenta ha sido desactivada. Contacta al administrador.';
        }

        if (userData['password'] == password) {
          try {
            return await _auth.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
          } catch (authError) {
            AppLogger.log('Creando usuario en Auth: $email', prefix: 'AUTH:');
            final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );

            final batch = _firestore.batch();
            final newUserRef = _firestore.collection('users').doc(userCredential.user!.uid);
            batch.set(newUserRef, {
              ...userData,
              'updatedAt': FieldValue.serverTimestamp(),
            });

            if (querySnapshot.docs.first.id != userCredential.user!.uid) {
              batch.delete(querySnapshot.docs.first.reference);
            }

            await batch.commit();
            return userCredential;
          }
        } else {
          throw 'Contraseña incorrecta';
        }
      } else {
        try {
          return await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } catch (e) {
          throw 'Usuario no encontrado';
        }
      }
    } catch (e) {
      AppLogger.log('Error en autenticación: $e', prefix: 'AUTH_ERROR:');
      if (e is String) {
        throw e;
      } else if (e is FirebaseAuthException) {
        throw _handleFirebaseAuthException(e);
      } else {
        throw 'Error en el proceso de autenticación';
      }
    }
  }

  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo electrónico';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'El correo electrónico no es válido';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Por favor, intente más tarde';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}