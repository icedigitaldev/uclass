import 'package:flutter/material.dart';
import '../dialogs/logout_confirmation_dialog.dart';
import '../utils/logger.dart';
import '../utils/pdf_generator.dart';
import '../components/student_bottom_sheet.dart';
import '../controllers/teacher_controller.dart';
import '../controllers/student_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/assessment_controller.dart';
import '../widgets/student/search_download_bar.dart';
import '../widgets/student/student_card.dart';
import '../widgets/student/add_student_button.dart';

class StudentListView extends StatefulWidget {
  const StudentListView({Key? key}) : super(key: key);

  @override
  _StudentListViewState createState() => _StudentListViewState();
}

class _StudentListViewState extends State<StudentListView> {
  final TextEditingController _searchController = TextEditingController();
  final TeacherController _teacherController = TeacherController();
  final StudentController _studentController = StudentController();
  final AuthController _authController = AuthController();
  final AssessmentController _assessmentController = AssessmentController();
  final PdfGenerator _pdfGenerator = PdfGenerator();

  final Map<String, Color> courseColors = {
    'Psicología': Colors.blue,
    'Enfermería Comunitaria': Colors.green,
    'Enfermería Hospitalaria': Colors.orange,
  };

  Color courseColor = Colors.green;
  String? teacherCourse;
  String? adminViewTeacherId;
  String? adminViewTeacherName;
  String _searchQuery = '';
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final Map<String, dynamic>? args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      setState(() {
        adminViewTeacherId = args['teacherId'];
        adminViewTeacherName = args['teacherName'];
        teacherCourse = args['course'];
        if (teacherCourse != null && courseColors.containsKey(teacherCourse)) {
          courseColor = courseColors[teacherCourse]!;
        }
      });
    } else {
      await _loadTeacherData();
    }
  }

  Future<void> _loadTeacherData() async {
    try {
      final teacherData = await _teacherController.getCurrentTeacher();
      if (teacherData != null && mounted) {
        setState(() {
          teacherCourse = teacherData['curso'];
          if (teacherCourse != null && courseColors.containsKey(teacherCourse)) {
            courseColor = courseColors[teacherCourse]!;
          }
        });
      }
    } catch (e) {
      AppLogger.log('Error al cargar datos del profesor: $e', prefix: 'STUDENT_LIST:');
    }
  }

  void _filterStudents(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  Future<void> _handlePdfGeneration() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      final data = await _assessmentController.getPdfData(
        teacherId: adminViewTeacherId,
      );
      List<String> generatedPaths = [];

      for (var student in data['students']) {
        final pdfPath = await _pdfGenerator.generatePdf(
          studentData: student,
          teacherData: data['teacher'],
        );
        if (pdfPath.isNotEmpty) {
          generatedPaths.add(pdfPath);
        }
      }

      if (mounted && generatedPaths.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Se generaron ${generatedPaths.length} PDFs exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al generar los PDFs'),
            backgroundColor: Colors.red,
          ),
        );
      }
      AppLogger.log('Error al generar PDFs: $e', prefix: 'PDF_GENERATION:');
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: adminViewTeacherId != null
              ? const Icon(Icons.arrow_back, color: Colors.black)
              : const Icon(Icons.logout, color: Colors.black),
          onPressed: () {
            if (adminViewTeacherId != null) {
              Navigator.pop(context);
            } else {
              // Mostrar el diálogo de confirmación
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return LogoutConfirmationDialog(
                    onConfirm: () => _authController.signOut(context),
                  );
                },
              );
            }
          },
        ),
        title: Text(
          adminViewTeacherId != null
              ? adminViewTeacherName ?? ''
              : teacherCourse ?? 'Lista de Alumnos',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (adminViewTeacherId == null)
            AddStudentButton(
              courseColor: courseColor,
              onPressed: () => _showAddStudentBottomSheet(context),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
          child: Column(
            children: [
              SearchDownloadBar(
                searchController: _searchController,
                onSearch: _filterStudents,
                onDownload: _handlePdfGeneration,
                isDownloading: _isDownloading,
                courseColor: courseColor,
                showDownload: true, // Habilitado para admin y profesor
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: adminViewTeacherId != null
                      ? _studentController.getStudentsByTeacherId(adminViewTeacherId!)
                      : teacherCourse != null
                      ? _studentController.getStudentsByCourse(teacherCourse!)
                      : _studentController.getTeacherStudents(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final students = snapshot.data ?? [];
                    final filteredStudents = students.where((data) {
                      return data['fullName'].toString().toLowerCase().contains(_searchQuery) ||
                          data['studentId'].toString().toLowerCase().contains(_searchQuery);
                    }).toList();

                    if (filteredStudents.isEmpty) {
                      return const Center(
                        child: Text('No se encontraron estudiantes'),
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        double cardWidth = constraints.maxWidth;
                        if (constraints.maxWidth > 1200) {
                          cardWidth = (constraints.maxWidth - 32) / 3;
                        } else if (constraints.maxWidth > 800) {
                          cardWidth = (constraints.maxWidth - 16) / 2;
                        }

                        return ListView(
                          children: [
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: filteredStudents.map((data) {
                                return StudentCard(
                                  name: data['fullName'] ?? '',
                                  studentId: data['studentId'] ?? '',
                                  internshipSite: data['internshipLocation'] ?? '',
                                  designatedArea: data['designatedArea'] ?? '',
                                  courseColor: courseColor,
                                  isAdminView: adminViewTeacherId != null,
                                  cardWidth: cardWidth,
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddStudentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StudentBottomSheet(course: teacherCourse);
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}