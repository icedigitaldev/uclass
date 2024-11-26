import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/teacher_service.dart';

class TeacherController {
  final TeacherService _teacherService = TeacherService();

  // Registrar nuevo profesor
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

  // Obtener profesores por curso
  Future<List<Map<String, dynamic>>> getTeachersByCourse(String courseName) async {
    try {
      final QuerySnapshot querySnapshot = await _teacherService.getTeachersByCourse(courseName);

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['nombre'],
          'email': data['email'],
          'dni': data['dni'],
          'password': data['password'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener profesores: $e');
    }
  }

  // Obtener datos del profesor autenticado
  Future<Map<String, dynamic>?> getCurrentTeacher() async {
    try {
      final teacherData = await _teacherService.getCurrentTeacherData();
      return teacherData;
    } catch (e) {
      throw Exception('Error al obtener datos del profesor: $e');
    }
  }
}