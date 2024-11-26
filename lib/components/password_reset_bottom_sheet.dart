import 'package:flutter/material.dart';
import '../utils/logger.dart';
import '../utils/responsive_utils.dart';
import '../widgets/bottom_sheet/input_custom.dart';

class PasswordResetBottomSheet extends StatelessWidget {
  const PasswordResetBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                const Text(
                  'Restablecer Contraseña',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                InputCustom.buildTextField(
                  hintText: 'Correo electrónico',
                  prefixIcon: Icons.email_outlined,
                  onChanged: (value) {
                    AppLogger.log('Email para restablecimiento: $value', prefix: 'RESET:');
                  },
                ),
                const SizedBox(height: 16.0),
                InputCustom.buildTextField(
                  hintText: 'Contraseña actual',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  onChanged: (value) {
                    AppLogger.log('Contraseña actual ingresada', prefix: 'RESET:');
                  },
                ),
                const SizedBox(height: 16.0),
                InputCustom.buildTextField(
                  hintText: 'Nueva contraseña',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  onChanged: (value) {
                    AppLogger.log('Nueva contraseña ingresada', prefix: 'RESET:');
                  },
                ),
                const SizedBox(height: 24.0),
                InputCustom.buildButton(
                  text: 'Cambiar Contraseña',
                  onPressed: () {
                    AppLogger.log('Solicitud de cambio de contraseña', prefix: 'RESET:');
                    Navigator.pop(context);
                    // Implementar lógica de cambio de contraseña aquí
                  },
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