import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/theme_toggle_button.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _loading = false;
  bool _obscurePass = true;

  @override
  void dispose() {
    _usernameCtl.dispose();
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      // Check if username already exists
      final usernameExists = await AuthService.instance.isUsernameExists(
        _usernameCtl.text.trim(),
      );
      if (usernameExists) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Username already taken')));
        setState(() => _loading = false);
        return;
      }

      await AuthService.instance.signUp(
        email: _emailCtl.text.trim(),
        password: _passCtl.text,
        username: _usernameCtl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/report');
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
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
            title: 'Create Account',
            subtitle: 'Fill in your details to get started',
          ),
          const SizedBox(height: 32),
          AuthCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AuthColors.fieldColor,
                        borderRadius: BorderRadius.circular(48),
                        border: Border.all(color: Colors.white12, width: 1.2),
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: Colors.white70,
                        size: 42,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _usernameCtl,
                    decoration: authInputDecoration(
                      label: 'Username',
                      icon: Icons.person_outline_rounded,
                      context: context,
                    ),
                    style: TextStyle(color: AuthColors.getTextColor(context)),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Username is required';
                      }
                      if (v.length < 3) {
                        return 'Username must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
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
                        AuthService.instance.validatePassword(v ?? ''),
                  ),
                  const SizedBox(height: 18),
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : AuthGradientButton(
                          label: 'Create Account',
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
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.lightBlueAccent,
                      ),
                      child: const Text('Already have an account? Sign In'),
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
