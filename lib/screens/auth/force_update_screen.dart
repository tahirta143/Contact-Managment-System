import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';

class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
            kPrimaryColor.withOpacity(0.05),
            Colors.white,
          ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon / Illustration
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.system_update_rounded,
                size: 80,
                color: kPrimaryColor,
              ),
            )
            .animate()
            .scale(duration: 600.ms, curve: Curves.elasticOut)
            .shake(delay: 800.ms, duration: 500.ms),

            const SizedBox(height: 48),

            // Text content
            Text(
              "Update Required",
              style: TextStyle(
                fontSize: sw * 0.065,
                fontWeight: FontWeight.bold,
                color: kTextPrimary,
              ),
            ).animate().fade(delay: 200.ms).slideY(begin: 0.3, end: 0),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "This version of the app is no longer supported. Please install the latest version to continue.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: kTextSecondary,
                  height: 1.5,
                ),
              ),
            ).animate().fade(delay: 400.ms).slideY(begin: 0.3, end: 0),

            const SizedBox(height: 60),
            
            // Action Button - Only show if you want a download link
            // Since we decided to just disable, we will leave this empty
            // or put a "Contact Support" button here.
            
            const SizedBox(height: 24),

            Text(
              "Contact Admin if you have issues.",
              style: TextStyle(
                color: kTextSecondary.withOpacity(0.7),
                fontSize: 13,
              ),
            ).animate().fade(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
