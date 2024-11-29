import '../services/assessment_service.dart';
import '../utils/logger.dart';

class AssessmentController {
  final AssessmentService _assessmentService = AssessmentService();

  Future<void> saveStudentAssessment({
    required String studentId,
    required String aspectName,
    required Map<int, int> scores,
  }) async {
    try {
      await _assessmentService.saveAssessmentScores(
        studentId: studentId,
        aspectName: aspectName,
        scores: scores,
      );

      AppLogger.log(
          'Calificación guardada exitosamente',
          prefix: 'ASSESSMENT_CONTROLLER:'
      );
    } catch (e) {
      AppLogger.log(
          'Error en el controlador: $e',
          prefix: 'ERROR:'
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPdfData({String? teacherId}) async {
    try {
      final data = await _assessmentService.getPdfData(teacherId: teacherId);

      AppLogger.log(
          'Datos para PDF obtenidos exitosamente',
          prefix: 'ASSESSMENT_CONTROLLER:'
      );

      return data;
    } catch (e) {
      AppLogger.log(
          'Error obteniendo datos para PDF: $e',
          prefix: 'ERROR:'
      );
      rethrow;
    }
  }
}