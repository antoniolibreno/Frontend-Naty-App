import 'package:flutter/material.dart';
import 'package:natyapp/theme/app_colors.dart';

class Progressbar extends StatelessWidget {
  const Progressbar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      child: ClipRRect(
        child: SizedBox(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(color: AppColors.darkBackground),
            child: Column(
              spacing: 10,
              children: [
                Row(
                  children: [
                    buildProgressCircle(atual: 20, total: 100),
                    const SizedBox(width: 12),
                    Expanded(
                      child: buildProgressBar(
                        atual: 20,
                        texto: 'Modulo de IA',
                        total: 100,
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 20,
                  children: [
                    Container(
                      child: Row(
                        spacing: 5,
                        children: [
                          Image.asset("assets/imgs/fogo.png", width: 20),
                          Text(
                            "4 DIAS",
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "240 XP",
                      style: TextStyle(
                        color: AppColors.brandPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Meta 1/3",
                      style: TextStyle(
                        color: AppColors.brandGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 3,
                        color: AppColors.darkSurface,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildProgressCircle({required int atual, required int total}) {
    final progresso = atual / total;

    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.darkBackground,
            ),
          ),

          SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              value: progresso,
              strokeWidth: 4,
              backgroundColor: AppColors.darkSurface,
              valueColor: const AlwaysStoppedAnimation(AppColors.brandGreen),
              strokeCap: StrokeCap.round,
            ),
          ),

          Text(
            atual.toString(),
            style: const TextStyle(
              color: AppColors.primaryLight,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProgressBar({
    required int atual,
    required int total,
    required String texto,
  }) {
    final progresso = total > 0 ? atual / total : 0.0;
    final porcentagem = (progresso * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              texto,
              style: TextStyle(
                color: Color(0xFFB8C0D4),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$porcentagem%',
              style: const TextStyle(
                color: Color(0xFFB8C0D4),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: progresso,
            minHeight: 5,
            backgroundColor: const Color(0xFF182136),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF5DE1B5)),
          ),
        ),
      ],
    );
  }
}
