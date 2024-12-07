import 'package:flutter/material.dart';

class SearchDownloadBar extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final bool isDownloading;
  final VoidCallback onDownloadPressed;
  final String courseName;

  const SearchDownloadBar({
    Key? key,
    required this.searchController,
    required this.onSearchChanged,
    required this.isDownloading,
    required this.onDownloadPressed,
    required this.courseName,
  }) : super(key: key);

  final Map<String, Color> courseColors = const {
    'Psicología': Colors.blue,
    'Enfermería Comunitaria': Colors.green,
    'Enfermería Hospitalaria': Colors.orange,
  };

  @override
  Widget build(BuildContext context) {
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
              controller: searchController,
              onChanged: onSearchChanged,
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
            icon: isDownloading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Icon(Icons.download, color: Colors.white),
            onPressed: onDownloadPressed,
          ),
        ),
      ],
    );
  }
}