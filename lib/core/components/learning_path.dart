import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:natyapp/theme/app_colors.dart';

/// Estado visual de uma etapa da trilha.
enum LearningPathStepState { completed, active, available, locked }

/// Lado em que o texto da etapa será exibido em relação ao nó.
enum LearningPathLabelSide { left, right }

/// Dados de uma etapa exibida por [LearningPath].
class LearningPathStep {
  const LearningPathStep({
    required this.label,
    required this.state,
    this.icon,
    this.nodeText,
    this.labelSide = LearningPathLabelSide.right,
    this.horizontalPosition = 0.5,
    this.semanticLabel,
    this.onTap,
  }) : assert(horizontalPosition >= 0 && horizontalPosition <= 1);

  final String label;
  final LearningPathStepState state;
  final IconData? icon;
  final String? nodeText;

  /// Define o lado do rótulo sem obrigar o componente a seguir uma direção fixa.
  final LearningPathLabelSide labelSide;

  /// Posição horizontal do centro do nó, de 0 (esquerda) a 1 (direita).
  final double horizontalPosition;
  final String? semanticLabel;
  final VoidCallback? onTap;
}

/// Trilha vertical de etapas, como um mapa de progresso de treinamento.
///
/// Exemplo:
///
/// ```dart
/// LearningPath(
///   steps: const [
///     LearningPathStep(
///       label: 'Canais',
///       state: LearningPathStepState.completed,
///     ),
///     LearningPathStep(
///       label: 'Conversas',
///       state: LearningPathStepState.active,
///     ),
///   ],
/// )
/// ```
class LearningPath extends StatelessWidget {
  const LearningPath({
    required this.steps,
    super.key,
    this.stepExtent = 96,
    this.nodeSize = 58,
    this.horizontalPadding = 28,
    this.labelGap = 14,
    this.connectorWidth = 3,
    this.controller,
    this.physics,
  });

  final List<LearningPathStep> steps;
  final double stepExtent;
  final double nodeSize;
  final double horizontalPadding;
  final double labelGap;
  final double connectorWidth;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();

    final height = stepExtent * steps.length;

