import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../views/welcome_view.dart';
import '../views/student_list_view.dart';
import '../views/home_view.dart';
import '../utils/logger.dart';

class AuthController {
  static final AuthController _instance = AuthController._internal();
  factory AuthController() => _instance;
  AuthController._internal();

  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<Widget> handleAuthState() {
    return _authService.authStateChanges.asyncMap((User? user) async {
      if (user == null) {
        return const WelcomeView(showContinueButton: true);
      }

      final userSnapshot = await _authService.getUserData(user.uid);

      if (userSnapshot != null && userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;

        // Verificar si el usuario es profesor y está desactivado
        if (userData['rol'] == 'profesor' && userData['isActive'] == false) {
          AppLogger.log('Profesor desactivado intentando acceder: ${user.email}', prefix: 'AUTH:');
          await _authService.signOut();
          return const WelcomeView(showContinueButton: true);
        }

        if (userData['rol'] == 'profesor' && userData['isActive'] == true) {
          return const StudentListView();
        }
      }

      return const HomeView();
    });
  }

  Future<void> signIn({
    required String email,
    required String password,
    required BuildContext context,
    required Function(bool) setLoading,
    required Function(String?) setError,
  }) async {
    try {
      setLoading(true);
      setError(null);

      final userCredential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;

          if (userData['rol'] == 'profesor' && userData['isActive'] == false) {
            await _authService.signOut();
            setError('Tu cuenta ha sido desactivada. Contacta al administrador.');
            return;
          }

          if (userData['rol'] == 'profesor' && userData['isActive'] == true) {
            Navigator.pushReplacementNamed(context, '/student_list');
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      }
    } catch (e) {
      AppLogger.log('Error en signIn: $e', prefix: 'AUTH_ERROR:');
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> checkAuthStateAndRedirect(BuildContext context) async {
    if (_authService.isAuthenticated) {
      final user = _authService.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;

          if (userData['rol'] == 'profesor' && userData['isActive'] == false) {
            await _authService.signOut();
            return;
          }

          if (userData['rol'] == 'profesor' && userData['isActive'] == true) {
            Navigator.pushReplacementNamed(context, '/student_list');
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      }
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _authService.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }
}