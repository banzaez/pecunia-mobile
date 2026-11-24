import 'dart:math';
import 'package:material_ui/material_ui.dart';

/// Общий виджет для каскадной анимации появления (fade + slide).
/// Централизует логику, которая ранее дублировалась в:
/// home_transaction_list.dart и transactions_screen.dart
class StaggeredFadeIn extends StatefulWidget {
  const StaggeredFadeIn({
    super.key,
    required this.child,
    required this.index,
    this.maxDelay = const Duration(milliseconds: 300),
    this.delayPerItem = const Duration(milliseconds: 40),
    this.maxAnimatedIndex = 15,
  });

  final Widget child;
  final int index;
  final Duration maxDelay;
  final Duration delayPerItem;

  /// Анимация только для первых N элементов — снижает нагрузку при пагинации.
  final int maxAnimatedIndex;

  @override
  State<StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<StaggeredFadeIn>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _opacityAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.index >= widget.maxAnimatedIndex) return;

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _controller = controller;

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: controller,
            curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    final rawDelay = widget.delayPerItem * widget.index;
    final clampedMs = min(
      rawDelay.inMilliseconds,
      widget.maxDelay.inMilliseconds,
    );
    Future.delayed(Duration(milliseconds: clampedMs), () {
      if (mounted) _controller?.forward();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return widget.child;
    }

    return FadeTransition(
      opacity: _opacityAnimation!,
      child: SlideTransition(position: _slideAnimation!, child: widget.child),
    );
  }
}
