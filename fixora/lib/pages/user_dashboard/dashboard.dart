import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDark ? _darkTheme() : _lightTheme(),
      home: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,

          title: Text(
            "Dashboard",
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "theme") {
                  setState(() {
                    isDark = !isDark;
                  });
                } else if (value == "logout") {
                  // Logout handling
                }
              },
              icon: Icon(Icons.menu, color: Theme.of(context).primaryColorDark),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: "theme",
                  child: Row(
                    children: [
                      Icon(Icons.brightness_6),
                      SizedBox(width: 10),
                      Text("Toggle Theme"),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: "logout",
                  child: Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 10),
                      Text("Logout"),
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
            children: [
              // Search Placeholder
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(30),
                ),
              ),

              const SizedBox(height: 30),

              // Grid Section
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 30,
                  children: [
                    _categoryItem("Roads & Transportation"),
                    _categoryItem("Waste Management"),
                    _categoryItem("Water Supply"),
                    _categoryItem("Drainage & Sewage"),
                    _categoryItem("Noise & Air Pollution"),
                    _categoryItem("Parks & Public Spaces"),
                    _categoryItem("Public Safety"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // FIXED CATEGORY ITEM (NO OVERFLOW)
  Widget _categoryItem(String title) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            // Image Placeholder
            Container(
              height: constraints.maxHeight * 0.55,
              width: constraints.maxHeight * 0.55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  "No Image",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
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
                  color: Theme.of(context).primaryColorDark,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }

  // LIGHT THEME
  ThemeData _lightTheme() {
    return ThemeData(
      primaryColor: Colors.blue,
      primaryColorDark: Colors.blue[900],
      scaffoldBackgroundColor: Colors.white,
    );
  }

  // DARK THEME
  ThemeData _darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.blue,
      primaryColorDark: Colors.white,
      scaffoldBackgroundColor: Colors.grey[900],
    );
  }
}
