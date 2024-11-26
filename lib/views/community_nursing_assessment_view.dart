import 'package:flutter/material.dart';
import 'dart:convert';
import '../utils/logger.dart';

class CommunityNursingAssessmentView extends StatefulWidget {
  const CommunityNursingAssessmentView({super.key});

  @override
  State<CommunityNursingAssessmentView> createState() => _CommunityNursingAssessmentViewState();
}

class _CommunityNursingAssessmentViewState extends State<CommunityNursingAssessmentView> {
  Map<String, dynamic>? aspectData;
  Map<int, int> selectedScores = {};
  Map<int, bool> expandedItems = {};
  bool isLoading = true;
  late String aspectName;
  late String studentName;
  late IconData icon;
  late Color color;

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
      appBar: AppBar(
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
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
                  _buildStudentInfo(),
                  const SizedBox(height: 24),
                  _buildCriteriaList(),
                ],
              ),
            ),
          ),
        ),
        _buildBottomButton(),
      ],
    );
  }

  Widget _buildCriteriaCard(int index) {
    final criteria = aspectData!['criteria'][index];
    final isExpanded = expandedItems[index] ?? false;
    final hasScore = selectedScores.containsKey(index);

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: hasScore ? color : Colors.grey[300]!,
          width: hasScore ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () {
              setState(() {
                expandedItems.forEach((key, _) {
                  if (key != index) expandedItems[key] = false;
                });
                expandedItems[index] = !isExpanded;
              });
            },
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    'Criterio ${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                if (hasScore)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Nota: ${selectedScores[index]}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: color,
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                criteria,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: scoreOptions[aspectName]!.map((score) {
                  final isSelected = selectedScores[index] == score;
                  return InkWell(
                    onTap: () => setState(() => selectedScores[index] = score),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected ? color : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? color : Colors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          score.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCriteriaList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: aspectData!['criteria'].length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildCriteriaCard(index),
    );
  }

  Widget _buildStudentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Evaluación de $aspectName',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    final allCriteriaScored = aspectData!['criteria'].length == selectedScores.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black12),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: allCriteriaScored ? () {
              AppLogger.log(
                'Calificaciones guardadas: $selectedScores',
                prefix: 'SAVE:',
              );
              Navigator.pop(context, selectedScores);
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: Text(
              allCriteriaScored
                  ? 'Guardar Calificaciones'
                  : 'Califique todos los criterios',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}