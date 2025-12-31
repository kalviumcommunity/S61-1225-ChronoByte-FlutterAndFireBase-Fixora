import 'package:flutter/material.dart';
import 'header_section.dart';
import 'features_section.dart';
import 'steps_section.dart';
import 'report_now_section.dart';
import 'footer_section.dart';
import '../../widgets/animated_section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/auth_service.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndRedirect();
  }

  Future<void> _checkAuthAndRedirect() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final role = (doc.data()?['role']) as String?;
      final email = user.email ?? '';
      final isAdmin = (role == 'admin') || email.toLowerCase().endsWith('@fixoradmin.com');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, isAdmin ? '/admin' : '/home');
      });
    } catch (e) {
      final email = user.email ?? '';
      final isAdmin = email.toLowerCase().endsWith('@fixoradmin.com');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, isAdmin ? '/admin' : '/home');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSection(delay: const Duration(milliseconds: 0), child: HeaderSection()),
            const SizedBox(height: 20),

            AnimatedSection(delay: const Duration(milliseconds: 100), child: FeaturesSection()),
            const SizedBox(height: 20),

            AnimatedSection(delay: const Duration(milliseconds: 200), child: StepsSection()),
            const SizedBox(height: 20),

            AnimatedSection(delay: const Duration(milliseconds: 300), child: ReportNowSection()),
            const SizedBox(height: 20),

            AnimatedSection(delay: const Duration(milliseconds: 400), child: FooterSection()),
          ],
        ),
      ),
    );
  }
}
