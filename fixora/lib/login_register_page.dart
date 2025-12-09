import 'package:flutter/material.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({Key? key}) : super(key: key);

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String username = '';

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 1200;

    // Responsive padding
    final horizontalPadding = isSmallScreen
        ? 16.0
        : (isMediumScreen ? 32.0 : 48.0);
    final cardPadding = isSmallScreen ? 20.0 : (isMediumScreen ? 32.0 : 40.0);
    final maxCardWidth = isSmallScreen
        ? double.infinity
        : (isMediumScreen ? 500.0 : 600.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Login' : 'Register'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: screenHeight * 0.02,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxCardWidth,
              minHeight: screenHeight * 0.4,
            ),
            child: Card(
              elevation: isSmallScreen ? 4 : 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
              ),
              child: Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isLogin)
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Username',
                            labelStyle: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                          onChanged: (val) => username = val,
                          validator: (val) => val == null || val.isEmpty
                              ? 'Enter username'
                              : null,
                        ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),
                        style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (val) => email = val,
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Enter email' : null,
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),
                        style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                        obscureText: true,
                        onChanged: (val) => password = val,
                        validator: (val) => val == null || val.isEmpty
                            ? 'Enter password'
                            : null,
                      ),
                      SizedBox(height: isSmallScreen ? 20 : 24),
                      SizedBox(
                        width: double.infinity,
                        height: isSmallScreen ? 48 : 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Navigate to dashboard
                              Navigator.pushNamed(
                                context,
                                '/dashboard',
                                arguments: {
                                  'email': email,
                                  'username': username,
                                },
                              );
                            }
                          },
                          child: Text(
                            isLogin ? 'Login' : 'Register',
                            style: TextStyle(fontSize: isSmallScreen ? 16 : 18),
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      TextButton(
                        onPressed: toggleForm,
                        child: Text(
                          isLogin
                              ? "Don't have an account? Register"
                              : 'Already have an account? Login',
                          style: TextStyle(fontSize: isSmallScreen ? 13 : 15),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
