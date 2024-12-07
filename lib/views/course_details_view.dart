import 'package:flutter/material.dart';
import '../widgets/course/search_download_bar.dart';
import '../widgets/course/teacher_card.dart';
import '../widgets/course/add_button.dart';
import '../components/teacher_bottom_sheet.dart';
import '../controllers/teacher_controller.dart';
import '../controllers/assessment_controller.dart';
import '../utils/pdf_generator.dart';
import '../utils/logger.dart';

class CourseDetailsView extends StatefulWidget {
  const CourseDetailsView({Key? key}) : super(key: key);

  @override
  _CourseDetailsViewState createState() => _CourseDetailsViewState();
}

class _CourseDetailsViewState extends State<CourseDetailsView> {
  final TextEditingController _searchController = TextEditingController();
  final TeacherController _teacherController = TeacherController();
  final AssessmentController _assessmentController = AssessmentController();
  final PdfGenerator _pdfGenerator = PdfGenerator();

  List<Map<String, dynamic>> filteredTeachers = [];
  List<Map<String, dynamic>> allTeachers = [];
  bool isLoading = true;
  bool _isDownloading = false;
  Map<String, bool> passwordVisibility = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTeachers();
    });
  }

  Future<void> _loadTeachers() async {
    final String courseName = ModalRoute.of(context)!.settings.arguments as String;

    try {
      setState(() => isLoading = true);
      final teachers = await _teacherController.getTeachersByCourse(courseName);

      setState(() {
        allTeachers = teachers;
        filteredTeachers = teachers;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar profesores: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleTeacherStatusUpdate(String teacherId, bool newStatus) async {
    try {
      await _teacherController.updateTeacherStatus(
        teacherId: teacherId,
        isActive: newStatus,
        onSuccess: () {
          setState(() {
            final teacherIndex = allTeachers.indexWhere((t) => t['id'] == teacherId);
            if (teacherIndex != -1) {
              allTeachers[teacherIndex]['isActive'] = newStatus;
              _filterTeachers(_searchController.text);
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(newStatus ? 'Profesor activado exitosamente' : 'Profesor desactivado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    } catch (e) {
      AppLogger.log('Error al actualizar estado: $e', prefix: 'TEACHERS:');
    }
  }

  Future<void> _showTeacherBottomSheet(BuildContext context, String courseName, [Map<String, dynamic>? teacher]) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return TeacherBottomSheet(
          curso: courseName,
          teacher: teacher,
        );
      },
    );

    if (result == true) {
      _loadTeachers();
    }
  }

  Future<void> _downloadAllReports() async {
    if (_isDownloading) return;

    final String courseName = ModalRoute.of(context)!.settings.arguments as String;
    setState(() => _isDownloading = true);

    try {
      int totalPdfs = 0;

      for (var teacher in filteredTeachers) {
        AppLogger.log('Procesando profesor: ${teacher['name']}', prefix: 'PDF_DOWNLOAD:');

        final data = await _assessmentController.getPdfData(
          teacherId: teacher['id'],
        );

        if (data['students'].isNotEmpty) {
          for (var student in data['students']) {
            final String pdfPath = await _pdfGenerator.generatePdf(
              studentData: student,
              teacherData: data['teacher'],
              courseName: courseName,
              teacherName: teacher['name'],
            );

            if (pdfPath.isNotEmpty) {
              totalPdfs++;
              AppLogger.log('PDF generado: $pdfPath', prefix: 'PDF_DOWNLOAD:');
            }
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Se generaron $totalPdfs PDFs exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDFs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      AppLogger.log('Error en la descarga: $e', prefix: 'PDF_DOWNLOAD:');
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  void _filterTeachers(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredTeachers = allTeachers;
      } else {
        filteredTeachers = allTeachers.where((teacher) =>
        teacher['name']!.toLowerCase().contains(query.toLowerCase()) ||
            teacher['dni']!.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String courseName = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          courseName,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          AddButton(
            courseName: courseName,
            onPressed: () => _showTeacherBottomSheet(context, courseName),
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
                onSearchChanged: _filterTeachers,
                isDownloading: _isDownloading,
                onDownloadPressed: _downloadAllReports,
                courseName: courseName,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredTeachers.isEmpty
                    ? const Center(
                  child: Text('No hay profesores registrados en este curso'),
                )
                    : LayoutBuilder(
                  builder: (context, constraints) {
                    return ListView(
                      children: [
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: filteredTeachers.map((teacher) =>
                              TeacherCard(
                                teacher: teacher,
                                courseName: courseName,
                                passwordVisibility: passwordVisibility,
                                onPasswordVisibilityChanged: (password, isVisible) {
                                  setState(() {
                                    passwordVisibility[password] = isVisible;
                                  });
                                },
                                onEdit: (teacherId) {
                                  AppLogger.log('Editando profesor: $teacherId', prefix: 'TEACHERS:');
                                  _showTeacherBottomSheet(context, courseName, teacher);
                                },
                                onToggleStatus: _handleTeacherStatusUpdate,
                              ),
                          ).toList(),
                        ),
                      ],
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}