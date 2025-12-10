import 'package:flutter/material.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Chip(
            backgroundColor: Colors.blue.shade50,
            label: Text("Features",
                style: TextStyle(color: Colors.blue.shade700)),
          ),

          const SizedBox(height: 10),
          const Text(
            "A Complete Solution for Civic Issues",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),
          Text(
            "Our platform bridges the gap between citizens and authorities — ensuring your voice is heard.",
            style: TextStyle(color: Colors.grey.shade700),
          ),

          const SizedBox(height: 20),
          _featureCard(Icons.description, "Easy Complaint Filing",
              "Submit complaints with photos, location, and description."),
          _featureCard(Icons.location_on, "Location-Based Tracking",
              "Accurate tracking using GPS integration."),
          _featureCard(Icons.notifications, "Real-Time Notifications",
              "Get notified instantly at every update."),
          _featureCard(Icons.dashboard, "Transparent Dashboard",
              "Track complaint status with complete visibility."),
          _featureCard(Icons.security, "Secure & Anonymous",
              "Your identity remains fully protected."),
          _featureCard(Icons.flash_on, "Quick Resolution",
              "Issues are routed instantly to the right department."),
        ],
      ),
    );
  }

  Widget _featureCard(IconData icon, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc,
                    style:
                        TextStyle(color: Colors.grey.shade700, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
