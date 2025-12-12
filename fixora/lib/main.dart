import 'package:flutter/material.dart';
import 'auth/login_page.dart';
import 'auth/signup_page.dart';
import 'widgets/user_dashboard.dart';
import 'pages/landing_page/landing.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/user_dashboard/dashboard.dart';
import 'pages/admin_dashboard/admin_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fixora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      initialRoute: '/',
      routes: {
        // '/': (context) => const HomePage(),
        // '/': (context) => const LandingPage(),
        // '/': (context) => const DashboardScreen(),
        '/': (context) => const AdminDashboardPage(),
        '/signup': (context) => const SignupPage(),
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return UserDashboard(
            email: args?['email'] ?? '',
            username: args?['username'],
          );
        },
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 1200;

    // Responsive padding
    final horizontalPadding = isSmallScreen
        ? 24.0
        : (isMediumScreen ? 48.0 : 64.0);
    final verticalPadding = isSmallScreen ? 24.0 : 32.0;

    // Responsive button width
    final maxButtonWidth = isSmallScreen
        ? double.infinity
        : (isMediumScreen ? 400.0 : 500.0);

    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to Fixora'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600,
              minHeight: screenHeight * 0.5,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to Fixora!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 24 : 28,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.04),
                SizedBox(
                  width: maxButtonWidth,
                  height: isSmallScreen ? 48 : 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text(
                      'Login / Register',
                      style: TextStyle(fontSize: isSmallScreen ? 16 : 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
