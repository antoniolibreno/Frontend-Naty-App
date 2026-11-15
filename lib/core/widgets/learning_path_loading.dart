import 'package:flutter/material.dart';
import 'package:natyapp/theme/app_colors.dart';

class LearningPathLoading extends StatelessWidget {
  const LearningPathLoading({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Carregando trilhas',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const LoadingProgressBar(label: 'Carregando trilhas'),
        const Padding(
          padding: EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 180,
              height: 24,
              child: ColoredBox(color: AppColors.darkSurfaceVariant),
            ),
          ),
        ),
        Expanded(
          child: ExcludeSemantics(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var index = 0; index < 4; index++)
                  Align(
                    alignment: index.isEven
                        ? const Alignment(-.3, 0)
                        : const Alignment(.3, 0),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: SizedBox.square(
                        dimension: 64,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.darkSurface,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class LoadingProgressBar extends StatelessWidget {
  const LoadingProgressBar({required this.label, super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Semantics(
        label: label,
        child: const SizedBox(
          height: 3,
          child: ColoredBox(color: AppColors.brandGreen),
        ),
      );
    }
    return LinearProgressIndicator(
      minHeight: 3,
      color: AppColors.brandGreen,
      backgroundColor: AppColors.darkBorder,
      semanticsLabel: label,
    );
  }
}
