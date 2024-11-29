import 'package:flutter/material.dart';
import 'dart:convert';
import '../utils/logger.dart';
import '../utils/responsive_utils.dart';
import '../controllers/assessment_controller.dart';
import '../widgets/psychology/student_info_card.dart';
import '../widgets/psychology/criteria_card.dart';
import '../widgets/psychology/bottom_button.dart';

class PsychologyAssessmentView extends StatefulWidget {
  const PsychologyAssessmentView({super.key});

  @override
  State<PsychologyAssessmentView> createState() => _PsychologyAssessmentViewState();
}

class _PsychologyAssessmentViewState extends State<PsychologyAssessmentView> {
  final AssessmentController _assessmentController = AssessmentController();
  Map<String, dynamic>? aspectData;
  int? selectedCriteriaIndex;
  bool isLoading = true;
  bool isSaving = false;
  late String aspectName;
  late String studentName;
  late String studentId;
  late IconData icon;
  late Color color;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      setState(() {
        aspectName = args['aspectName'];
        studentName = args['studentName'];
        studentId = args['studentId'];
        icon = args['icon'];
        color = args['color'];
      });
      _loadAspectData();
    });
  }

  Future<void> _loadAspectData() async {
    try {
      final String jsonString = await DefaultAssetBundle.of(context).loadString(
        'assets/json/psychology.json',
      );
      final data = json.decode(jsonString);

      final aspect = data['aspects'].firstWhere(
            (aspect) => aspect['name'] == aspectName,
        orElse: () => null,
      );

      setState(() {
        aspectData = aspect;
        isLoading = false;
      });
    } catch (e) {
      AppLogger.log('Error al cargar criterios: $e', prefix: 'ERROR:');
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleSave() async {
    setState(() => isSaving = true);
    final selectedCriteria = aspectData!['criteria'][selectedCriteriaIndex!];

    try {
      await _assessmentController.saveStudentAssessment(
        studentId: studentId,
        aspectName: aspectName,
        scores: {0: selectedCriteria['points']},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Calificación guardada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, selectedCriteria['points']);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la calificación: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ResponsiveUtils.wrapWithMaxWidth(
          AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: !isLoading ? Text(
              aspectName,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ) : null,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveUtils.wrapWithMaxWidth(_buildBody()),
    );
  }

  Widget _buildBody() {
    if (aspectData == null) {
      return const Center(child: Text('No se encontraron criterios'));
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StudentInfoCard(
                    studentName: studentName,
                    aspectName: aspectName,
                    icon: icon,
                    color: color,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Seleccione un criterio de evaluación:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: aspectData!['criteria'].length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final criteria = aspectData!['criteria'][index];
                      return CriteriaCard(
                        criteria: criteria,
                        isSelected: selectedCriteriaIndex == index,
                        color: color,
                        onTap: () => setState(() => selectedCriteriaIndex = index),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        BottomButton(
          color: color,
          isSaving: isSaving,
          selectedCriteriaIndex: selectedCriteriaIndex,
          onPressed: selectedCriteriaIndex != null && !isSaving ? _handleSave : null,
        ),
      ],
    );
  }
}