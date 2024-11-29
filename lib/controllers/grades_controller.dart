import '../services/grades_service.dart';
import '../utils/logger.dart';

class GradesController {
  final GradesService _gradesService = GradesService();

  Future<void> saveStudentGrades({
    required String teacherId,
    required String studentId,
    required Map<String, dynamic> grades,
  }) async {
    try {
      await _gradesService.saveGrade(
        teacherId: teacherId,
        studentId: studentId,
        grades: grades,
      );
    } catch (e) {
      AppLogger.log(
          'Error en el controlador al guardar calificación: $e',
          prefix: 'ERROR:'
      );
      rethrow;
    }
  }
}