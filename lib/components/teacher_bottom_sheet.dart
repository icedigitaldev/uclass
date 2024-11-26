import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';
import '../widgets/bottom_sheet/input_custom.dart';
import '../controllers/teacher_controller.dart';

class TeacherBottomSheet extends StatefulWidget {
  final String curso;

  const TeacherBottomSheet({super.key, required this.curso});

  @override
  State<TeacherBottomSheet> createState() => _TeacherBottomSheetState();
}

class _TeacherBottomSheetState extends State<TeacherBottomSheet> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dniController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TeacherController _teacherController = TeacherController();
  bool _isLoading = false;

  @override
  void dispose() {
    nombreController.dispose();
    emailController.dispose();
    dniController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
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
                const Text(
                  'Agregar Profesor',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                InputCustom.buildTextField(
                  controller: nombreController,
                  hintText: 'Nombre completo',
                  prefixIcon: Icons.person_outline,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16.0),
                InputCustom.buildTextField(
                  controller: emailController,
                  hintText: 'Correo electrónico',
                  prefixIcon: Icons.email_outlined,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16.0),
                InputCustom.buildTextField(
                  controller: dniController,
                  hintText: 'DNI',
                  prefixIcon: Icons.credit_card_outlined,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                ),
                const SizedBox(height: 16.0),
                InputCustom.buildTextField(
                  controller: passwordController,
                  hintText: 'Contraseña',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 24.0),
                InputCustom.buildButton(
                  text: 'Agregar Profesor',
                  onPressed: _isLoading ? null : () async {
                    // Validar campos
                    if (nombreController.text.isEmpty ||
                        emailController.text.isEmpty ||
                        dniController.text.isEmpty ||
                        passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor, complete todos los campos'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Validar DNI
                    if (dniController.text.length != 8) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('El DNI debe tener 8 dígitos'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Validar contraseña
                    if (passwordController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('La contraseña debe tener al menos 6 caracteres'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    setState(() => _isLoading = true);

                    await _teacherController.registerTeacher(
                      nombre: nombreController.text.trim(),
                      email: emailController.text.trim(),
                      dni: dniController.text.trim(),
                      password: passwordController.text,
                      curso: widget.curso,
                      onSuccess: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profesor registrado exitosamente'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      onError: (error) {
                        setState(() => _isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                    );
                  },
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
}