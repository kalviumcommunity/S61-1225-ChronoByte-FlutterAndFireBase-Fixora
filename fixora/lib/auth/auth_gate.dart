import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';
import '../pages/landing_page/landing.dart';
import '../pages/user_dashboard/dashboard.dart';

/// Simple AuthGate that listens to `authStateChanges` and returns
/// - [LandingPage] when the user is not signed in
/// - [UserDashboard] when the user is signed in
/// - a loading spinner while waiting for the stream
class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Auth error: ${snapshot.error}')),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const LandingPage();
        }

        // Signed in - show dashboard screen (which will fetch the username)
        return const DashboardScreen();
      },
    );
  }
}
