import 'package:flutter/material.dart';

class StudentCard extends StatelessWidget {
  final String name;
  final String studentId;
  final String internshipSite;
  final String designatedArea;
  final Color courseColor;
  final bool isAdminView;
  final double cardWidth;

  const StudentCard({
    super.key,
    required this.name,
    required this.studentId,
    required this.internshipSite,
    required this.designatedArea,
    required this.courseColor,
    required this.isAdminView,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
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
          _buildHeader(),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.local_hospital, 'Sede de Internado', internshipSite),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.work, 'Área Designada', designatedArea),
        ],
      ),
    );

    if (!isAdminView) {
      return GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/student_assessment',
            arguments: {
              'name': name,
              'studentId': studentId,
            },
          );
        },
        child: card,
      );
    }

    return card;
  }

  Widget _buildHeader() {
    return Row(
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
}