import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/logger.dart';

class GradesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveGrade({
    required String teacherId,
    required String studentId,
    required Map<String, dynamic> grades,
  }) async {
    try {
      await _firestore.collection('grades').add({
        'teacherId': teacherId,
        'studentId': studentId,
        'grades': grades,
        'createdAt': FieldValue.serverTimestamp(),
      });

      AppLogger.log(
          'Calificación guardada - Estudiante: $studentId',
          prefix: 'GRADES:'
      );
    } catch (e) {
      AppLogger.log(
          'Error al guardar calificación: $e',
          prefix: 'ERROR:'
      );
      rethrow;
    }
  }

  Stream<QuerySnapshot> getStudentGrades(String studentId) {
    return _firestore
        .collection('grades')
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getTeacherGrades(String teacherId) {
    return _firestore
        .collection('grades')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}