import 'package:flutter/material.dart';
import '../../utils/logger.dart';

class TeacherCard extends StatelessWidget {
  final Map<String, dynamic> teacher;
  final String courseName;
  final Map<String, bool> passwordVisibility;
  final Function(String, bool) onPasswordVisibilityChanged;
  final Function(String) onEdit;
  final Function(String, bool) onToggleStatus;

  const TeacherCard({
    Key? key,
    required this.teacher,
    required this.courseName,
    required this.passwordVisibility,
    required this.onPasswordVisibilityChanged,
    required this.onEdit,
    required this.onToggleStatus,
  }) : super(key: key);

  final Map<String, Color> courseColors = const {
    'Psicología': Colors.blue,
    'Enfermería Comunitaria': Colors.green,
    'Enfermería Hospitalaria': Colors.orange,
  };

  Widget _buildInfoRow(IconData icon, String label, String value, Color courseColor) {
    return Row(
      children: [
        Icon(icon, size: 20, color: courseColor),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 16),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRow(String password, Color courseColor) {
    String hiddenPassword = '*' * password.length;

    return Row(
      children: [
        Icon(Icons.lock, size: 20, color: courseColor),
        const SizedBox(width: 8),
        const Text(
          'Contraseña: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          passwordVisibility[password] == true ? password : hiddenPassword,
          style: const TextStyle(fontSize: 16),
        ),
        IconButton(
          icon: Icon(
            passwordVisibility[password] == true
                ? Icons.visibility_off
                : Icons.visibility,
            size: 20,
            color: courseColor,
          ),
          onPressed: () {
            AppLogger.log(
              'Cambiando visibilidad de contraseña',
              prefix: 'TEACHER_CARD:',
            );
            onPasswordVisibilityChanged(
              password,
              !(passwordVisibility[password] ?? false),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(Color courseColor) {
    // Usamos el valor directamente de Firebase sin valor por defecto
    final bool isActive = teacher['isActive'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.edit,
            color: courseColor,
            size: 28,
          ),
          onPressed: () {
            AppLogger.log(
              'Editando profesor: ${teacher['name']}',
              prefix: 'TEACHER_CARD:',
            );
            onEdit(teacher['id']);
          },
          tooltip: 'Editar',
        ),
        Transform.scale(
          scale: 1.5,
          child: Switch(
            value: isActive,
            onChanged: (bool value) {
              AppLogger.log(
                'Cambiando estado a: ${value ? "activo" : "inactivo"}',
                prefix: 'TEACHER_CARD:',
              );
              onToggleStatus(teacher['id'], value);
            },
            activeColor: courseColor,
            activeTrackColor: courseColor.withOpacity(0.5),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color courseColor = courseColors[courseName] ?? Colors.blue;

    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth = constraints.maxWidth;
        if (constraints.maxWidth > 1200) {
          cardWidth = (constraints.maxWidth - 32) / 3;
        } else if (constraints.maxWidth > 800) {
          cardWidth = (constraints.maxWidth - 16) / 2;
        }

        return GestureDetector(
          onTap: () {
            AppLogger.log(
              'Navegando a lista de estudiantes: ${teacher['name']}',
              prefix: 'TEACHER_CARD:',
            );
            Navigator.pushNamed(
              context,
              '/student_list',
              arguments: {
                'teacherId': teacher['id'],
                'teacherName': teacher['name'],
                'course': courseName,
              },
            );
          },
          child: Container(
            width: cardWidth,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: courseColor.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: courseColor,
                            child: Text(
                              teacher['name'].substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  teacher['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  teacher['email'],
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(Icons.credit_card, 'DNI', teacher['dni'], courseColor),
                      const SizedBox(height: 8),
                      _buildPasswordRow(teacher['password'], courseColor),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _buildActionButtons(courseColor),
              ],
            ),
          ),
        );
      },
    );
  }
}