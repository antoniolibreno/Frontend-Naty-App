import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Mantém os gestos e o foco do controle; apenas anima a resposta ao toque.
class PressFeedback extends StatefulWidget {
  const PressFeedback({required this.child, this.enabled = true, super.key});
  final Widget child;
  final bool enabled;

  @override
  State<PressFeedback> createState() => _PressFeedbackState();
}

class _PressFeedbackState extends State<PressFeedback> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: widget.enabled ? (_) => _setPressed(true) : null,
    onPointerUp: (_) => _setPressed(false),
    onPointerCancel: (_) => _setPressed(false),
    child: widget.child
        .animate(
          target:
              _pressed &&
                  widget.enabled &&
                  !MediaQuery.disableAnimationsOf(context)
              ? 1
              : 0,
        )
        .scaleXY(
          begin: 1,
          end: .97,
          duration: 120.ms,
          curve: Curves.easeOutCubic,
        ),
  );
}
