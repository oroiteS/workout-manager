import 'package:flutter/material.dart';

class DayTemplateCard extends StatelessWidget {
  final String dayLabel;
  final int dayOfWeek;
  final List<String> exercises;
  final VoidCallback onAdd;
  final ValueChanged<String> onDelete;

  const DayTemplateCard({
    super.key,
    required this.dayLabel,
    required this.dayOfWeek,
    required this.exercises,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  dayLabel,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _isToday() ? Colors.blue : Colors.black87,
                  ),
                ),
                if (_isToday())
                  const Text(
                    ' (今天)',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 22),
                  onPressed: onAdd,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (exercises.isEmpty)
              Text(
                '暂无动作',
                style: TextStyle(fontSize: 13, color: Colors.grey[400]),
              )
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: exercises.map((name) {
                  return Chip(
                    label: Text(name, style: const TextStyle(fontSize: 13)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => onDelete(name),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  bool _isToday() => DateTime.now().weekday == dayOfWeek;
}
