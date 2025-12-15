import 'package:flutter/material.dart';

/// Shared color palette for authentication screens
class AuthColors {
  static const Color panelColor = Color(0xFF101d31);
  static const Color fieldColor = Color(0xFF16243a);
  static const Color accentStart = Color(0xFF1e9dfd);
  static const Color accentEnd = Color(0xFF1ab0ff);

  // Light theme colors
  static const Color lightPanelColor = Colors.white;
  static const Color lightFieldColor = Color(0xFFF5F7FA);
  static const Color lightTextColor = Color(0xFF1a1a1a);
  static const Color lightTextSecondary = Color(0xFF666666);

  static Color getPanelColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? panelColor
        : lightPanelColor;
  }

  static Color getFieldColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? fieldColor
        : lightFieldColor;
  }

  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : lightTextColor;
  }

  static Color getTextSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : lightTextSecondary;
  }
}

/// Returns a styled InputDecoration for auth form fields
InputDecoration authInputDecoration({
  required String label,
  required IconData icon,
  Widget? suffix,
  required BuildContext context,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(
      color: isDark ? Colors.white70 : AuthColors.lightTextSecondary,
    ),
    prefixIcon: Icon(
      icon,
      color: isDark ? Colors.white70 : AuthColors.lightTextSecondary,
    ),
    suffixIcon: suffix,
    filled: true,
    fillColor: AuthColors.getFieldColor(context),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.1),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: AuthColors.accentStart.withOpacity(0.8)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
  );
}

/// Reusable gradient button widget for auth screens
class AuthGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AuthGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AuthColors.accentStart, AuthColors.accentEnd],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AuthColors.accentStart.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_right_alt_rounded, size: 22),
          ],
        ),
      ),
    );
  }
}

/// Reusable auth screen header with logo and title
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AuthColors.accentStart.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.bolt_rounded,
                size: 26,
                color: Colors.lightBlueAccent,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'FlutterAuth',
              style: TextStyle(
                color: AuthColors.getTextColor(context),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Text(
          title,
          style: TextStyle(
            color: AuthColors.getTextColor(context),
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AuthColors.getTextSecondaryColor(context),
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

/// Reusable auth screen container with gradient background
class AuthScreenContainer extends StatelessWidget {
  final Widget child;

  const AuthScreenContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF5F7FA),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0c1626),
                    Color(0xFF0c1b2f),
                    Color(0xFF0f1f36),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFF5F7FA),
                    const Color(0xFFE8EEF5),
                    Colors.blue.shade50,
                  ],
                ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Reusable auth card container
class AuthCard extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const AuthCard({super.key, required this.child, this.maxWidth = 460.0});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width > 520 ? maxWidth : size.width * 0.9;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: cardWidth),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 26),
        decoration: BoxDecoration(
          color: isDark
              ? AuthColors.panelColor.withOpacity(0.9)
              : Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.35)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
