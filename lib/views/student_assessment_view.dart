import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';
import '../controllers/teacher_controller.dart';

class StudentAssessmentView extends StatefulWidget {
  const StudentAssessmentView({super.key});

  @override
  State<StudentAssessmentView> createState() => _StudentAssessmentViewState();
}

class _StudentAssessmentViewState extends State<StudentAssessmentView> {
  final TeacherController _teacherController = TeacherController();
  String? teacherCourse;
  String? studentName;
  String? studentId;

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
        if (args != null) {
          setState(() {
            studentName = args['name'];
            studentId = args['studentId'];
          });
        }
      }
    });
  }

  Future<void> _loadTeacherData() async {
    final teacherData = await _teacherController.getCurrentTeacher();
    if (teacherData != null && mounted) {
      setState(() {
        teacherCourse = teacherData['curso'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (studentName == null || studentId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
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
                  _buildAssessmentSection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => Navigator.pop(context),
            constraints: const BoxConstraints(),
          ),
          const CircleAvatar(
            backgroundColor: Colors.black,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ID: $studentId',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rubros Evaluativos',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: ResponsiveUtils.getCoursesGridCrossAxisCount(context),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: _getAssessmentCards(),
        ),
      ],
    );
  }

  List<Widget> _getAssessmentCards() {
    switch (teacherCourse) {
      case 'Psicología':
        return [
          _buildAssessmentCard('Asistencia', Icons.calendar_today, Colors.blue),
          _buildAssessmentCard('Ética Profesional', Icons.policy, Colors.green),
          _buildAssessmentCard('Eficiencia', Icons.speed, Colors.orange),
          _buildAssessmentCard('Iniciativa y Responsabilidad', Icons.lightbulb, Colors.purple),
        ];
      case 'Enfermería Hospitalaria':
        return [
          _buildAssessmentCard('Aspecto Cognitivo', Icons.psychology, Colors.blue),
          _buildAssessmentCard('Aspecto Procedimental', Icons.medical_services, Colors.green),
          _buildAssessmentCard('Aspecto Actitudinal', Icons.person_outline, Colors.orange),
        ];
      case 'Enfermería Comunitaria':
        return [
          _buildAssessmentCard('Aspecto Cognitivo', Icons.psychology, Colors.indigo),
          _buildAssessmentCard('Aspecto Procedimental', Icons.healing, Colors.teal),
          _buildAssessmentCard('Aspecto Actitudinal', Icons.groups, Colors.deepOrange),
        ];
      default:
        return [];
    }
  }

  Widget _buildAssessmentCard(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            String route;
            switch (teacherCourse) {
              case 'Psicología':
                route = '/psychology_assessment';
                break;
              case 'Enfermería Hospitalaria':
                route = '/hospital_assessment';
                break;
              case 'Enfermería Comunitaria':
                route = '/community_assessment';
                break;
              default:
                return;
            }

            Navigator.pushNamed(
              context,
              route,
              arguments: {
                'aspectName': title,
                'studentName': studentName,
                'studentId': studentId,
                'icon': icon,
                'color': color,
              },
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}