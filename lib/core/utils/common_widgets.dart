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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultCardColor = isDark
        ? const Color(0xFF1A1D27)   // dark card bg
        : Colors.white;             // light card bg

    final shadowColor = isDark
        ? Colors.black.withOpacity(0.25)
        : Colors.black.withOpacity(0.05);

    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? defaultCardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
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
      backgroundColor: backgroundColor ?? kPrimaryColor.withOpacity(0.1),
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
