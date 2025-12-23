import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_service.dart';
import '../pages/landing_page/landing.dart';
import '../pages/user_dashboard/dashboard.dart';
import '../pages/admin_dashboard/admin_dashboard.dart';

/// Simple AuthGate that listens to `authStateChanges` and returns
/// - [LandingPage] when the user is not signed in
/// - [UserDashboard] when the user is signed in
/// - [AdminDashboardPage] when the user's email domain matches admin domain
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

        // Fetch users doc to check role; fallback to email domain check
        return FutureBuilder(
          future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (userSnap.hasError) {
              // If fetching user doc fails, fallback to domain check
              final email = user.email ?? '';
              final isAdminDom = email.toLowerCase().endsWith('@fixoradmin.com');
              if (isAdminDom) return const AdminDashboardPage();
              return const DashboardScreen();
            }

            final doc = userSnap.data as DocumentSnapshot<Map<String, dynamic>>?;
            final role = doc?.data()?['role'] as String?;
            final email = user.email ?? '';
            final isAdmin = (role == 'admin') || email.toLowerCase().endsWith('@fixoradmin.com');

            // Debug logging for admin detection
            // Prints will appear in the debug console when running the app
            // Example output: "AuthGate: user=user@fixoradmin.com, role=admin, isAdmin=true"
            try {
              // ignore: avoid_print
              print('AuthGate: user=${user.email}, role=$role, isAdmin=$isAdmin');
            } catch (_) {}

            if (isAdmin) return const AdminDashboardPage();
            return const DashboardScreen();
          },
        );
      },
    );
  }
}
