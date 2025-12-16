import 'package:flutter/material.dart';

class TrackComplaintPage extends StatelessWidget {
  const TrackComplaintPage({super.key});

  Color get _primary => const Color(0xFF0D47A1);
  Color get _accent => const Color(0xFF1A73E8);
  Color get _bg => const Color(0xFFF4F7FB);

  @override
  Widget build(BuildContext context) {
    final complaints = [
      _ComplaintCardData(
        title: 'Large pothole on Main Street',
        id: 'CG-2024-001234',
        category: 'Roads & Potholes',
        status: 'In Progress',
        chipColor: const Color(0xFFFFF3E0),
        textColor: const Color(0xFFCC8A0E),
      ),
      _ComplaintCardData(
        title: 'No water supply for 3 days',
        id: 'CG-2024-001235',
        category: 'Water Supply',
        status: 'Pending',
        chipColor: const Color(0xFFFFEBEE),
        textColor: const Color(0xFFD32F2F),
      ),
      _ComplaintCardData(
        title: 'Street lights not working',
        id: 'CG-2024-001236',
        category: 'Street Lights',
        status: 'Resolved',
        chipColor: const Color(0xFFE7F5ED),
        textColor: const Color(0xFF2E7D32),
      ),
      _ComplaintCardData(
        title: 'Garbage not collected',
        id: 'CG-2024-001237',
        category: 'Sanitation & Garbage',
        status: 'In Progress',
        chipColor: const Color(0xFFFFF3E0),
        textColor: const Color(0xFFCC8A0E),
      ),
    ];

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(primary: _primary),
              const SizedBox(height: 26),
              _HeroSection(primary: _primary, accent: _accent),
              const SizedBox(height: 24),
              _DemoIds(accent: _primary),
              const SizedBox(height: 30),
              Text(
                'Recent Public Complaints',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B2430),
                ),
              ),
              const SizedBox(height: 14),
              ...complaints.map((c) => _ComplaintCard(data: c)).toList(),
              const SizedBox(height: 28),
              _Footer(primary: _primary, accent: _accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.primary, required this.accent});

  final Color primary;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(Icons.search, size: 42, color: primary),
        ),
        const SizedBox(height: 20),
        Text(
          'Track Your Complaint',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1B2430),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Enter your tracking ID to check the current status of your complaint.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF4F5B6C),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 22),
        _TrackingForm(primary: primary, accent: accent),
      ],
    );
  }
}

class _TrackingForm extends StatefulWidget {
  const _TrackingForm({required this.primary, required this.accent});

  final Color primary;
  final Color accent;

  @override
  State<_TrackingForm> createState() => _TrackingFormState();
}

class _TrackingFormState extends State<_TrackingForm> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: InputBorder.none,
                hintText: 'Enter Tracking ID (e.g., CG-2024-001234)',
                hintStyle: const TextStyle(color: Color(0xFF90A4AE)),
                prefixIcon: Icon(Icons.search, color: widget.primary),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.primary,
              padding: const EdgeInsets.symmetric(horizontal: 26),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            onPressed: () {
              // Hook up real tracking action here.
              FocusScope.of(context).unfocus();
            },
            child: const Text(
              'Track',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

class _DemoIds extends StatelessWidget {
  const _DemoIds({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        Text(
          'Try these demo tracking IDs:',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF54606E)),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: const [
            _Chip(text: 'CG-2024-001234'),
            _Chip(text: 'CG-2024-001235'),
            _Chip(text: 'CG-2024-001236'),
          ],
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF1B2430),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ComplaintCardData {
  const _ComplaintCardData({
    required this.title,
    required this.id,
    required this.category,
    required this.status,
    required this.chipColor,
    required this.textColor,
  });

  final String title;
  final String id;
  final String category;
  final String status;
  final Color chipColor;
  final Color textColor;
}

class _ComplaintCard extends StatelessWidget {
  const _ComplaintCard({required this.data});

  final _ComplaintCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  data.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B2430),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _StatusChip(
                label: data.status,
                color: data.chipColor,
                textColor: data.textColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data.id,
            style: const TextStyle(
              color: Color(0xFF607282),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.category,
            style: const TextStyle(
              color: Color(0xFF8A99AB),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.primary});

  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: primary,
          child: const Text(
            'CG',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu),
          color: const Color(0xFF1B2430),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.primary, required this.accent});

  final Color primary;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: primary,
                child: const Text(
                  'CG',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'CivicGrievance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1B2430),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'A transparent and efficient platform for citizens to raise and track civic complaints with Urban Local Bodies.',
                      style: TextStyle(color: Color(0xFF4F5B6C), height: 1.4),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Quick Links',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B2430),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '• Submit Complaint\n• Track Status\n• Admin Portal',
                      style: TextStyle(color: Color(0xFF4F5B6C), height: 1.5),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Contact',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B2430),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Helpline: 1800-XXX-XXXX\nEmail: support@civicgrievance.gov\nMon - Sat: 9AM - 6PM',
                      style: TextStyle(color: Color(0xFF4F5B6C), height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            '© 2025 CivicGrievance Portal. All rights reserved.',
            style: TextStyle(
              color: const Color(0xFF6D7A8B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
