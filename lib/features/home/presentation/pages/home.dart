import 'package:flutter/material.dart';
import 'package:natyapp/core/components/learning_path.dart';
import 'package:natyapp/core/router/app_routes.dart';
import 'package:natyapp/theme/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(

      color: AppColors.darkBackground,
      child: LearningPath(
        steps:  [
          LearningPathStep(
            label: 'Canais',
            state: LearningPathStepState.completed,
            horizontalPosition: .45,
            onTap: (){
              Navigator.of(context).pushNamed(AppRoute.aula.path);
            }
          ),
          LearningPathStep(
            label: 'Conversas',
            state: LearningPathStepState.active,
            nodeText: '2',
            horizontalPosition: .2,
          ),
          LearningPathStep(
            label: 'Empresa',
            state: LearningPathStepState.available,
            labelSide: LearningPathLabelSide.right,
            horizontalPosition: .68,
          ),
          LearningPathStep(
            label: 'Canais',
            state: LearningPathStepState.completed,
            horizontalPosition: .45,
          ),

        ],
      ),
    );
  }
}
