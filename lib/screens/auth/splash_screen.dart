import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../main_screen.dart';
import 'login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _ringCtrl;
  late AnimationController _spinCtrl;
  late AnimationController _progressCtrl;
  late AnimationController _particleCtrl;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _progressAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.68), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 0.68, end: 0.84), weight: 23),
      TweenSequenceItem(tween: Tween(begin: 0.84, end: 1.0),  weight: 22),
    ]).animate(CurvedAnimation(
      parent: _progressCtrl,
      curve: Curves.easeOut,
    ));

    Future.delayed(400.ms, () {
      if (mounted) _progressCtrl.forward();
    });

    _navigateToNext();
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _spinCtrl.dispose();
    _progressCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  void _navigateToNext() async {
    // Wait for the minimal splash duration
    await Future.delayed(2800.ms);
    if (!mounted) return;

    // Wait for auth initialization to finish if it's still loading
    bool isAuthLoading = ref.read(authProvider).isLoading;
    int maxWaitMs = 5000;
    int waitedMs = 0;
    
    while (isAuthLoading && waitedMs < maxWaitMs) {
      await Future.delayed(100.ms);
      if (!mounted) return;
      waitedMs += 100;
      isAuthLoading = ref.read(authProvider).isLoading;
    }

    if (!mounted) return;
    final finalUser = ref.read(authProvider).user;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: 600.ms,
        pageBuilder: (_, __, ___) =>
        finalUser != null ? const MainScreen() : const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Stack(
        children: [
          // Canvas-style ring + particle layer
          AnimatedBuilder(
            animation: Listenable.merge([_ringCtrl, _particleCtrl]),
            builder: (_, __) => CustomPaint(
              size: Size(sw, sh),
              painter: _SplashPainter(
                ringProgress:     _ringCtrl.value,
                particleProgress: _particleCtrl.value,
              ),
            ),
          ),

          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(sw),
                SizedBox(height: sh * 0.032),
                Text(
                  AppStrings.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: sw * 0.062,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
                )
                    .animate()
                    .slideY(
                  begin: 0.5, end: 0,
                  duration: 600.ms,
                  delay: 850.ms,
                  curve: Curves.easeOutCubic,
                )
                    .fade(duration: 500.ms, delay: 850.ms),

                SizedBox(height: sh * 0.008),

                Text(
                  AppStrings.tagline,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: sw * 0.032,
                    letterSpacing: 0.6,
                  ),
                )
                    .animate()
                    .fade(duration: 600.ms, delay: 1050.ms),
              ],
            ),
          ),

          // Progress bar
          Positioned(
            bottom: sh * 0.062,
            left: 0, right: 0,
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _progressAnim,
                  builder: (_, __) => Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: SizedBox(
                        width: sw * 0.28,
                        height: 3,
                        child: LinearProgressIndicator(
                          value: _progressAnim.value,
                          backgroundColor: Colors.white.withOpacity(0.14),
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: sh * 0.012),
                Text(
                  "LOADING...",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.38),
                    fontSize: sw * 0.026,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            )
                .animate()
                .fade(duration: 500.ms, delay: 1200.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(double sw) {
    final boxSize = sw * 0.22;

    return SizedBox(
      width:  boxSize + 44,
      height: boxSize + 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer spinning ring
          AnimatedBuilder(
            animation: _spinCtrl,
            builder: (_, child) => Transform.rotate(
              angle: _spinCtrl.value * 2 * pi,
              child: child,
            ),
            child: Container(
              width:  boxSize + 30,
              height: boxSize + 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.22),
                  width: 1.5,
                ),
              ),
            ),
          ),
          // Inner counter-spin dashed feel
          AnimatedBuilder(
            animation: _spinCtrl,
            builder: (_, child) => Transform.rotate(
              angle: -_spinCtrl.value * 2 * pi * 0.65,
              child: child,
            ),
            child: Container(
              width:  boxSize + 14,
              height: boxSize + 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                  width: 1,
                ),
              ),
            ),
          ),
          // Logo box
          Container(
            width:  boxSize,
            height: boxSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(sw * 0.058),
            ),
            child: Center(
              child: Text(
                "C",
                style: TextStyle(
                  fontSize: boxSize * 0.54,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                  height: 1,
                ),
              ),
            ),
          )
              .animate()
              .scale(
            begin: const Offset(0.3, 0.3),
            end: const Offset(1, 1),
            duration: 800.ms,
            delay: 200.ms,
            curve: Curves.elasticOut,
          )
              .rotate(begin: -0.1, end: 0, duration: 700.ms, delay: 200.ms)
              .fade(duration: 300.ms, delay: 200.ms),

          // Gold accent dot
          Positioned(
            right: 8, bottom: 8,
            child: Container(
              width: 14, height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                shape: BoxShape.circle,
                border: Border.all(color: kPrimaryColor, width: 2.5),
              ),
            )
                .animate(delay: 900.ms)
                .scale(
              begin: const Offset(0, 0),
              duration: 400.ms,
              curve: Curves.elasticOut,
            )
                .then()
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.35, 1.35),
              duration: 900.ms,
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }
}

// ── CustomPainter: rings + floating particles ──────────────────────────────
class _SplashPainter extends CustomPainter {
  final double ringProgress;
  final double particleProgress;

  static final _rnd = Random(42);
  static final _particles = List.generate(22, (i) => _P(
    x:     _rnd.nextDouble(),
    y:     0.35 + _rnd.nextDouble() * 0.55,
    size:  1.5  + _rnd.nextDouble() * 3.0,
    speed: 0.6  + _rnd.nextDouble() * 0.9,
    alpha: 0.15 + _rnd.nextDouble() * 0.4,
    phase: _rnd.nextDouble(),
    drift: (_rnd.nextDouble() - 0.5) * 0.015,
  ));

  const _SplashPainter({
    required this.ringProgress,
    required this.particleProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  * 0.5;
    final cy = size.height * 0.44;
    final maxRings = [60.0, 105.0, 155.0, 210.0];

    // Pulsing rings
    for (int i = 0; i < 4; i++) {
      final p = (ringProgress + i * 0.25) % 1.0;
      final r = maxRings[i] * p;
      final a = pow(1 - p, 1.6) * 0.18;
      canvas.drawCircle(
        Offset(cx, cy), r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = Colors.white.withOpacity(a.toDouble()),
      );
    }

    // Floating particles with sinusoidal drift
    for (final p in _particles) {
      final prog = (particleProgress * p.speed + p.phase) % 1.0;
      final curY = p.y - prog * 0.52;
      final curX = p.x + sin(particleProgress * pi * 2 + p.phase * 10) * p.drift;
      final fadeIn  = (prog / 0.15).clamp(0.0, 1.0);
      final fadeOut = prog > 0.75 ? ((1.0 - prog) / 0.25).clamp(0.0, 1.0) : 1.0;

      canvas.drawCircle(
        Offset(curX * size.width, curY * size.height),
        p.size * 0.5,
        Paint()..color = Colors.white.withOpacity(p.alpha * fadeIn * fadeOut),
      );
    }
  }

  @override
  bool shouldRepaint(_SplashPainter old) =>
      old.ringProgress     != ringProgress ||
          old.particleProgress != particleProgress;
}

class _P {
  final double x, y, size, speed, alpha, phase, drift;
  const _P({
    required this.x, required this.y, required this.size,
    required this.speed, required this.alpha, required this.phase,
    required this.drift,
  });
}