    return Semantics(
      container: true,
      label: 'Trilha de progresso',
      child: SingleChildScrollView(
        controller: controller,
        physics: physics,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : 360.0;
            final pathWidth = math
                .max(0.0, width - horizontalPadding * 2)
                .toDouble();

            return SizedBox(
              height: height,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _LearningPathConnectorPainter(
                          steps: steps,
                          nodeSize: nodeSize,
                          stepExtent: stepExtent,
                          horizontalPadding: horizontalPadding,
                          connectorWidth: connectorWidth,
                          pathWidth: pathWidth,
                        ),
                      ),
                    ),
                  ),
                  for (var index = 0; index < steps.length; index++)
                    _StepPositioned(
                      step: steps[index],
                      index: index,
                      width: width,
                      pathWidth: pathWidth,
                      stepExtent: stepExtent,
                      nodeSize: nodeSize,
                      horizontalPadding: horizontalPadding,
                      labelGap: labelGap,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StepPositioned extends StatelessWidget {
  const _StepPositioned({
    required this.step,
    required this.index,
    required this.width,
    required this.pathWidth,
    required this.stepExtent,
    required this.nodeSize,
    required this.horizontalPadding,
    required this.labelGap,
  });

  final LearningPathStep step;
  final int index;
  final double width;
  final double pathWidth;
  final double stepExtent;
  final double nodeSize;
  final double horizontalPadding;
  final double labelGap;

  @override
  Widget build(BuildContext context) {
    final nodeLeft = horizontalPadding +
        (pathWidth * step.horizontalPosition) -
        (nodeSize / 2);
    final labelLeft = step.labelSide == LearningPathLabelSide.right
        ? nodeLeft + nodeSize + labelGap
        : 0.0;
    final labelRight = step.labelSide == LearningPathLabelSide.left
        ? width - nodeLeft + labelGap
        : 12.0;

    final label = Text(
      step.label,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: _labelColor(step.state),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );

    return Positioned(
      left: 0,
      right: 0,
      top: index * stepExtent,
      height: stepExtent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: nodeLeft,
            top: (stepExtent - nodeSize) / 2,
            child: _LearningPathNode(step: step, size: nodeSize),
          ),
          Positioned(
            left: labelLeft,
            right: labelRight,
            top: (stepExtent - 18) / 2,
            child: Align(
              alignment: step.labelSide == LearningPathLabelSide.right
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: label,
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningPathNode extends StatelessWidget {
  const _LearningPathNode({required this.step, required this.size});

  final LearningPathStep step;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isActive = step.state == LearningPathStepState.active;
    final isCompleted = step.state == LearningPathStepState.completed;
    final isLocked = step.state == LearningPathStepState.locked;
    final foreground = isActive
        ? AppColors.darkBackground
        : isCompleted
        ? AppColors.darkBackground
        : AppColors.darkTextDisabled;

    final node = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? AppColors.brandPurple
            : isCompleted
            ? AppColors.brandGreen
            : AppColors.darkSurface,
        border: isLocked
            ? Border.all(color: AppColors.darkBorder)
            : null,
      ),
      alignment: Alignment.center,
      child: step.nodeText != null
          ? Text(
              step.nodeText!,
              style: TextStyle(
                color: foreground,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            )
          : Icon(
              step.icon ?? (isCompleted ? Icons.check : Icons.lock),
              size: isActive && step.icon == null ? 24 : 20,
              color: foreground,
            ),
    );

    return Semantics(
      button: step.onTap != null,
      enabled: !isLocked,
      label: step.semanticLabel ?? '${step.label}, ${_stateLabel(step.state)}',
      child: step.onTap == null
          ? node
          : Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: isLocked ? null : step.onTap,
                customBorder: const CircleBorder(),
                child: node,
              ),
            ),
    );
  }
}

class _LearningPathConnectorPainter extends CustomPainter {
  const _LearningPathConnectorPainter({
    required this.steps,
    required this.nodeSize,
    required this.stepExtent,
    required this.horizontalPadding,
    required this.connectorWidth,
    required this.pathWidth,
  });

  final List<LearningPathStep> steps;
  final double nodeSize;
  final double stepExtent;
  final double horizontalPadding;
  final double connectorWidth;
  final double pathWidth;

  @override
  void paint(Canvas canvas, Size size) {
    for (var index = 0; index < steps.length - 1; index++) {
      final start = _center(index);
      final end = _center(index + 1);
      final paint = Paint()
        ..color = steps[index].state == LearningPathStepState.completed
            ? AppColors.brandGreen
            : AppColors.darkBorder
        ..strokeWidth = connectorWidth
        ..style = PaintingStyle.stroke;

      _drawDashedLine(canvas, start, end, paint);
    }
  }

  Offset _center(int index) => Offset(
        horizontalPadding + pathWidth * steps[index].horizontalPosition,
        stepExtent / 2 + index * stepExtent,
      );

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final distance = (end - start).distance;
    final direction = (end - start) / distance;
    const dashLength = 4.0;
    const gapLength = 5.0;

    for (var offset = nodeSize / 2; offset < distance - nodeSize / 2;) {
      final dashEnd = math.min(offset + dashLength, distance - nodeSize / 2);
      canvas.drawLine(
        start + direction * offset,
        start + direction * dashEnd,
        paint,
      );
      offset += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant _LearningPathConnectorPainter oldDelegate) =>
      oldDelegate.steps != steps ||
      oldDelegate.stepExtent != stepExtent ||
      oldDelegate.pathWidth != pathWidth;
}

Color _labelColor(LearningPathStepState state) => switch (state) {
      LearningPathStepState.completed => AppColors.darkTextSecondary,
      LearningPathStepState.active => AppColors.darkTextPrimary,
      LearningPathStepState.available => AppColors.darkTextSecondary,
      LearningPathStepState.locked => AppColors.darkTextDisabled,
    };

String _stateLabel(LearningPathStepState state) => switch (state) {
      LearningPathStepState.completed => 'concluído',
      LearningPathStepState.active => 'em andamento',
      LearningPathStepState.available => 'disponível',
      LearningPathStepState.locked => 'bloqueado',
    };
