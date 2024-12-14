import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/logger.dart';

class AuthController {
  static final AuthController _instance = AuthController._internal();
  factory AuthController() => _instance;
  AuthController._internal();

  final AuthService _authService = AuthService();

  Stream<bool> handleAuthState() {
    return _authService.authStateChanges.map((user) => user != null);
  }

  Future<void> handleUserRedirection(String uid, BuildContext context) async {
    try {
      final userDoc = await _authService.getUserData(uid);

      if (!userDoc.exists) {
        AppLogger.log('Login exitoso de administrador', prefix: 'AUTH:');
        _navigateToHome(context);
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      if (userData['rol'] == 'profesor') {
        if (userData['isActive'] == false) {
          await _authService.signOut();
          throw 'Tu cuenta ha sido desactivada. Contacta al administrador.';
        }
        _navigateToStudentList(context);
        return;
      }

      _navigateToHome(context);
    } catch (e) {
      AppLogger.log('Error al obtener datos de usuario: $e', prefix: 'AUTH_ERROR:');
      throw 'Error al obtener datos de usuario';
    }
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
        await handleUserRedirection(userCredential.user!.uid, context);
      }
    } catch (e) {
      AppLogger.log('Error en signIn: $e', prefix: 'AUTH_ERROR:');
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> checkAuthStateAndRedirect(BuildContext context) async {
    if (_authService.isAuthenticated && _authService.currentUser != null) {
      try {
        await handleUserRedirection(_authService.currentUser!.uid, context);
      } catch (e) {
        AppLogger.log('Error en checkAuthState: $e', prefix: 'AUTH_ERROR:');
        await signOut(context);
      }
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _authService.signOut();
      _navigateToLogin(context);
    } catch (e) {
      AppLogger.log('Error en signOut: $e', prefix: 'AUTH_ERROR:');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _navigateToStudentList(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/student_list');
  }
}