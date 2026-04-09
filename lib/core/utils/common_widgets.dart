import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? color;
  final List<BoxShadow>? boxShadow;
  final BoxBorder? border;
  final VoidCallback? onTap;
  final Duration? delay;

  const AppCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.boxShadow,
    this.border,
    this.onTap,
    this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme = theme.cardTheme;
    
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(borderRadius ?? 30.0),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.4 : 0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: border,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? 30.0),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    ).animate(delay: delay ?? 0.ms)
     .fadeIn(duration: 400.ms, curve: Curves.easeOut)
     .slideX(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}

// Keep compatible name for now
typedef GlassCard = AppCard;

class GradientAvatar extends StatelessWidget {
  final double radius;
  final String? imageUrl;
  final String? initials;

  final Color? backgroundColor;
  final Color? textColor;

  const GradientAvatar({
    super.key,
    required this.radius,
    this.imageUrl,
    this.initials,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? primaryColor.withOpacity(0.12),
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null && initials != null
          ? Text(
              initials!,
              style: TextStyle(
                color: textColor ?? primaryColor,
                fontSize: radius * 0.8,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    ).animate()
     .fadeIn(duration: 500.ms)
     .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), curve: Curves.easeOutBack);
  }
}
