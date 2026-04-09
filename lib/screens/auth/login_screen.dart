import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/common_widgets.dart';
import '../../providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey            = GlobalKey<FormState>();
  bool _isPasswordVisible   = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      final authState = ref.read(authProvider);
      if (authState.user != null) {
        if (mounted) {
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
                    SizedBox(height: sh * 0.032),
                    _buildFormCard(sw, sh),
                    _buildDivider(sw, sh),
                    _buildSocialRow(sw, sh),
                    SizedBox(height: sh * 0.012),
                    _buildSignUpRow(sw),
                    SizedBox(height: sh * 0.012),
                    _buildDeveloperCredit(sw),
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

  // ── Colored header with lock icon + title ──────────────────────────────────
  Widget _buildHeader(double sw, double sh, double top) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        sw * 0.06,
        top + sh * 0.04,
        sw * 0.06,
        sh * 0.042,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Frosted icon box
          Container(
            width:  sw * 0.16,
            height: sw * 0.16,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(sw * 0.045),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.lock_person_rounded,
              color: Colors.white,
              size: sw * 0.075,
            ),
          ),
          SizedBox(height: sh * 0.018),
          Text(
            AppStrings.welcomeBack,
            style: TextStyle(
              color: Colors.white,
              fontSize: sw * 0.055,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: sh * 0.005),
          Text(
            AppStrings.signInSubtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: sw * 0.032,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Main form card ─────────────────────────────────────────────────────────
  Widget _buildFormCard(double sw, double sh) {
    return AppCard(
      borderRadius: sw * 0.045,
      padding: EdgeInsets.all(sw * 0.055),
      child: Column(
        children: [
          _buildInputField(
            label:      "EMAIL ADDRESS",
            hint:       "Enter your email",
            controller: _emailController,
            icon:       Icons.email_outlined,
            sw: sw, sh: sh,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return "Email is required";
              if (!v.contains('@'))       return "Enter a valid email";
              return null;
            },
          ),
          SizedBox(height: sh * 0.018),
          _buildInputField(
            label:      "PASSWORD",
            hint:       "Enter your password",
            controller: _passwordController,
            icon:       Icons.lock_outline,
            sw: sw, sh: sh,
            obscureText: !_isPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                size: sw * 0.052,
              ),
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return "Password is required";
              if (v.length < 6)          return "Min 6 characters";
              return null;
            },
          ),
          SizedBox(height: sh * 0.008),

          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                AppStrings.forgotPassword,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: sw * 0.032,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: sh * 0.024),

          SizedBox(
            width: double.infinity,
            height: sh * 0.065,
            child: Consumer(
              builder: (context, ref, child) {
                final authState = ref.watch(authProvider);
                return ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: authState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.login,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sw * 0.042,
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

  // ── Reusable labeled input field ───────────────────────────────────────────
  Widget _buildInputField({
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
            color: Theme.of(context).textTheme.bodyMedium?.color,
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
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: sw * 0.038,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText:   hint,
            filled:     true,
            fillColor:  Theme.of(context).cardTheme.color,
            prefixIcon: Icon(icon, color: Theme.of(context).primaryColor, size: sw * 0.052),
            suffixIcon: suffixIcon,
            contentPadding: EdgeInsets.symmetric(
              vertical: sh * 0.018,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  // ── "Or continue with" divider ─────────────────────────────────────────────
  Widget _buildDivider(double sw, double sh) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: sh * 0.022),
      child: Row(
        children: [
          Expanded(child: Divider(color: Theme.of(context).dividerColor.withOpacity(0.2), thickness: 0.5)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
            child: Text(
              "or continue with",
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: sw * 0.03),
            ),
          ),
          Expanded(child: Divider(color: Theme.of(context).dividerColor.withOpacity(0.2), thickness: 0.5)),
        ],
      ),
    );
  }

  // ── Social login buttons ───────────────────────────────────────────────────
  Widget _buildSocialRow(double sw, double sh) {
    return Row(
      children: [
        Expanded(child: _buildSocialBtn("Google",  Icons.g_mobiledata,  Colors.red,   sw, sh)),
        SizedBox(width: sw * 0.03),
        Expanded(child: _buildSocialBtn("Apple",   Icons.apple,          Colors.black, sw, sh)),
      ],
    );
  }

  Widget _buildSocialBtn(
      String label, IconData icon, Color iconColor, double sw, double sh,
      ) {
    return AppCard(
      borderRadius: sw * 0.032,
      child: InkWell(
        borderRadius: BorderRadius.circular(sw * 0.032),
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: sh * 0.018),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: sw * 0.055),
              SizedBox(width: sw * 0.02),
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: sw * 0.036,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sign up row ────────────────────────────────────────────────────────────
  Widget _buildSignUpRow(double sw) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.dontHaveAccount,
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: sw * 0.034),
        ),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SignupScreen()),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.only(left: sw * 0.01),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            "Sign Up",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: sw * 0.034,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // ── Developer credit ───────────────────────────────────────────────────────
  Widget _buildDeveloperCredit(double sw) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Developed by",
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: sw * 0.034),
        ),
        TextButton(
          onPressed: () async {
            final url = Uri.parse('https://afaqtechnologies.com.pk/');
            await launchUrl(url, mode: LaunchMode.externalApplication);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.only(left: sw * 0.01),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            "Afaq Technologies",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: sw * 0.034,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
