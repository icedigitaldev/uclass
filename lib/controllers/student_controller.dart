import '../services/student_service.dart';

class StudentController {
  final StudentService _studentService = StudentService();

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

  Stream<List<Map<String, dynamic>>> getTeacherStudents() {
    return _studentService.getTeacherStudents();
  }

  Stream<List<Map<String, dynamic>>> getStudentsByCourse(String courseName) {
    return _studentService.getStudentsByCourse(courseName);
  }

  Stream<List<Map<String, dynamic>>> getStudentsByTeacherId(String teacherId) {
    return _studentService.getStudentsByTeacherId(teacherId);
  }

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

  Future<void> deleteStudent(String studentId) async {
    try {
      await _studentService.deleteStudent(studentId);
    } catch (e) {
      rethrow;
    }
  }
}