import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';

class CustomLoader extends StatelessWidget {
  final String? message;
  final bool isOverlay;

  const CustomLoader({
    super.key,
    this.message,
    this.isOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    // Premium visuals block
    Widget loaderVisuals = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // 1. Outer subtle glow pulse
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.2),
                    Theme.of(context).primaryColor.withOpacity(0.0),
                  ],
                ),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 1.5.seconds)
              .fade(begin: 0.5, end: 1.0, duration: 1.5.seconds),

            // 2. Double animated gradient rings
            _buildRotatingRing(context, 64, 3, 1500.ms, false),
            _buildRotatingRing(context, 46, 2.5, 2000.ms, true),

            // 3. Center gradient logo/icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 800.ms),
          ],
        ),
        if (message != null) ...[
          const SizedBox(height: 24),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ).animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.2, end: 0.0, duration: 500.ms, curve: Curves.easeOutCirc),
          const SizedBox(height: 6),
          // Text(
          //   "Please wait a moment...",
          //   textAlign: TextAlign.center,
          //   style: const TextStyle(
          //     color: kTextSecondary,
          //     fontSize: 13,
          //     fontWeight: FontWeight.w400,
          //   ),
          // ).animate()
          //   .fadeIn(delay: 200.ms, duration: 500.ms),
        ],
      ],
    );

    if (isOverlay) {
      // Glassmorphism background for overlay mode
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(color: (Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white).withOpacity(0.2)),
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: loaderVisuals,
              ),
            ),
          ],
        ),
      );
    }

    return Center(child: loaderVisuals);
  }

  Widget _buildRotatingRing(BuildContext context, double size, double strokeWidth, Duration duration, bool reverse) {
    return SizedBox(
      width: size,
      height: size,
      child: ShaderMask(
        shaderCallback: (bounds) => SweepGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.0),
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
          transform: const GradientRotation(3.14 / 4),
        ).createShader(bounds),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: strokeWidth),
          ),
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat())
     .rotate(duration: duration, begin: reverse ? 1.0 : 0.0, end: reverse ? 0.0 : 1.0);
  }

  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent, // Disable default shadow backdrop to use blur
      builder: (context) => PopScope(
        canPop: false,
        child: CustomLoader(message: message, isOverlay: true),
      ),
    );
  }

  static void hide(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}
