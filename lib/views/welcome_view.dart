import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/logger.dart';
import '../utils/responsive_utils.dart';
import '../widgets/custom_app_bar.dart';

class WelcomeView extends StatelessWidget {
  final bool showContinueButton;

  const WelcomeView({
    super.key,
    this.showContinueButton = true
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Image.asset(
                  'assets/images/hacker.png',
                  height: 200,
                ),
                const SizedBox(height: 48),
                const Text(
                  '¡Bienvenido!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Comienza tu viaje con nosotros',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                if (showContinueButton)
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: ResponsiveUtils.getFixedBottomSheetMaxWidth(),
                      ),
                      child: _buildButton(
                        text: 'Continuar',
                        onPressed: () {
                          AppLogger.log('Navegando a LoginView', prefix: 'WELCOME:');
                          Navigator.pushNamed(context, '/login');
                        },
                      ),
                    ),
                  )
                else
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}