import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blur;
  final Color? color;
  final Color? borderColor;
  final bool interactive;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 18.0,
    this.blur = 12.0,
    this.color,
    this.borderColor,
    this.interactive = false,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.interactive) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
          child: Container(
            padding: widget.padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.color ?? AppColors.glassBackground,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: widget.borderColor ?? AppColors.glassBorder,
                width: 1.5,
              ),
            ),
            child: widget.child,
          ),
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: widget.interactive && _hovered
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.16),
                    blurRadius: 26,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
            child: Container(
              padding: widget.padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.color ?? AppColors.glassBackground,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: widget.borderColor ?? AppColors.glassBorder,
                  width: 1.5,
                ),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
