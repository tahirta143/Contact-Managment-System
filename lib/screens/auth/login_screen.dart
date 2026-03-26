import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/common_widgets.dart';
import '../../providers/auth_provider.dart';
import '../main_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // In a real app, this would call the API
      // For now, let's mock a successful login
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
      
      // Real implementation would be:
      // await ref.read(authProvider.notifier).login(_emailController.text, _passwordController.text);
      // if (ref.read(authProvider).user != null) {
      //   if (mounted) {
      //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
      //   }
      // }
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
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: availableHeight * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: kTextPrimary),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: kCardBg,
                        child: Icon(Icons.person, color: kTextSecondary, size: 20),
                      ),
                    ],
                  ),
                  SizedBox(height: availableHeight * 0.05),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_person_rounded, color: kPrimaryColor, size: 35),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.welcomeBack,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(color: kTextPrimary),
                  ),
                  Text(
                    AppStrings.signInSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kTextSecondary),
                  ),
                  SizedBox(height: availableHeight * 0.05),
                  
                  // FORM CARD
                  AppCard(
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
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Email is required";
                            if (!value.contains('@')) return "Enter a valid email";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            hintText: "Password",
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: kTextSecondary,
                              ),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Password is required";
                            if (value.length < 6) return "Min 6 characters";
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                            child: const Text(
                              AppStrings.forgotPassword,
                              style: TextStyle(color: kTextSecondary, fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _handleLogin,
                          child: const Text(AppStrings.login),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: availableHeight * 0.04),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(AppStrings.dontHaveAccount, style: TextStyle(color: kTextSecondary)),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                        child: const Text(
                          "SIGN UP",
                          style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
