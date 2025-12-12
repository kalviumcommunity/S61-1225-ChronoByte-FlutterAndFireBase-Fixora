import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Colors.blue;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(primary),
              const SizedBox(height: 20),
              _summaryCards(primary),
              const SizedBox(height: 20),
              _searchAndFilters(),
              const SizedBox(height: 20),
              _complaintsTable(),
              const SizedBox(height: 40),
              _footer(primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.dashboard_customize, color: primary, size: 28),
            ),
            const SizedBox(width: 12),
            const Text(
              "Admin Dashboard",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          "Manage and resolve citizen complaints",
          style: TextStyle(fontSize: 14, color: Colors.grey),
        )
      ],
    );
  }

  Widget _summaryCards(Color primary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _summaryCard("Total Complaints", "5", Icons.list_alt, primary),
        _summaryCard("Pending", "2", Icons.error_outline, Colors.red),
        _summaryCard("In Progress", "2", Icons.timelapse, Colors.amber),
        _summaryCard("Resolved", "1", Icons.check_circle_outline, Colors.green),
      ],
    );
  }

  Widget _summaryCard(String title, String count, IconData icon, Color iconColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(count,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                Icon(icon, color: iconColor, size: 28)
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _searchAndFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: "Search by ID, title, or citizen name",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _dropdown("All Status", Icons.filter_alt),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _dropdown("All Categories", Icons.category),
            ),
          ],
        )
      ],
    );
  }

  Widget _dropdown(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Row(children: [Icon(icon), SizedBox(width: 8), Text(title)]),
          items: [],
          onChanged: (value) {},
        ),
      ),
    );
  }

  Widget _complaintsTable() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        children: [
          _tableHeader(),
          const Divider(),
          _tableRow("CG-2024-001234", "Large pothole", "In Progress", Colors.amber),
          _tableRow("CG-2024-001235", "No water supply", "Pending", Colors.red),
          _tableRow("CG-2024-001236", "Streetlight issue", "Resolved", Colors.green),
          _tableRow("CG-2024-001237", "Garbage issue", "In Progress", Colors.amber),
          _tableRow("CG-2024-001238", "Blocked drain", "Pending", Colors.red),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text("Tracking ID", style: TextStyle(fontWeight: FontWeight.bold)),
        Text("Title", style: TextStyle(fontWeight: FontWeight.bold)),
        Text("Status", style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _tableRow(String id, String title, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(id),
          Text(title, overflow: TextOverflow.ellipsis),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(status, style: TextStyle(color: statusColor)),
          )
        ],
      ),
    );
  }

  Widget _footer(Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 18, backgroundColor: primary, child: const Text("CG", style: TextStyle(color: Colors.white))),
            const SizedBox(width: 10),
            const Text(
              "CivicGrievance",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          "A transparent and efficient platform for citizens to raise and track civic complaints.",
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        const Text("Quick Links", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text("Submit Complaint"),
        const Text("Track Status"),
        const Text("Admin Portal"),
        const SizedBox(height: 20),
        const Text("Contact", style: TextStyle(fontWeight: FontWeight.bold)),
        const Text("Helpline: 1800-XXX-XXXX"),
        const Text("Email: support@civicgrievance.gov"),
        const Text("Mon - Sat: 9AM – 6PM"),
        const SizedBox(height: 20),
        const Text("© 2025 CivicGrievance Portal. All rights reserved.", style: TextStyle(fontSize: 12, color: Colors.grey))
      ],
    );
  }
}