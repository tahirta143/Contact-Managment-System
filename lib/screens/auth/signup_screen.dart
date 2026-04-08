import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/common_widgets.dart';
import '../main_screen.dart';
import 'login_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController            = TextEditingController();
  final _emailController           = TextEditingController();
  final _passwordController        = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey                   = GlobalKey<FormState>();
  String _selectedRole             = 'User';
  bool _showPassword               = false;
  bool _showConfirm                = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authProvider.notifier).register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _selectedRole,
      );

      final authState = ref.read(authProvider);
      if (authState.user != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Account created successfully!"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
      } else if (authState.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authState.error!), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw  = MediaQuery.of(context).size.width;
    final sh  = MediaQuery.of(context).size.height;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(sw, sh, top),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: sw * 0.055),
                child: Column(
                  children: [
                    SizedBox(height: sh * 0.028),
                    _buildFormCard(sw, sh),
                    SizedBox(height: sh * 0.01),
                    _buildSignInRow(sw),
                    SizedBox(height: sh * 0.04),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header wave ────────────────────────────────────────────────────────────
  Widget _buildHeader(double sw, double sh, double top) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        sw * 0.06, top + sh * 0.032, sw * 0.06, sh * 0.036,
      ),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(sw * 0.085),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width:  sw * 0.15,
            height: sw * 0.15,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(sw * 0.042),
              border: Border.all(
                color: Colors.white.withOpacity(0.28),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.person_add_alt_1_rounded,
              color: Colors.white,
              size: sw * 0.07,
            ),
          ),
          SizedBox(height: sh * 0.016),
          Text(
            AppStrings.createAccount,
            style: TextStyle(
              color: Colors.white,
              fontSize: sw * 0.052,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: sh * 0.005),
          Text(
            "Fill in the details to get started",
            style: TextStyle(
              color: Colors.white.withOpacity(0.68),
              fontSize: sw * 0.03,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Form card ──────────────────────────────────────────────────────────────
  Widget _buildFormCard(double sw, double sh) {
    return AppCard(
      borderRadius: sw * 0.045,
      padding: EdgeInsets.all(sw * 0.055),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildField(
            label: "FULL NAME",
            hint: "Enter your full name",
            controller: _nameController,
            icon: Icons.person_outline,
            sw: sw, sh: sh,
            validator: (v) =>
            v == null || v.isEmpty ? "Name is required" : null,
          ),
          SizedBox(height: sh * 0.016),
          _buildField(
            label: "EMAIL ADDRESS",
            hint: "Enter your email",
            controller: _emailController,
            icon: Icons.email_outlined,
            sw: sw, sh: sh,
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
            (v == null || !v.contains('@')) ? "Enter a valid email" : null,
          ),
          SizedBox(height: sh * 0.016),
          _buildField(
            label: "PASSWORD",
            hint: "Min 6 characters",
            controller: _passwordController,
            icon: Icons.lock_outline,
            sw: sw, sh: sh,
            obscureText: !_showPassword,
            suffixIcon: _eyeIcon(_showPassword, () =>
                setState(() => _showPassword = !_showPassword), sw),
            validator: (v) =>
            (v == null || v.length < 6) ? "Min 6 characters" : null,
          ),
          SizedBox(height: sh * 0.016),
          _buildField(
            label: "CONFIRM PASSWORD",
            hint: "Re-enter your password",
            controller: _confirmPasswordController,
            icon: Icons.lock_outline,
            sw: sw, sh: sh,
            obscureText: !_showConfirm,
            suffixIcon: _eyeIcon(_showConfirm, () =>
                setState(() => _showConfirm = !_showConfirm), sw),
            validator: (v) =>
            v != _passwordController.text ? "Passwords do not match" : null,
          ),
          SizedBox(height: sh * 0.024),

          // Role selector
          Text(
            "SELECT ROLE",
            style: TextStyle(
              color: kTextSecondary,
              fontSize: sw * 0.028,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: sh * 0.01),
          Row(
            children: [
              _buildRoleBtn("Admin", sw, sh),
              SizedBox(width: sw * 0.03),
              _buildRoleBtn("User",  sw, sh),
            ],
          ),
          SizedBox(height: sh * 0.028),

          SizedBox(
            width: double.infinity,
            height: sh * 0.065,
            child: Consumer(
              builder: (context, ref, child) {
                final authState = ref.watch(authProvider);
                return ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(sw * 0.035),
                    ),
                    elevation: 0,
                  ),
                  child: authState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.signUp,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sw * 0.04,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.4,
                        ),
                      ),
                      SizedBox(width: sw * 0.02),
                      Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: sw * 0.048),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Role toggle button ─────────────────────────────────────────────────────
  Widget _buildRoleBtn(String role, double sw, double sh) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: sh * 0.055,
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryColor : kInputBg,
            borderRadius: BorderRadius.circular(sw * 0.06),
          ),
          child: Center(
            child: Text(
              role,
              style: TextStyle(
                color: isSelected ? Colors.white : kTextSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: sw * 0.036,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Shared field builder ───────────────────────────────────────────────────
  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required double sw,
    required double sh,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: kTextSecondary,
            fontSize: sw * 0.028,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: sh * 0.007),
        TextFormField(
          controller:   controller,
          obscureText:  obscureText,
          keyboardType: keyboardType,
          style: TextStyle(
            color: kTextPrimary,
            fontSize: sw * 0.038,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText:    hint,
            filled:      true,
            fillColor:   kInputBg,
            prefixIcon:  Icon(icon, color: kPrimaryColor, size: sw * 0.052),
            suffixIcon:  suffixIcon,
            contentPadding: EdgeInsets.symmetric(vertical: sh * 0.018),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(sw * 0.032),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(sw * 0.032),
              borderSide: BorderSide(color: kPrimaryColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(sw * 0.032),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(sw * 0.032),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _eyeIcon(bool visible, VoidCallback onTap, double sw) {
    return IconButton(
      icon: Icon(
        visible ? Icons.visibility : Icons.visibility_off,
        color: kTextSecondary,
        size: sw * 0.052,
      ),
      onPressed: onTap,
    );
  }

  // ── Sign in row ────────────────────────────────────────────────────────────
  Widget _buildSignInRow(double sw) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account?",
          style: TextStyle(color: kTextSecondary, fontSize: sw * 0.034),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: EdgeInsets.only(left: sw * 0.01),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            "Sign In",
            style: TextStyle(
              color: kPrimaryColor,
              fontSize: sw * 0.034,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
