import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';
import '../widgets/home/course_card.dart';
import '../widgets/home/home_header.dart';
import '../dialogs/logout_confirmation_dialog.dart';
import '../controllers/auth_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false, // Evita que el teclado afecte el layout
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveUtils.isDesktop(context) ? 1200 : double.infinity,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildCoursesSection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return HomeHeader(
      onLogoutPressed: () => _showLogoutConfirmationDialog(context),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LogoutConfirmationDialog(
          onConfirm: () {
            AuthController().signOut(context);
          },
        );
      },
    );
  }

  Widget _buildCoursesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Cursos',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: ResponsiveUtils.getCoursesGridCrossAxisCount(context),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildCourseCard(context, 'Psicología', Icons.psychology, Colors.blue),
            _buildCourseCard(context, 'Enfermería Comunitaria', Icons.local_hospital, Colors.green),
            _buildCourseCard(context, 'Enfermería Hospitalaria', Icons.medical_services, Colors.orange),
          ],
        ),
      ],
    );
  }

  Widget _buildCourseCard(BuildContext context, String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/course_details',
          arguments: title,
        );
      },
      child: CourseCard(
        title: title,
        icon: icon,
        color: color,
      ),
    );
  }
}