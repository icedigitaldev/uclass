import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _studentsCollection => _firestore.collection('students');
  String get _currentTeacherId => _auth.currentUser?.uid ?? '';

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

  Stream<List<Map<String, dynamic>>> getTeacherStudents() {
    try {
      return _studentsCollection
          .where('teacherId', isEqualTo: _currentTeacherId)
          .orderBy('fullName')
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => {
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      })
          .toList());
    } catch (e) {
      throw 'Error al obtener los estudiantes: $e';
    }
  }

  Stream<List<Map<String, dynamic>>> getStudentsByCourse(String courseName) {
    try {
      return _studentsCollection
          .where('teacherId', isEqualTo: _currentTeacherId)
          .where('courseName', isEqualTo: courseName)
          .orderBy('fullName')
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => {
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      })
          .toList());
    } catch (e) {
      throw 'Error al obtener los estudiantes del curso: $e';
    }
  }

  Stream<List<Map<String, dynamic>>> getStudentsByTeacherId(String teacherId) {
    try {
      return _studentsCollection
          .where('teacherId', isEqualTo: teacherId)
          .orderBy('fullName')
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => {
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      })
          .toList());
    } catch (e) {
      throw 'Error al obtener los estudiantes del profesor: $e';
    }
  }

  Future<void> updateStudent({
    required String studentId,
    String? fullName,
    String? studentIdUpdate,
    String? internshipLocation,
    String? designatedArea,
    String? courseName,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};

      if (fullName != null) updateData['fullName'] = fullName;
      if (studentIdUpdate != null) updateData['studentId'] = studentIdUpdate;
      if (internshipLocation != null) {
        updateData['internshipLocation'] = internshipLocation;
      }
      if (designatedArea != null) updateData['designatedArea'] = designatedArea;
      if (courseName != null) updateData['courseName'] = courseName;

      await _studentsCollection.doc(studentId).update(updateData);
    } catch (e) {
      throw 'Error al actualizar el estudiante: $e';
    }
  }

  Future<void> deleteStudent(String studentId) async {
    try {
      await _studentsCollection.doc(studentId).delete();
    } catch (e) {
      throw 'Error al eliminar el estudiante: $e';
    }
  }

  Future<void> deleteAllStudents() async {
    try {
      final QuerySnapshot studentsSnapshot = await _studentsCollection
          .where('teacherId', isEqualTo: _currentTeacherId)
          .get();

      final batch = _firestore.batch();
      for (var doc in studentsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw 'Error al eliminar todos los estudiantes: $e';
    }
  }
}