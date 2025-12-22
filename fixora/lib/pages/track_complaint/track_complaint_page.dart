import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrackComplaintPage extends StatefulWidget {
  const TrackComplaintPage({super.key});

  @override
  State<TrackComplaintPage> createState() => _TrackComplaintPageState();
}

class _TrackComplaintPageState extends State<TrackComplaintPage> {
  Color get _primary => const Color(0xFF0D47A1);
  Color get _accent => const Color(0xFF1A73E8);
  Color get _bg => const Color(0xFFF4F7FB);

  @override
  void initState() {
    super.initState();
    _seedDemoComplaint();
  }

  Future<void> _seedDemoComplaint() async {
    // Seed only in debug mode to avoid production test data
    if (!kDebugMode) return;

    const complaintId = 'CG-2025-001234';
    try {
      final existing = await FirebaseFirestore.instance
          .collection('problems')
          .where('complaintId', isEqualTo: complaintId)
          .limit(1)
          .get();

      if (existing.docs.isEmpty) {
        final userId = FirebaseAuth.instance.currentUser?.uid ?? 'demo';
        await FirebaseFirestore.instance.collection('problems').doc().set({
          'complaintId': complaintId,
          'userId': userId,
          'category': 'Road & Transportation',
          'issue': 'Potholes',
          'description': 'Demo seeded complaint to verify tracking flow.',
          'location': 'Main Street, Ward 12',
          'status': 'Pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {
      // Silent fail in debug; this is only a helper
    }
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 12),
              const _CreateDemoButton(),
              const SizedBox(height: 30),
              Text(
                'Recent Public Complaints',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B2430),
                ),
              ),
              const SizedBox(height: 14),
              _ComplaintsList(),
              const SizedBox(height: 28),
              _Footer(primary: _primary, accent: _accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComplaintsList extends StatelessWidget {
  const _ComplaintsList();

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFEBEE);
      case 'in progress':
        return const Color(0xFFFFF3E0);
      case 'resolved':
        return const Color(0xFFE7F5ED);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFD32F2F);
      case 'in progress':
        return const Color(0xFFCC8A0E);
      case 'resolved':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFF666666);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('problems')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No complaints available yet',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        }

        final complaints = snapshot.data!.docs;

        return Column(
          children: complaints.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'Pending';
            final chipColor = _getStatusColor(status);
            final textColor = _getStatusTextColor(status);

            return _ComplaintCard(
              data: _ComplaintCardData(
                title: data['issue'] ?? 'Unknown Issue',
                id: data['complaintId'] ?? 'CG-XXXXXX',
                category: data['category'] ?? 'Uncategorized',
                status: status,
                chipColor: chipColor,
                textColor: textColor,
                description: data['description'] ?? '',
                location: data['location'] ?? '',
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _CreateDemoButton extends StatelessWidget {
  const _CreateDemoButton();

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.center,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Create Sample Complaint (Debug)'),
        onPressed: () async {
          final now = DateTime.now();
          final year = now.year;
          final random = DateTime.now().millisecondsSinceEpoch % 1000000;
          final complaintId = 'CG-$year-${random.toString().padLeft(6, '0')}';

          await FirebaseFirestore.instance.collection('problems').doc().set({
            'complaintId': complaintId,
            'userId': user.uid,
            'category': 'Waste Management',
            'issue': 'Garbage Overflow',
            'description':
                'Sample complaint created for testing via Track page.',
            'location': 'N/A',
            'status': 'Pending',
            'createdAt': FieldValue.serverTimestamp(),
          });

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sample complaint created: $complaintId')),
            );
          }
        },
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
              cursorColor: Colors.black,
              style: const TextStyle(color: Colors.black),
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
            onPressed: () async {
              final trackingId = _controller.text.trim();
              if (trackingId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a tracking ID')),
                );
                return;
              }

              try {
                final snapshot = await FirebaseFirestore.instance
                    .collection('problems')
                    .where('complaintId', isEqualTo: trackingId)
                    .limit(1)
                    .get();

                if (snapshot.docs.isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Complaint ID not found')),
                    );
                  }
                } else {
                  final data =
                      snapshot.docs.first.data() as Map<String, dynamic>;
                  final status = data['status'] ?? 'Unknown';
                  final category = data['category'] ?? 'Uncategorized';
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Status: $status • $category'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error searching complaint: $e')),
                  );
                }
              }

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
            _Chip(text: 'CG-2024-342891'),
            _Chip(text: 'CG-2024-567123'),
            _Chip(text: 'CG-2024-789456'),
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
    this.description = '',
    this.location = '',
  });

  final String title;
  final String id;
  final String category;
  final String status;
  final Color chipColor;
  final Color textColor;
  final String description;
  final String location;
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
