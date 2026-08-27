import 'package:flutter/material.dart';
import 'package:natyapp/core/components/learning_path.dart';
import 'package:natyapp/theme/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(

      color: AppColors.darkBackground,
      child: LearningPath(
        steps: const [
          LearningPathStep(
            label: 'Canais',
            state: LearningPathStepState.completed,
            horizontalPosition: .45,
          ),
          LearningPathStep(
            label: 'Conversas',
            state: LearningPathStepState.active,
            nodeText: '2',
            horizontalPosition: .62,
          ),
          LearningPathStep(
            label: 'Empresa',
            state: LearningPathStepState.locked,
            labelSide: LearningPathLabelSide.right,
            horizontalPosition: .68,
          ),
        ],
      ),
    );
  }
}
