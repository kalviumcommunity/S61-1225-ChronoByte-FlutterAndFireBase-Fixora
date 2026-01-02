import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_service.dart';
import '../../theme/theme_provider.dart';
import '../../widgets/skeleton_loaders.dart';
import 'category_issues_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _username;
  bool _loadingUsername = true;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    setState(() => _loadingUsername = true);
    try {
      final name = await AuthService.instance.getUsernameForCurrentUser();
      setState(() => _username = name);
    } catch (e) {
      // ignore errors
    } finally {
      setState(() => _loadingUsername = false);
    }
  }

  void _onMenuSelected(String value) async {
    if (value == 'theme') {
      // toggle app theme via ThemeProvider
      context.read<ThemeProvider>().toggleTheme();
    } else if (value == 'profile') {
      Navigator.pushNamed(context, '/profile');
    } else if (value == 'logout') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await AuthService.instance.signOut();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = AuthService.instance.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Dashboard',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _onMenuSelected,
            icon: const Icon(Icons.menu),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'theme',
                child: Row(
                  children: [
                    Icon(Icons.brightness_6),
                    SizedBox(width: 10),
                    Text('Toggle Theme'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 10),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 10),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            if (_loadingUsername)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('Loading...'),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _username != null && _username!.isNotEmpty
                      ? 'Welcome back, ${_username!}'
                      : 'Hello',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            if (userEmail.isNotEmpty)
              Text(userEmail, style: Theme.of(context).textTheme.bodyMedium),

            const SizedBox(height: 20),

            // Search Placeholder

            const SizedBox(height: 30),

            // Grid Section
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 30,
                children: [
                  _categoryItem('Roads & Transportation'),
                  _categoryItem('Waste Management'),
                  _categoryItem('Water Supply'),
                  _categoryItem('Drainage & Sewage'),
                  _categoryItem('Noise & Air Pollution'),
                  _categoryItem('Parks & Public Spaces'),
                  _categoryItem('Public Safety'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Map category titles to image assets
  String _getImageForCategory(String title) {
    switch (title) {
      case 'Roads & Transportation':
        return 'assets/images/Road.jpeg';
      case 'Waste Management':
        return 'assets/images/Dustbin.jpeg';
      case 'Water Supply':
        return 'assets/images/water.jpeg';
      case 'Drainage & Sewage':
        return 'assets/images/Drainage.jpeg';
      case 'Noise & Air Pollution':
        return 'assets/images/Pollution.jpeg';
      case 'Parks & Public Spaces':
        return 'assets/images/Parks.jpeg';
      case 'Public Safety':
        return 'assets/images/logo.png';
      default:
        return 'assets/images/logo.png';
    }
  }

  // FIXED CATEGORY ITEM (NO OVERFLOW)
  Widget _categoryItem(String title) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imagePath = _getImageForCategory(title);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryIssuesPage(categoryTitle: title),
              ),
            );
          },
          child: Column(
            children: [
              // Image Container
              Container(
                height: constraints.maxHeight * 0.55,
                width: constraints.maxHeight * 0.55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Theme.of(context).cardColor,
                        child: Center(
                          child: Text(
                            'Image Not Found',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: constraints.maxHeight * 0.08),

              // Title (No Overflow)
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
