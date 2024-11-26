import 'package:flutter/material.dart';
import '../utils/logger.dart';
import '../components/student_bottom_sheet.dart';
import '../controllers/teacher_controller.dart';
import '../controllers/student_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/auth_controller.dart';

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

  final Map<String, Color> courseColors = {
    'Psicología': Colors.blue,
    'Enfermería Comunitaria': Colors.green,
    'Enfermería Hospitalaria': Colors.orange,
  };

  Color courseColor = Colors.green;
  String? teacherCourse;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
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
      print('Error loading teacher data: $e');
    }
  }

  void _filterStudents(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: teacherCourse != null
              ? const Icon(Icons.logout, color: Colors.black)
              : const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (teacherCourse != null) {
              _authController.signOut(context);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          teacherCourse != null ? 'Alumnos de $teacherCourse' : 'Lista de Alumnos',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          _buildAddButton(context),
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
                child: StreamBuilder<QuerySnapshot>(
                  stream: teacherCourse != null
                      ? _studentController.getStudentsByCourse(teacherCourse!)
                      : _studentController.getTeacherStudents(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final students = snapshot.data?.docs ?? [];
                    final filteredStudents = students.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
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
                        return ListView(
                          children: [
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: filteredStudents.map((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                return _buildStudentCard(
                                  context,
                                  data['fullName'] ?? '',
                                  data['studentId'] ?? '',
                                  data['internshipLocation'] ?? '',
                                  data['designatedArea'] ?? '',
                                  constraints,
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

  Widget _buildSearchAndDownloadBar() {
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
              onChanged: _filterStudents,
              decoration: const InputDecoration(
                hintText: 'Buscar Estudiante',
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
            color: courseColor,
            borderRadius: BorderRadius.circular(25),
          ),
          child: IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Descarga de Excel no implementada')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: courseColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: const Icon(Icons.person_add, color: Colors.white),
        onPressed: () {
          AppLogger.log('Botón de agregar alumno presionado', prefix: 'STUDENT_LIST:');
          _showAddStudentBottomSheet(context);
        },
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

  Widget _buildStudentCard(BuildContext context, String name, String studentId, String internshipSite, String designatedArea, BoxConstraints constraints) {
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
          '/student_assessment',
          arguments: name,
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
              color: Colors.grey.withOpacity(0.2),
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
                  backgroundColor: courseColor,
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
                        studentId,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.local_hospital, 'Sede de Internado', internshipSite),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.work, 'Área Designada', designatedArea),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}