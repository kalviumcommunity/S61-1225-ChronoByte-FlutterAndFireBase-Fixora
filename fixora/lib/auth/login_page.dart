import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/theme_toggle_button.dart';
import '../utils/error_handler.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _loading = false;
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.instance.signIn(
        email: _emailCtl.text.trim(),
        password: _passCtl.text,
      );
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email?.toLowerCase() ?? '';

      ErrorHandler.showSuccess(context, message: 'Login successful!');

      if (email.endsWith('@fixoradmin.com')) {
        Navigator.pushNamedAndRemoveUntil(context, '/admin', (r) => false);
      } else {
        // Route to the root which is guarded by AuthGate for regular users
        Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
      }
    } on Exception catch (e) {
      if (!mounted) return;
      ErrorHandler.showError(
        context,
        title: 'Login Failed',
        message: ErrorHandler.getErrorMessage(e),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(right: 16, top: 8),
              child: ThemeToggleButton(),
            ),
          ),
          const SizedBox(height: 20),
          const AuthHeader(
            title: 'Welcome Back',
            subtitle: 'Enter your credentials to access your account',
          ),
          const SizedBox(height: 32),
          AuthCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _emailCtl,
                    decoration: authInputDecoration(
                      label: 'Email Address',
                      icon: Icons.mail_outline_rounded,
                      context: context,
                    ),
                    style: TextStyle(color: AuthColors.getTextColor(context)),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter email' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passCtl,
                    decoration: authInputDecoration(
                      label: 'Password',
                      icon: Icons.lock_outline_rounded,
                      context: context,
                      suffix: IconButton(
                        onPressed: () =>
                            setState(() => _obscurePass = !_obscurePass),
                        icon: Icon(
                          _obscurePass
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AuthColors.getTextSecondaryColor(context),
                        ),
                      ),
                    ),
                    style: TextStyle(color: AuthColors.getTextColor(context)),
                    obscureText: _obscurePass,
                    validator: (v) =>
                        (v == null || v.length < 6) ? '6+ chars' : null,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.lightBlueAccent,
                      ),
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : AuthGradientButton(
                          label: 'Sign In',
                          onPressed: _submit,
                        ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Container(height: 1, color: Colors.white12),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'or',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      Expanded(
                        child: Container(height: 1, color: Colors.white12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.lightBlueAccent,
                      ),
                      child: const Text('Don\'t have an account? Sign Up'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'By continuing, you agree to our Terms of Service and Privacy Policy',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
