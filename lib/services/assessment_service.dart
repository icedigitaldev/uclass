import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/logger.dart';

class AssessmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveAssessmentScores({
    required String studentId,
    required String aspectName,
    required Map<int, int> scores,
  }) async {
    try {
      final QuerySnapshot studentQuery = await _firestore
          .collection('students')
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();

      if (studentQuery.docs.isEmpty) {
        throw Exception('Estudiante no encontrado');
      }

      final DocumentReference studentRef = studentQuery.docs.first.reference;
      final int totalScore = scores.values.reduce((sum, score) => sum + score);

      final now = DateTime.now();
      final String dateOnly = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final String scoreKey = aspectName.toLowerCase().replaceAll(' ', '_');

      final DocumentSnapshot doc = await studentRef.get();
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      final Map<String, dynamic> existingScores = data['scores'] ?? {};
      final int nextIndex = existingScores.length;

      await studentRef.set({
        'scores': {
          '$nextIndex': {
            'date': dateOnly,
            scoreKey: totalScore
          }
        }
      }, SetOptions(merge: true));

      AppLogger.log(
          'Calificación guardada con índice: $nextIndex',
          prefix: 'ASSESSMENT_SERVICE:'
      );
    } catch (e) {
      AppLogger.log(
          'Error al guardar calificación: $e',
          prefix: 'ERROR:'
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPdfData({String? teacherId}) async {
    try {
      final String effectiveTeacherId = teacherId ?? _auth.currentUser!.uid;

      final DocumentSnapshot teacherDoc = await _firestore
          .collection('users')
          .doc(effectiveTeacherId)
          .get();

      if (!teacherDoc.exists) {
        throw Exception('Docente no encontrado');
      }

      final teacherData = teacherDoc.data() as Map<String, dynamic>;

      final QuerySnapshot studentsSnapshot = await _firestore
          .collection('students')
          .where('teacherId', isEqualTo: effectiveTeacherId)
          .get();

      final List<Map<String, dynamic>> studentsList = studentsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      AppLogger.log(
          'Datos obtenidos para ${studentsList.length} estudiantes',
          prefix: 'ASSESSMENT_SERVICE:'
      );

      return {
        'teacher': teacherData,
        'students': studentsList,
      };
    } catch (e) {
      AppLogger.log(
          'Error obteniendo datos para PDF: $e',
          prefix: 'ERROR:'
      );
      rethrow;
    }
  }
}