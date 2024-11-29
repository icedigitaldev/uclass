import 'package:flutter/material.dart';
import 'dart:convert';
import '../utils/logger.dart';
import '../utils/responsive_utils.dart';
import '../widgets/community/student_info_card.dart';
import '../widgets/community/criteria_card.dart';
import '../widgets/community/bottom_button.dart';
import '../controllers/assessment_controller.dart';

class CommunityNursingAssessmentView extends StatefulWidget {
  const CommunityNursingAssessmentView({super.key});

  @override
  State<CommunityNursingAssessmentView> createState() => _CommunityNursingAssessmentViewState();
}

class _CommunityNursingAssessmentViewState extends State<CommunityNursingAssessmentView> {
  final AssessmentController _assessmentController = AssessmentController();
  Map<String, dynamic>? aspectData;
  Map<int, int> selectedScores = {};
  Map<int, bool> expandedItems = {};
  bool isLoading = true;
  late String aspectName;
  late String studentName;
  late String studentId;
  late IconData icon;
  late Color color;
  bool isSaving = false;

  final Map<String, List<int>> scoreOptions = {
    'Aspecto Cognitivo': [0, 3, 6, 8],
    'Aspecto Procedimental': [0, 2, 4, 5],
    'Aspecto Actitudinal': [0, 2, 3, 4],
  };

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
        'assets/json/community_nursing.json',
      );
      final data = json.decode(jsonString);
      final aspect = data['aspects'].firstWhere(
            (aspect) => aspect['name'] == aspectName,
        orElse: () => null,
      );

      setState(() {
        aspectData = aspect;
        isLoading = false;
        for (int i = 0; i < aspect['criteria'].length; i++) {
          expandedItems[i] = false;
        }
      });
    } catch (e) {
      AppLogger.log('Error al cargar criterios: $e', prefix: 'ERROR:');
      setState(() => isLoading = false);
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

    final allCriteriaScored = aspectData!['criteria'].length == selectedScores.length;

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
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: aspectData!['criteria'].length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return CriteriaCard(
                        index: index,
                        criteria: aspectData!['criteria'][index],
                        hasScore: selectedScores.containsKey(index),
                        score: selectedScores[index],
                        color: color,
                        isExpanded: expandedItems[index] ?? false,
                        onTap: () {
                          setState(() {
                            expandedItems.forEach((key, _) {
                              if (key != index) expandedItems[key] = false;
                            });
                            expandedItems[index] = !(expandedItems[index] ?? false);
                          });
                        },
                        scoreOptions: scoreOptions[aspectName]!,
                        onScoreSelected: (score) {
                          setState(() => selectedScores[index] = score);
                        },
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
          isLoading: isSaving,
          onPressed: allCriteriaScored ? () async {
            setState(() => isSaving = true);
            await _assessmentController.saveStudentAssessment(
              studentId: studentId,
              aspectName: aspectName,
              scores: selectedScores,
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Calificaciones guardadas correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, selectedScores);
            }
          } : null,
          allCriteriaScored: allCriteriaScored,
        ),
      ],
    );
  }
}