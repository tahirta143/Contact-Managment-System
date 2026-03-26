import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/common_widgets.dart';
import '../../providers/auth_provider.dart';
import '../main_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'User';

  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      // Mock signup
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account created successfully!"),
          backgroundColor: kButtonColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Simulate successful signup
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
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
                  SizedBox(height: availableHeight * 0.02),
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
                  SizedBox(height: availableHeight * 0.02),
                  Text(
                    AppStrings.createAccount,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(color: kTextPrimary),
                  ),
                  Text(
                    "Fill the details to create a new user",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kTextSecondary),
                  ),
                  SizedBox(height: availableHeight * 0.03),
                  
                  // FORM CARD
                  AppCard(
                    padding: EdgeInsets.all(size.width * 0.06),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            hintText: "Full Name",
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) => value == null || value.isEmpty ? "Name is required" : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            hintText: "Email",
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) => (value == null || !value.contains('@')) ? "Enter a valid email" : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            hintText: "Password",
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          validator: (value) => (value == null || value.length < 6) ? "Min 6 chars" : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            hintText: "Confirm Password",
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          validator: (value) => value != _passwordController.text ? "Passwords do not match" : null,
                        ),
                        const SizedBox(height: 24),
                        const Text("Role", style: TextStyle(color: kTextSecondary, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildRoleToggle("Admin"),
                            const SizedBox(width: 12),
                            _buildRoleToggle("User"),
                          ],
                        ),
                        SizedBox(height: availableHeight * 0.03),
                        ElevatedButton(
                          onPressed: _handleSignup,
                          child: const Text(AppStrings.signUp),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: availableHeight * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?", style: TextStyle(color: kTextSecondary)),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "LOG IN",
                          style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: availableHeight * 0.02),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildRoleToggle(String role) {
    bool isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryColor : kInputBg,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Center(
            child: Text(
              role,
              style: TextStyle(
                color: isSelected ? Colors.white : kTextSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
