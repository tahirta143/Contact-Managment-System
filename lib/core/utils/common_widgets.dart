import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
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
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? kPrimaryColor.withValues(alpha: 0.1),
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null && initials != null
          ? Text(
              initials!,
              style: TextStyle(
                color: textColor ?? kPrimaryColor,
                fontSize: radius * 0.8,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }
}

class AnimatedCountText extends StatelessWidget {
  final int count;
  final TextStyle style;
  final Duration duration;

  const AnimatedCountText({
    super.key,
    required this.count,
    required this.style,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: count.toDouble()),
      duration: duration,
      curve: Curves.easeOutExpo,
      builder: (context, value, child) {
        return Text(
          value.toInt().toString().padLeft(2, '0'),
          style: style,
        );
      },
    );
  }
}
