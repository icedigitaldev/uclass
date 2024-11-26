import 'package:flutter/material.dart';
import 'dart:convert';
import '../utils/logger.dart';

class PsychologyAssessmentView extends StatefulWidget {
  const PsychologyAssessmentView({super.key});

  @override
  State<PsychologyAssessmentView> createState() => _PsychologyAssessmentViewState();
}

class _PsychologyAssessmentViewState extends State<PsychologyAssessmentView> {
  Map<String, dynamic>? aspectData;
  int? selectedCriteriaIndex;
  bool isLoading = true;
  late String aspectName;
  late String studentName;
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
      AppLogger.log('Criterios cargados: $aspectName', prefix: 'PSYCHOLOGY:');
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
                  const Text(
                    'Seleccione un criterio de evaluación:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
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

  Widget _buildCriteriaList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: aspectData!['criteria'].length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final criteria = aspectData!['criteria'][index];
        final isSelected = selectedCriteriaIndex == index;

        return InkWell(
          onTap: () => setState(() => selectedCriteriaIndex = index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : Colors.grey[200]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      criteria['points'].toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    criteria['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: selectedCriteriaIndex != null ? () {
              final selectedCriteria = aspectData!['criteria'][selectedCriteriaIndex!];
              AppLogger.log(
                'Criterio seleccionado: ${selectedCriteria['description']} - Puntos: ${selectedCriteria['points']}',
                prefix: 'SAVE:',
              );
              Navigator.pop(context, selectedCriteria['points']);
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
              selectedCriteriaIndex != null ? 'Guardar Calificación' : 'Seleccione un criterio',
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