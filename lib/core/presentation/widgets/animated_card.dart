import 'package:flutter/material.dart';
import '../../theme/app_animations.dart';
import '../../theme/app_shadows.dart';

/// Карточка с анимациями и тенями для визуальной иерархии
/// Источник: 5 приемов отличного UI - тени для иерархии → задачи на 15% быстрее
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final Border? border;
  final bool enableHoverEffect;
  final bool enableShadow;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.gradient,
    this.border,
    this.enableHoverEffect = true,
    this.enableShadow = true,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.cardHover,
      vsync: this,
    );
    _elevationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHoverEnter(PointerEvent event) {
    if (widget.enableHoverEffect && widget.onTap != null) {
      setState(() => _isHovered = true);
      _controller.forward();
    }
  }

  void _handleHoverExit(PointerEvent event) {
    if (widget.enableHoverEffect && widget.onTap != null) {
      setState(() => _isHovered = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = widget.color ?? theme.cardTheme.color ?? theme.colorScheme.surface;
    final shadowColor = theme.colorScheme.primary;

    return MouseRegion(
      onEnter: _handleHoverEnter,
      onExit: _handleHoverExit,
      child: AnimatedBuilder(
        animation: _elevationAnimation,
        builder: (context, child) {
          return Container(
            margin: widget.margin,
            decoration: BoxDecoration(
              color: widget.gradient == null ? cardColor : null,
              gradient: widget.gradient,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
              border: widget.border,
              boxShadow: widget.enableShadow
                  ? (_isHovered
                      ? AppShadows.elevated(shadowColor, isDark: isDark)
                      : AppShadows.card(shadowColor, isDark: isDark))
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                child: Padding(
                  padding: widget.padding ?? const EdgeInsets.all(16),
                  child: child,
                ),
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
