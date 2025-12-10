import 'package:flutter/material.dart';
import 'header_section.dart';
import 'features_section.dart';
import 'steps_section.dart';
import 'report_now_section.dart';
import 'footer_section.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            HeaderSection(),
            SizedBox(height: 20),
            FeaturesSection(),
            SizedBox(height: 20),
            StepsSection(),
            SizedBox(height: 20),
            ReportNowSection(),
            SizedBox(height: 20),
            FooterSection(),
          ],
        ),
      ),
    );
  }
}
