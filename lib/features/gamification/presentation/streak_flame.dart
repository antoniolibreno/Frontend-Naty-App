import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:natyapp/theme/app_colors.dart';

class StreakFlame extends StatefulWidget {
  const StreakFlame({required this.active, super.key});
  final bool active;

  @override
  State<StreakFlame> createState() => _StreakFlameState();
}

class _StreakFlameState extends State<StreakFlame> with WidgetsBindingObserver {
  ScrollPosition? _position;
  bool _visible = false;
  bool _resumed = true;
  bool _scheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = Scrollable.maybeOf(context)?.position;
    if (_position != next) {
      _position?.removeListener(_scheduleVisibility);
      _position = next;
      _position?.addListener(_scheduleVisibility);
    }
    _scheduleVisibility();
  }

  void _scheduleVisibility() {
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!mounted) return;
      final box = context.findRenderObject();
      final viewport = Scrollable.maybeOf(context)?.context.findRenderObject();
      final visible =
          box is RenderBox &&
          box.hasSize &&
          (viewport is! RenderBox ||
              (box.localToGlobal(Offset.zero) & box.size).overlaps(
                viewport.localToGlobal(Offset.zero) & viewport.size,
              ));
      if (_visible != visible) setState(() => _visible = visible);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (mounted) setState(() => _resumed = state == AppLifecycleState.resumed);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _position?.removeListener(_scheduleVisibility);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = Center(
      child: Icon(
        Icons.local_fire_department_rounded,
        color: widget.active ? AppColors.warning : AppColors.darkTextDisabled,
        size: 27,
      ),
    );
    final animate =
        widget.active &&
        _visible &&
        _resumed &&
        TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context);
    return SizedBox.square(
      dimension: 44,
      child: RepaintBoundary(
        child: animate
            ? icon
                  .animate(onPlay: (controller) => controller.repeat())
                  .custom(
                    duration: 1600.ms,
                    builder: (_, phase, child) => CustomPaint(
                      painter: StreakFirePainter(phase),
                      child: child,
                    ),
                  )
            : icon,
      ),
    );
  }
}

class StreakFirePainter extends CustomPainter {
  const StreakFirePainter(this.phase);
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    for (var index = 0; index < 7; index++) {
      final angle = math.pi * 2 * index / 7;
      final flicker = .5 + .5 * math.sin(phase * math.pi * 2 + index * 1.7);
      final x = size.width / 2 + math.cos(angle) * size.width * .32;
      final y = size.height / 2 + math.sin(angle) * size.height * .27;
      final height = 4 + flicker * 5;
      final sway = math.sin(phase * math.pi * 2 + index) * 2;
      final flame = Path()
        ..moveTo(x - 3, y + 3)
        ..cubicTo(
          x - 5,
          y - 2,
          x + sway - 1,
          y - height * .6,
          x + sway,
          y - height,
        )
        ..cubicTo(x + sway + 1, y - height * .4, x + 6, y - 1, x + 3, y + 3)
        ..quadraticBezierTo(x, y + 6, x - 3, y + 3);
      canvas.drawPath(
        flame,
        Paint()
          ..color = AppColors.warning.withValues(alpha: .35 + flicker * .4),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y + 1),
          width: 3,
          height: 4 + flicker * 2,
        ),
        Paint()..color = const Color(0xFFFFDD73).withValues(alpha: .8),
      );
    }
  }

  @override
  bool shouldRepaint(StreakFirePainter oldDelegate) =>
      phase != oldDelegate.phase;
}
