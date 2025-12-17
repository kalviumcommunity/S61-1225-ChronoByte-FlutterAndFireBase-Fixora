import 'package:flutter/material.dart';
import 'header_section.dart';
import 'features_section.dart';
import 'steps_section.dart';
import 'report_now_section.dart';
import 'footer_section.dart';
import '../../widgets/animated_section.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

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
