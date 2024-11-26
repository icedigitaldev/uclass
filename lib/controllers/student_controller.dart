import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/student_service.dart';

class StudentController {
  final StudentService _studentService = StudentService();

  // Crear un nuevo estudiante
  Future<void> createStudent({
    required String fullName,
    required String studentId,
    required String internshipLocation,
    required String designatedArea,
    required String courseName,
  }) async {
    try {
      await _studentService.createStudent(
        fullName: fullName,
        studentId: studentId,
        internshipLocation: internshipLocation,
        designatedArea: designatedArea,
        courseName: courseName,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Obtener estudiantes del profesor
  Stream<QuerySnapshot> getTeacherStudents() {
    return _studentService.getTeacherStudents();
  }

  // Obtener estudiantes por curso
  Stream<QuerySnapshot> getStudentsByCourse(String courseName) {
    return _studentService.getStudentsByCourse(courseName);
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
      await _studentService.updateStudent(
        studentId: studentId,
        fullName: fullName,
        internshipLocation: internshipLocation,
        designatedArea: designatedArea,
        courseName: courseName,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Eliminar estudiante
  Future<void> deleteStudent(String studentId) async {
    try {
      await _studentService.deleteStudent(studentId);
    } catch (e) {
      rethrow;
    }
  }
}