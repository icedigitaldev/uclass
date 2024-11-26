import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Crear un nuevo profesor
  Future<void> createTeacher({
    required String nombre,
    required String email,
    required String dni,
    required String password,
    required String curso,
  }) async {
    try {
      await _firestore.collection('users').add({
        'nombre': nombre,
        'email': email,
        'dni': dni,
        'password': password,
        'rol': 'profesor',
        'curso': curso,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al registrar profesor: $e');
    }
  }

  // Obtener profesores por curso
  Future<QuerySnapshot> getTeachersByCourse(String courseName) async {
    try {
      return await _firestore
          .collection('users')
          .where('rol', isEqualTo: 'profesor')
          .where('curso', isEqualTo: courseName)
          .get();
    } catch (e) {
      throw Exception('Error al obtener profesores: $e');
    }
  }

  // Obtener datos del profesor autenticado
  Future<Map<String, dynamic>?> getCurrentTeacherData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return doc.data();
        }
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener datos del profesor: $e');
    }
  }
}