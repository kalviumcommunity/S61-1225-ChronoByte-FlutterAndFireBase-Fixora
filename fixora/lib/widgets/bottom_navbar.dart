import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/raise_issue/raise_issue_page.dart';
import '../pages/profile_Info/profile.dart';
import '../pages/user_dashboard/dashboard.dart';
import '../pages/track_complaint/track_complaint_page.dart';
import '../theme/theme_provider.dart' show AppTheme, ThemeProvider;

class BottomNavbarPage extends StatefulWidget {
  const BottomNavbarPage({Key? key}) : super(key: key);

  @override
  State<BottomNavbarPage> createState() => _BottomNavbarPageState();
}

class _BottomNavbarPageState extends State<BottomNavbarPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const RaiseIssuePage(),
    const DashboardScreen(),
    const TrackComplaintPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: isDark
                ? AppTheme.darkSurface
                : AppTheme.lightSurface,
            selectedItemColor: isDark
                ? AppTheme.darkPrimary
                : AppTheme.lightPrimary,
            unselectedItemColor: isDark
                ? AppTheme.darkTextSecondary
                : AppTheme.lightTextSecondary,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline),
                activeIcon: Icon(Icons.add_circle),
                label: 'Submit Complaint',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.track_changes_outlined),
                activeIcon: Icon(Icons.track_changes),
                label: 'Tracking',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
