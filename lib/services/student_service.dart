import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _studentsCollection => _firestore.collection('students');
  String get _currentTeacherId => _auth.currentUser?.uid ?? '';

  // Crear un nuevo estudiante
  Future<void> createStudent({
    required String fullName,
    required String studentId,
    required String internshipLocation,
    required String designatedArea,
    required String courseName,
  }) async {
    try {
      if (_currentTeacherId.isEmpty) {
        throw 'No hay un profesor autenticado';
      }

      await _studentsCollection.add({
        'fullName': fullName.trim(),
        'studentId': studentId.trim(),
        'internshipLocation': internshipLocation.trim(),
        'designatedArea': designatedArea.trim(),
        'courseName': courseName,
        'teacherId': _currentTeacherId,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      throw 'Error al crear el estudiante: $e';
    }
  }

  // Obtener estudiantes del profesor
  Stream<QuerySnapshot> getTeacherStudents() {
    try {
      return _studentsCollection
          .where('teacherId', isEqualTo: _currentTeacherId)
          .orderBy('fullName')
          .snapshots();
    } catch (e) {
      throw 'Error al obtener los estudiantes: $e';
    }
  }

  // Obtener estudiantes por curso
  Stream<QuerySnapshot> getStudentsByCourse(String courseName) {
    try {
      return _studentsCollection
          .where('teacherId', isEqualTo: _currentTeacherId)
          .where('courseName', isEqualTo: courseName)
          .orderBy('fullName')
          .snapshots();
    } catch (e) {
      throw 'Error al obtener los estudiantes del curso: $e';
    }
  }

  // Actualizar estudiante
  Future<void> updateStudent({
    required String studentId,
    String? fullName,
    String? internshipLocation,
    String? designatedArea,
    String? courseName,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};

      if (fullName != null) updateData['fullName'] = fullName;
      if (internshipLocation != null) updateData['internshipLocation'] = internshipLocation;
      if (designatedArea != null) updateData['designatedArea'] = designatedArea;
      if (courseName != null) updateData['courseName'] = courseName;

      await _studentsCollection.doc(studentId).update(updateData);
    } catch (e) {
      throw 'Error al actualizar el estudiante: $e';
    }
  }

  // Eliminar estudiante
  Future<void> deleteStudent(String studentId) async {
    try {
      await _studentsCollection.doc(studentId).delete();
    } catch (e) {
      throw 'Error al eliminar el estudiante: $e';
    }
  }
}