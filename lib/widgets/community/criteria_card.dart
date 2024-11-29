import 'package:flutter/material.dart';

class CriteriaCard extends StatelessWidget {
  final int index;
  final String criteria;
  final bool hasScore;
  final int? score;
  final Color color;
  final bool isExpanded;
  final VoidCallback onTap;
  final List<int> scoreOptions;
  final Function(int) onScoreSelected;

  const CriteriaCard({
    required this.index,
    required this.criteria,
    required this.hasScore,
    this.score,
    required this.color,
    required this.isExpanded,
    required this.onTap,
    required this.scoreOptions,
    required this.onScoreSelected,
  });

  @override
  Widget build(BuildContext context) {
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
            onTap: onTap,
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
                      'Nota: $score',
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
            subtitle: Text(
              criteria,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
          if (isExpanded)
            _buildScoreOptions(),
        ],
      ),
    );
  }

  Widget _buildScoreOptions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: scoreOptions.map((scoreOption) {
          final isSelected = score == scoreOption;
          return InkWell(
            onTap: () => onScoreSelected(scoreOption),
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
                  scoreOption.toString(),
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
    );
  }
}