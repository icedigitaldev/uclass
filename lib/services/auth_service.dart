import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Primero consultar Firestore
      final QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      // Existe en Firestore (V)
      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data() as Map<String, dynamic>;

        // Verificar contraseña
        if (userData['password'] == password) {
          try {
            // Intentar iniciar sesión en Auth
            return await _auth.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
          } catch (authError) {
            // Si no existe en Auth (VF), crearlo
            print('Usuario existe en Firestore pero no en Auth, creando...');
            final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );

            // Actualizar documento en Firestore con el nuevo UID
            final batch = _firestore.batch();

            // Crear nuevo documento con UID
            final newUserRef = _firestore.collection('users').doc(userCredential.user!.uid);
            batch.set(newUserRef, {
              ...userData,
              'updatedAt': FieldValue.serverTimestamp(),
            });

            // Eliminar documento antiguo si tiene ID diferente
            if (querySnapshot.docs.first.id != userCredential.user!.uid) {
              batch.delete(querySnapshot.docs.first.reference);
            }

            await batch.commit();
            return userCredential;
          }
        } else {
          throw 'Contraseña incorrecta';
        }
      }
      // No existe en Firestore (F)
      else {
        // Intentar iniciar sesión en Auth (podría ser admin)
        try {
          return await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } catch (e) {
          // No existe en ninguno (FF)
          throw 'Usuario no encontrado';
        }
      }
    } catch (e) {
      print('Error en autenticación: $e');
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