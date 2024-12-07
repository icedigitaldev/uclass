import 'package:flutter/material.dart';

class StudentCard extends StatelessWidget {
  final String name;
  final String studentId;
  final String internshipSite;
  final String designatedArea;
  final Color courseColor;
  final bool isAdminView;
  final double cardWidth;
  final String id;
  final Function(String) onEdit;
  final Function(String) onDelete;

  const StudentCard({
    super.key,
    required this.name,
    required this.studentId,
    required this.internshipSite,
    required this.designatedArea,
    required this.courseColor,
    required this.isAdminView,
    required this.cardWidth,
    required this.id,
    required this.onEdit,
    required this.onDelete,
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
          _buildHeader(context),
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

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
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
              Column(
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
            ],
          ),
          Positioned(
            top: -10,
            right: -10,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (String value) {
                switch (value) {
                  case 'edit':
                    onEdit(id);
                    break;
                  case 'delete':
                    onDelete(id);
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
}
