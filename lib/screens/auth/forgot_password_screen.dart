import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/common_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey         = GlobalKey<FormState>();
  bool _isSuccess        = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

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
    final sw  = MediaQuery.of(context).size.width;
    final sh  = MediaQuery.of(context).size.height;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kScaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.055),
            child: Column(
              children: [
                SizedBox(height: sh * 0.02),
                _buildBackButton(sw),
                SizedBox(height: sh * 0.05),
                _buildIcon(sw, sh),
                SizedBox(height: sh * 0.032),
                _isSuccess
                    ? _buildSuccessState(sw, sh)
                    : _buildFormState(sw, sh),
                SizedBox(height: sh * 0.032),
                _buildSignInRow(sw),
                SizedBox(height: sh * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Back button (text style, no arrow_back icon clutter) ──────────────────
  Widget _buildBackButton(double sw) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chevron_left_rounded,
                color: kPrimaryColor, size: sw * 0.06),
            Text(
              "Back to login",
              style: TextStyle(
                color: kPrimaryColor,
                fontSize: sw * 0.034,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Centered icon + title block ────────────────────────────────────────────
  Widget _buildIcon(double sw, double sh) {
    final isSuccess = _isSuccess;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          width:  sw * 0.22,
          height: sw * 0.22,
          decoration: BoxDecoration(
            color: isSuccess
                ? const Color(0xFF1D9E75).withOpacity(0.1)
                : kPrimaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSuccess
                ? Icons.check_circle_outline_rounded
                : Icons.lock_reset_rounded,
            color: isSuccess ? const Color(0xFF1D9E75) : kPrimaryColor,
            size: sw * 0.1,
          ),
        ),
        SizedBox(height: sh * 0.022),
        Text(
          isSuccess ? "Link Sent!" : "Forgot Password?",
          style: TextStyle(
            color: kTextPrimary,
            fontSize: sw * 0.062,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.1,
          ),
        ),
        SizedBox(height: sh * 0.008),
        Text(
          isSuccess
              ? "Check your inbox and follow\nthe instructions to reset your password."
              : "Enter your email and we'll send\na reset link right away.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: kTextSecondary,
            fontSize: sw * 0.033,
            height: 1.55,
          ),
        ),
      ],
    );
  }

  // ── Form state ─────────────────────────────────────────────────────────────
  Widget _buildFormState(double sw, double sh) {
    return Form(
      key: _formKey,
      child: AppCard(
        borderRadius: sw * 0.045,
        padding: EdgeInsets.all(sw * 0.055),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "EMAIL ADDRESS",
              style: TextStyle(
                color: kTextSecondary,
                fontSize: sw * 0.028,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: sh * 0.007),
            TextFormField(
              controller:   _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: kTextPrimary,
                fontSize: sw * 0.038,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText:   "Enter your email",
                filled:     true,
                fillColor:  kInputBg,
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: kPrimaryColor,
                  size: sw * 0.052,
                ),
                contentPadding:
                EdgeInsets.symmetric(vertical: sh * 0.018),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(sw * 0.032),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(sw * 0.032),
                  borderSide:
                  BorderSide(color: kPrimaryColor, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(sw * 0.032),
                  borderSide:
                  const BorderSide(color: Colors.red, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(sw * 0.032),
                  borderSide:
                  const BorderSide(color: Colors.red, width: 1.5),
                ),
              ),
              validator: (v) =>
              (v == null || !v.contains('@'))
                  ? "Enter a valid email"
                  : null,
            ),
            SizedBox(height: sh * 0.028),
            SizedBox(
              width:  double.infinity,
              height: sh * 0.065,
              child: ElevatedButton(
                onPressed: _handleReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(sw * 0.035),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Send Reset Link",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: sw * 0.04,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                    SizedBox(width: sw * 0.02),
                    Icon(Icons.send_rounded,
                        color: Colors.white, size: sw * 0.045),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Success state banner ───────────────────────────────────────────────────
  Widget _buildSuccessState(double sw, double sh) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        color: const Color(0xFF1D9E75).withOpacity(0.08),
        borderRadius: BorderRadius.circular(sw * 0.04),
        border: Border.all(
          color: const Color(0xFF1D9E75).withOpacity(0.25),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.mark_email_read_rounded,
            color: const Color(0xFF1D9E75),
            size: sw * 0.06,
          ),
          SizedBox(width: sw * 0.03),
          Expanded(
            child: Text(
              "A password reset link has been sent to your email. You'll be redirected to login shortly.",
              style: TextStyle(
                color: const Color(0xFF0F6E56),
                fontSize: sw * 0.032,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sign in row ────────────────────────────────────────────────────────────
  Widget _buildSignInRow(double sw) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Remember your password?",
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
