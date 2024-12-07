import 'package:flutter/material.dart';
import '../services/teacher_service.dart';
import '../utils/logger.dart';

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
      AppLogger.log('Registrando profesor: $nombre', prefix: 'TEACHER_CONTROLLER:');
      await _teacherService.createTeacher(
        nombre: nombre,
        email: email,
        dni: dni,
        password: password,
        curso: curso,
      );
      AppLogger.log('Profesor registrado exitosamente', prefix: 'TEACHER_CONTROLLER:');
      onSuccess();
    } catch (e) {
      AppLogger.log('Error al registrar profesor: $e', prefix: 'TEACHER_CONTROLLER:');
      onError('Error al registrar profesor: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getTeachersByCourse(String courseName) async {
    try {
      AppLogger.log('Obteniendo profesores del curso: $courseName', prefix: 'TEACHER_CONTROLLER:');
      final teachers = await _teacherService.getTeachersByCourse(courseName);
      AppLogger.log('Profesores obtenidos: ${teachers.length}', prefix: 'TEACHER_CONTROLLER:');
      return teachers;
    } catch (e) {
      AppLogger.log('Error al obtener profesores: $e', prefix: 'TEACHER_CONTROLLER:');
      throw Exception('Error al obtener profesores: $e');
    }
  }

  Future<Map<String, dynamic>?> getCurrentTeacher() async {
    try {
      AppLogger.log('Obteniendo datos del profesor actual', prefix: 'TEACHER_CONTROLLER:');
      final teacherData = await _teacherService.getCurrentTeacherData();
      if (teacherData != null) {
        AppLogger.log('Datos del profesor obtenidos exitosamente', prefix: 'TEACHER_CONTROLLER:');
      } else {
        AppLogger.log('No se encontraron datos del profesor', prefix: 'TEACHER_CONTROLLER:');
      }
      return teacherData;
    } catch (e) {
      AppLogger.log('Error al obtener datos del profesor: $e', prefix: 'TEACHER_CONTROLLER:');
      throw Exception('Error al obtener datos del profesor: $e');
    }
  }

  Future<void> updateTeacherStatus({
    required String teacherId,
    required bool isActive,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    try {
      AppLogger.log(
        'Actualizando estado del profesor $teacherId a: ${isActive ? "activo" : "inactivo"}',
        prefix: 'TEACHER_CONTROLLER:',
      );
      await _teacherService.updateTeacherStatus(teacherId, isActive);
      AppLogger.log('Estado del profesor actualizado exitosamente', prefix: 'TEACHER_CONTROLLER:');
      onSuccess();
    } catch (e) {
      AppLogger.log('Error al actualizar estado del profesor: $e', prefix: 'TEACHER_CONTROLLER:');
      onError('Error al actualizar estado del profesor: ${e.toString()}');
    }
  }

  Future<void> updateTeacher({
    required String teacherId,
    required String nombre,
    required String email,
    required String dni,
    required String password,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    try {
      AppLogger.log('Actualizando profesor: $teacherId', prefix: 'TEACHER_CONTROLLER:');
      await _teacherService.updateTeacher(
        teacherId: teacherId,
        nombre: nombre,
        email: email,
        dni: dni,
        password: password,
      );
      AppLogger.log('Profesor actualizado exitosamente', prefix: 'TEACHER_CONTROLLER:');
      onSuccess();
    } catch (e) {
      AppLogger.log('Error al actualizar profesor: $e', prefix: 'TEACHER_CONTROLLER:');
      onError('Error al actualizar profesor: ${e.toString()}');
    }
  }
}