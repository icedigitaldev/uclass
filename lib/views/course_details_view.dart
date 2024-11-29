import 'package:flutter/material.dart';
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

  final Map<String, Color> courseColors = {
    'Psicología': Colors.blue,
    'Enfermería Comunitaria': Colors.green,
    'Enfermería Hospitalaria': Colors.orange,
  };

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar profesores: $e')),
      );
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

  Widget _buildSearchAndDownloadBar() {
    final String courseName = ModalRoute.of(context)!.settings.arguments as String;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterTeachers,
              decoration: const InputDecoration(
                hintText: 'Buscar Profesor',
                border: InputBorder.none,
                icon: Icon(Icons.search),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: courseColors[courseName] ?? Colors.blue,
            borderRadius: BorderRadius.circular(25),
          ),
          child: IconButton(
            icon: _isDownloading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Icon(Icons.download, color: Colors.white),
            onPressed: _downloadAllReports,
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context, String courseName) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: const Icon(Icons.person_add, color: Colors.white),
        onPressed: () async {
          await _showAddTeacherBottomSheet(context, courseName);
          _loadTeachers();
        },
      ),
    );
  }

  Future<void> _showAddTeacherBottomSheet(BuildContext context, String courseName) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return TeacherBottomSheet(curso: courseName);
      },
    );
  }

  Widget _buildUserCard(String id, String name, String email, String dni, String password, BoxConstraints constraints) {
    double cardWidth = constraints.maxWidth;
    if (constraints.maxWidth > 1200) {
      cardWidth = (constraints.maxWidth - 32) / 3;
    } else if (constraints.maxWidth > 800) {
      cardWidth = (constraints.maxWidth - 16) / 2;
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/student_list',
          arguments: {
            'teacherId': id,
            'teacherName': name,
            'course': ModalRoute.of(context)!.settings.arguments as String,
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
              color: courseColors[ModalRoute.of(context)!.settings.arguments as String]?.withOpacity(0.2) ?? Colors.blue.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: courseColors[ModalRoute.of(context)!.settings.arguments as String] ?? Colors.blue,
                  child: Text(
                    name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.credit_card, 'DNI', dni),
            const SizedBox(height: 8),
            _buildPasswordRow(password),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: courseColors[ModalRoute.of(context)!.settings.arguments as String] ?? Colors.blue),
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

  Widget _buildPasswordRow(String password) {
    final courseColor = courseColors[ModalRoute.of(context)!.settings.arguments as String] ?? Colors.blue;
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
            setState(() {
              passwordVisibility[password] = !(passwordVisibility[password] ?? false);
            });
          },
        ),
      ],
    );
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
          _buildAddButton(context, courseName),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
          child: Column(
            children: [
              _buildSearchAndDownloadBar(),
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
                              _buildUserCard(
                                teacher['id'],
                                teacher['name']!,
                                teacher['email']!,
                                teacher['dni']!,
                                teacher['password']!,
                                constraints,
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