import 'package:flutter/material.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text("Logo", style: TextStyle(color: Colors.blue.shade700)),
              ),
              const SizedBox(width: 12),
              Text("CivicGrievance",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700)),
            ],
          ),

          const SizedBox(height: 10),
          Text(
            "A transparent and efficient platform to file and track civic complaints.",
            style: TextStyle(color: Colors.grey.shade700),
          ),

          const SizedBox(height: 20),
          const Text("Quick Links",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text("• Submit Complaint",
              style: TextStyle(color: Colors.grey.shade700)),
          Text("• Track Status", style: TextStyle(color: Colors.grey.shade700)),

          const SizedBox(height: 20),
          const Text("Contact",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text("Helpline: 1800-XXX-XXXX",
              style: TextStyle(color: Colors.grey.shade700)),
          Text("Email: support@fixora.gov",
              style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}
