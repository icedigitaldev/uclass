import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class AuthController {
  static final AuthController _instance = AuthController._internal();
  factory AuthController() => _instance;
  AuthController._internal();

  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

        // Si existe documento y es profesor, va a student_list
        // Si no existe documento o no es profesor (admin), va a home
        if (userDoc.exists && userDoc.data()?['rol'] == 'profesor') {
          Navigator.pushReplacementNamed(context, '/student_list');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      print('Error en signIn: $e');
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

        // Misma lógica: si es profesor va a student_list, sino a home
        if (userDoc.exists && userDoc.data()?['rol'] == 'profesor') {
          Navigator.pushReplacementNamed(context, '/student_list');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
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