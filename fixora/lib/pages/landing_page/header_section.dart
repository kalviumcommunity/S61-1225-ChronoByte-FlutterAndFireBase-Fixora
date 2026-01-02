import 'package:flutter/material.dart';
import '../../auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HeaderSection extends StatefulWidget {
  const HeaderSection({super.key});

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  Future<void> _goToDashboard(BuildContext context) async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final role = doc.data()?['role'] as String?;
      final email = user.email ?? '';
      final isAdmin =
          role == 'admin' || email.toLowerCase().endsWith('@fixoradmin.com');

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, isAdmin ? '/admin' : '/home');
    } catch (_) {
      final email = user.email ?? '';
      final isAdmin = email.toLowerCase().endsWith('@fixoradmin.com');

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, isAdmin ? '/admin' : '/home');
    }
  }

  Future<void> _goToTrackStatus(BuildContext context) async {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    if (!mounted) return;
    Navigator.pushNamed(context, '/track');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  "Logo",
                  style: TextStyle(
                    color: Color(0xFF1976D2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              PopupMenuButton<String>(
                icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                onSelected: (value) {
                  switch (value) {
                    case 'login':
                      Navigator.pushNamed(context, '/login');
                      break;
                    case 'signup':
                      Navigator.pushNamed(context, '/signup');
                      break;
                    case 'track':
                      _goToTrackStatus(context);
                      break;
                    case 'submit':
                      Navigator.pushNamed(context, '/login');
                      break;
                    case 'dashboard':
                      _goToDashboard(context);
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'login',
                    child: ListTile(
                      leading: Icon(Icons.login),
                      title: Text('Login'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'signup',
                    child: ListTile(
                      leading: Icon(Icons.person_add),
                      title: Text('Sign Up'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'track',
                    child: ListTile(
                      leading: Icon(Icons.track_changes),
                      title: Text('Track Status'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'submit',
                    child: ListTile(
                      leading: Icon(Icons.send),
                      title: Text('Submit Complaint'),
                    ),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'dashboard',
                    child: ListTile(
                      leading: Icon(Icons.dashboard),
                      title: Text('Dashboard'),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 25),

          const Text(
            "Your Voice Matters.\nWe Listen.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            "Report civic issues directly to your local authorities. Track updates in real time.",
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text(
                "Submit Complaint",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                _goToTrackStatus(context);
              },
              child: const Text(
                "Track Status",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
