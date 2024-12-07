import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
        'isActive': true, // Agregamos isActive por defecto
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al registrar profesor: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTeachersByCourse(String courseName) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('rol', isEqualTo: 'profesor')
          .where('curso', isEqualTo: courseName)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['nombre'],
          'email': data['email'],
          'dni': data['dni'],
          'password': data['password'],
          'isActive': data['isActive'] ?? true, // Incluimos isActive en el mapeo
        };
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener profesores: $e');
    }
  }

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

  Future<void> updateTeacherStatus(String teacherId, bool isActive) async {
    try {
      await _firestore.collection('users').doc(teacherId).update({
        'isActive': isActive,
      });
    } catch (e) {
      throw Exception('Error al actualizar estado del profesor: $e');
    }
  }

  Future<void> updateTeacher({
    required String teacherId,
    required String nombre,
    required String email,
    required String dni,
    required String password,
  }) async {
    try {
      await _firestore.collection('users').doc(teacherId).update({
        'nombre': nombre,
        'email': email,
        'dni': dni,
        'password': password,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al actualizar profesor: $e');
    }
  }
}