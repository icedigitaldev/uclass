import 'package:flutter/material.dart';
import '../services/teacher_service.dart';

class TeacherController {
  final TeacherService _teacherService = TeacherService();

  Future<void> registerTeacher({
    required String nombre,
    required String email,
    required String dni,
    required String password,
    required String curso,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    try {
      await _teacherService.createTeacher(
        nombre: nombre,
        email: email,
        dni: dni,
        password: password,
        curso: curso,
      );
      onSuccess();
    } catch (e) {
      onError('Error al registrar profesor: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getTeachersByCourse(String courseName) async {
    try {
      return await _teacherService.getTeachersByCourse(courseName);
    } catch (e) {
      throw Exception('Error al obtener profesores: $e');
    }
  }

  Future<Map<String, dynamic>?> getCurrentTeacher() async {
    try {
      final teacherData = await _teacherService.getCurrentTeacherData();
      return teacherData;
    } catch (e) {
      throw Exception('Error al obtener datos del profesor: $e');
    }
  }
}