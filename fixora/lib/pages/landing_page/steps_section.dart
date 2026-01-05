import 'package:flutter/material.dart';

class StepsSection extends StatelessWidget {
  const StepsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Chip(
            backgroundColor: Colors.blue.shade50,
            label: Text(
              "How It Works",
              style: TextStyle(color: Colors.blue.shade700),
            ),
          ),

          const SizedBox(height: 10),
          const Text(
            "Simple Steps to Get Results",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),
          Text(
            "A streamlined process ensures your concerns are addressed quickly.",
            style: TextStyle(color: Colors.grey.shade700),
          ),

          const SizedBox(height: 25),
          _stepItem(
            Icons.edit_document,
            "File Complaint",
            "Describe your issue with photos and location.",
          ),
          _stepItem(
            Icons.compare_arrows,
            "Auto-Routing",
            "Complaint is routed automatically to the correct department.",
          ),
          _stepItem(
            Icons.track_changes,
            "Track Progress",
            "Monitor real-time updates from your dashboard.",
          ),
          _stepItem(
            Icons.check_circle,
            "Resolution",
            "You’re notified once your issue is resolved.",
          ),
        ],
      ),
    );
  }

  Widget _stepItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Icon(icon, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
