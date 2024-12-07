import 'package:flutter/material.dart';
import '../utils/logger.dart';
import '../utils/responsive_utils.dart';
import '../controllers/student_controller.dart';

class StudentBottomSheet extends StatefulWidget {
  final String? course;
  final bool isEditing;
  final String? studentId;
  final Map<String, dynamic>? initialData;

  const StudentBottomSheet({
    super.key,
    required this.course,
    this.isEditing = false,
    this.studentId,
    this.initialData,
  });

  @override
  State<StudentBottomSheet> createState() => _StudentBottomSheetState();
}

class _StudentBottomSheetState extends State<StudentBottomSheet> {
  final StudentController _studentController = StudentController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _siteController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.initialData != null) {
      _nameController.text = widget.initialData!['fullName'] ?? '';
      _idController.text = widget.initialData!['studentId'] ?? '';
      _siteController.text = widget.initialData!['internshipLocation'] ?? '';
      _areaController.text = widget.initialData!['designatedArea'] ?? '';
    }
  }

  Future<void> _handleSubmit() async {
    if (_nameController.text.isEmpty ||
        _idController.text.isEmpty ||
        _siteController.text.isEmpty ||
        _areaController.text.isEmpty ||
        widget.course == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete todos los campos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.isEditing) {
        await _studentController.updateStudent(
          studentId: widget.studentId!,
          studentIdUpdate: _idController.text,
          fullName: _nameController.text,
          internshipLocation: _siteController.text,
          designatedArea: _areaController.text,
        );
      } else {
        await _studentController.createStudent(
          fullName: _nameController.text,
          studentId: _idController.text,
          internshipLocation: _siteController.text,
          designatedArea: _areaController.text,
          courseName: widget.course!,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing
                ? 'Estudiante actualizado exitosamente'
                : 'Estudiante agregado exitosamente'
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing
                ? 'Error al actualizar estudiante: $e'
                : 'Error al agregar estudiante: $e'
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _siteController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveUtils.getFixedBottomSheetMaxWidth(),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.isEditing ? 'Editar Alumno' : 'Agregar Alumno',
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                _buildTextField(
                  controller: _nameController,
                  hintText: 'Nombre completo',
                  prefixIcon: Icons.person_outline,
                  onChanged: (value) {
                    AppLogger.log('Nombre del alumno: $value',
                        prefix: widget.isEditing ? 'EDIT_STUDENT:' : 'ADD_STUDENT:'
                    );
                  },
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _idController,
                  hintText: 'ID Estudiante',
                  prefixIcon: Icons.school_outlined,
                  onChanged: (value) {
                    AppLogger.log('ID del estudiante: $value',
                        prefix: widget.isEditing ? 'EDIT_STUDENT:' : 'ADD_STUDENT:'
                    );
                  },
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _siteController,
                  hintText: 'Sede de Internado',
                  prefixIcon: Icons.local_hospital_outlined,
                  onChanged: (value) {
                    AppLogger.log('Sede de Internado: $value',
                        prefix: widget.isEditing ? 'EDIT_STUDENT:' : 'ADD_STUDENT:'
                    );
                  },
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _areaController,
                  hintText: 'Área Designada',
                  prefixIcon: Icons.work_outline,
                  onChanged: (value) {
                    AppLogger.log('Área Designada: $value',
                        prefix: widget.isEditing ? 'EDIT_STUDENT:' : 'ADD_STUDENT:'
                    );
                  },
                ),
                const SizedBox(height: 24.0),
                _buildButton(
                  text: widget.isEditing ? 'Actualizar Alumno' : 'Agregar Alumno',
                  onPressed: _isLoading ? null : _handleSubmit,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isLoading,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: isLoading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
          : Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}