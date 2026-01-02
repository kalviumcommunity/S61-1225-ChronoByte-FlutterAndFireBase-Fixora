import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/admin_dashboard/admin_dashboard.dart';
import '../pages/profile_Info/profile.dart';
import '../pages/track_complaint/track_complaint_page.dart';
import '../theme/theme_provider.dart' show AppTheme, ThemeProvider;

class AdminBottomNavbarPage extends StatefulWidget {
  const AdminBottomNavbarPage({Key? key}) : super(key: key);

  @override
  State<AdminBottomNavbarPage> createState() => _AdminBottomNavbarPageState();
}

class _AdminBottomNavbarPageState extends State<AdminBottomNavbarPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminDashboardPage(),
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
          body: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
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
                icon: Icon(Icons.admin_panel_settings_outlined),
                activeIcon: Icon(Icons.admin_panel_settings),
                label: 'Admin',
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
