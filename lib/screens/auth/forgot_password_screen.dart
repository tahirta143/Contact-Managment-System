import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/common_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSuccess = false;

  void _handleReset() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSuccess = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final availableHeight = size.height - padding.top - padding.bottom;

    return Scaffold(
      backgroundColor: kScaffoldBg,
      body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
            child: Column(
              children: [
                SizedBox(height: availableHeight * 0.02),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: kTextPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Spacer(flex: 1),
                if (!_isSuccess) ...[
                  const Icon(Icons.lock_reset_rounded, color: kPrimaryColor, size: 80),
                  SizedBox(height: availableHeight * 0.03),
                  Text(
                    "Forgot Password?",
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: kTextPrimary,
                      fontSize: size.width * 0.08,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Enter your email to receive a reset link",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kTextSecondary),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: availableHeight * 0.05),
                  Form(
                    key: _formKey,
                    child: AppCard(
                      padding: EdgeInsets.all(size.width * 0.06),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              hintText: "Email",
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) => (value == null || !value.contains('@')) ? "Enter a valid email" : null,
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _handleReset,
                            child: const Text("Send Reset Link"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  const Icon(Icons.check_circle_outline_rounded, color: kPrimaryColor, size: 80),
                  const SizedBox(height: 24),
                  Text(
                    "Reset link sent!",
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(color: kTextPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Please check your email to reset your password. You will be redirected back to login shortly.",
                    style: TextStyle(color: kTextSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
    );
  }
}
