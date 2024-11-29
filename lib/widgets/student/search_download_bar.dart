import 'package:flutter/material.dart';

class SearchDownloadBar extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearch;
  final VoidCallback? onDownload;
  final bool isDownloading;
  final Color courseColor;
  final bool showDownload;

  const SearchDownloadBar({
    super.key,
    required this.searchController,
    required this.onSearch,
    this.onDownload,
    required this.isDownloading,
    required this.courseColor,
    this.showDownload = true,
  });

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
              onChanged: onSearch,
              decoration: const InputDecoration(
                hintText: 'Buscar Estudiante',
                border: InputBorder.none,
                icon: Icon(Icons.search),
              ),
            ),
          ),
        ),
        if (showDownload) ...[
          const SizedBox(width: 16),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: courseColor,
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
              onPressed: isDownloading ? null : onDownload,
            ),
          ),
        ],
      ],
    );
  }
}