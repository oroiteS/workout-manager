// lib/widgets/exercise_input_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExerciseInputCard extends StatelessWidget {
  final int exerciseId;
  final String exerciseName;
  final double? lastWeight;
  final DateTime? lastDate;
  final ValueChanged<double?> onWeightChanged;

  const ExerciseInputCard({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    required this.lastWeight,
    required this.lastDate,
    required this.onWeightChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => Navigator.pushNamed(
                context,
                '/chart',
                arguments: (exerciseId: exerciseId, exerciseName: exerciseName),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      exerciseName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                ],
              ),
            ),
            if (lastWeight != null) ...[
              const SizedBox(height: 6),
              Text(
                _buildHint(),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 10),
            TextFormField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: '重量 (kg)',
                hintText: '0.0',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (v) {
                final parsed = double.tryParse(v);
                onWeightChanged(parsed);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _buildHint() {
    final dateStr = lastDate != null
        ? DateFormat('M月d日').format(lastDate!)
        : '';
    return '💡 上次：${lastWeight}kg${dateStr.isNotEmpty ? '（$dateStr）' : ''}';
  }
}
