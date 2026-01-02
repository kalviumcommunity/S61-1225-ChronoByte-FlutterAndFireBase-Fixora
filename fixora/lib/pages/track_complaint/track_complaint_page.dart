import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../widgets/skeleton_loaders.dart';
import '../../utils/error_handler.dart';
import '../../theme/theme_provider.dart';
import '../../auth/auth_service.dart';

class TrackComplaintPage extends StatefulWidget {
  const TrackComplaintPage({super.key});

  @override
  State<TrackComplaintPage> createState() => _TrackComplaintPageState();
}

class _TrackComplaintPageState extends State<TrackComplaintPage> {
  String? _selectedCategory;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _seedDemoComplaint();
  }

  Future<void> _seedDemoComplaint() async {
    // Seed only in debug mode to avoid production test data
    if (!kDebugMode) return;

    const complaintId = 'FX-2025-001234';
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _TopBar(),
              const SizedBox(height: 26),
              const _HeroSection(),
              const SizedBox(height: 24),
              const _DemoIds(),
              const SizedBox(height: 12),
              const _CreateDemoButton(),
              const SizedBox(height: 30),
              Text(
                'Recent Public Complaints',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _StatusFilterButton(
                    selectedStatus: _selectedStatus,
                    onStatusChanged: (status) {
                      setState(() {
                        _selectedStatus = status;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  _CategoryFilterButton(
                    selectedCategory: _selectedCategory,
                    onCategoryChanged: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _ComplaintsList(
                selectedCategory: _selectedCategory,
                selectedStatus: _selectedStatus,
              ),
              const SizedBox(height: 28),
              const _Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusFilterButton extends StatefulWidget {
  const _StatusFilterButton({
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  final String? selectedStatus;
  final Function(String?) onStatusChanged;

  @override
  State<_StatusFilterButton> createState() => _StatusFilterButtonState();
}

class _StatusFilterButtonState extends State<_StatusFilterButton> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;
  bool _menuOpen = false;
  final GlobalKey _anchorKey = GlobalKey();

  Color get primary => Theme.of(context).colorScheme.primary;
  Color get accent => Theme.of(context).colorScheme.secondary;

  void _showMenu() {
    if (_menuOpen) return;
    _menuOpen = true;
    // Measure button position and screen width to avoid clipping
    final box = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    final buttonSize = box?.size ?? const Size(120, 40);
    final buttonPos = box?.localToGlobal(Offset.zero) ?? Offset.zero;
    final screenWidth = MediaQuery.of(context).size.width;
    const double desiredWidth = 360.0;
    const double padding = 16.0;
    final double menuWidth = desiredWidth > (screenWidth - padding * 2)
        ? (screenWidth - padding * 2)
        : desiredWidth;
    // Clamp offset so left >= padding and right <= screenWidth - padding
    final double minOffsetX = padding - buttonPos.dx;
    final double maxOffsetX =
        (screenWidth - padding - menuWidth) - buttonPos.dx;
    double offsetX = 0.0;
    offsetX = offsetX.clamp(minOffsetX, maxOffsetX);
    final double offsetY = buttonSize.height + 8.0;
    _entry = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _hideMenu,
            child: Stack(
              children: [
                CompositedTransformFollower(
                  link: _link,
                  offset: Offset(offsetX, offsetY),
                  showWhenUnlinked: false,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: menuWidth,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.flag_outlined,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Status',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _FilterChip(
                                label: 'All',
                                icon: Icons.apps,
                                isSelected: widget.selectedStatus == null,
                                onTap: () {
                                  widget.onStatusChanged(null);
                                  _hideMenu();
                                },
                                primary: Theme.of(context).colorScheme.primary,
                              ),
                              _FilterChip(
                                label: 'Pending',
                                icon: Icons.schedule,
                                isSelected: widget.selectedStatus == 'Pending',
                                onTap: () {
                                  widget.onStatusChanged('Pending');
                                  _hideMenu();
                                },
                                primary: const Color(0xFFD32F2F),
                              ),
                              _FilterChip(
                                label: 'In Progress',
                                icon: Icons.pending_actions,
                                isSelected:
                                    widget.selectedStatus == 'In Progress',
                                onTap: () {
                                  widget.onStatusChanged('In Progress');
                                  _hideMenu();
                                },
                                primary: const Color(0xFFCC8A0E),
                              ),
                              _FilterChip(
                                label: 'Resolved',
                                icon: Icons.check_circle,
                                isSelected: widget.selectedStatus == 'Resolved',
                                onTap: () {
                                  widget.onStatusChanged('Resolved');
                                  _hideMenu();
                                },
                                primary: const Color(0xFF2E7D32),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_entry!);
  }

  void _hideMenu() {
    if (_entry != null) {
      _entry!.remove();
      _entry = null;
      _menuOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasActive = widget.selectedStatus != null;
    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        onEnter: (_) => _showMenu(),
        child: GestureDetector(
          onTap: _showMenu,
          child: Container(
            key: _anchorKey,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.flag_outlined, size: 18, color: primary),
                const SizedBox(width: 8),
                Text(
                  'Status',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).iconTheme.color,
                ),
                if (hasActive) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A73E8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryFilterButton extends StatefulWidget {
  const _CategoryFilterButton({
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  final String? selectedCategory;
  final Function(String?) onCategoryChanged;

  @override
  State<_CategoryFilterButton> createState() => _CategoryFilterButtonState();
}

class _CategoryFilterButtonState extends State<_CategoryFilterButton> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;
  bool _menuOpen = false;
  final GlobalKey _anchorKey = GlobalKey();

  Color get primary => Theme.of(context).colorScheme.primary;
  Color get accent => Theme.of(context).colorScheme.secondary;

  void _showMenu() {
    if (_menuOpen) return;
    _menuOpen = true;
    // Measure button position and screen width to avoid clipping
    final box = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    final buttonSize = box?.size ?? const Size(120, 40);
    final buttonPos = box?.localToGlobal(Offset.zero) ?? Offset.zero;
    final screenWidth = MediaQuery.of(context).size.width;
    const double desiredWidth = 420.0;
    const double padding = 16.0;
    final double menuWidth = desiredWidth > (screenWidth - padding * 2)
        ? (screenWidth - padding * 2)
        : desiredWidth;

    // Calculate the best horizontal position
    double offsetX = 0;
    final buttonCenter = buttonPos.dx + (buttonSize.width / 2);
    final menuLeftEdge = buttonCenter - (menuWidth / 2);
    final menuRightEdge = menuLeftEdge + menuWidth;

    // Adjust if menu goes off screen to the left
    if (menuLeftEdge < padding) {
      offsetX = padding - buttonPos.dx;
    }
    // Adjust if menu goes off screen to the right
    else if (menuRightEdge > screenWidth - padding) {
      offsetX = (screenWidth - padding) - menuWidth - buttonPos.dx;
    }
    // Center align otherwise
    else {
      offsetX = -(menuWidth / 2 - buttonSize.width / 2);
    }

    const double offsetY = 44.0;
    _entry = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _hideMenu,
            child: Stack(
              children: [
                CompositedTransformFollower(
                  link: _link,
                  offset: Offset(offsetX, offsetY),
                  showWhenUnlinked: false,
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: menuWidth,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.category_outlined,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Category',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.start,
                            children: [
                              _FilterChip(
                                label: 'All',
                                icon: Icons.apps,
                                isSelected: widget.selectedCategory == null,
                                onTap: () {
                                  widget.onCategoryChanged(null);
                                  _hideMenu();
                                },
                                primary: primary,
                              ),
                              _FilterChip(
                                label: 'Road & Transport',
                                icon: Icons.directions_car,
                                isSelected:
                                    widget.selectedCategory ==
                                    'Road & Transportation',
                                onTap: () {
                                  widget.onCategoryChanged(
                                    'Road & Transportation',
                                  );
                                  _hideMenu();
                                },
                                primary: primary,
                              ),
                              _FilterChip(
                                label: 'Waste',
                                icon: Icons.delete_outline,
                                isSelected:
                                    widget.selectedCategory ==
                                    'Waste Management',
                                onTap: () {
                                  widget.onCategoryChanged('Waste Management');
                                  _hideMenu();
                                },
                                primary: primary,
                              ),
                              _FilterChip(
                                label: 'Water',
                                icon: Icons.water_drop_outlined,
                                isSelected:
                                    widget.selectedCategory == 'Water Supply',
                                onTap: () {
                                  widget.onCategoryChanged('Water Supply');
                                  _hideMenu();
                                },
                                primary: primary,
                              ),
                              _FilterChip(
                                label: 'Electricity',
                                icon: Icons.bolt,
                                isSelected:
                                    widget.selectedCategory == 'Electricity',
                                onTap: () {
                                  widget.onCategoryChanged('Electricity');
                                  _hideMenu();
                                },
                                primary: primary,
                              ),
                              _FilterChip(
                                label: 'Others',
                                icon: Icons.more_horiz,
                                isSelected: widget.selectedCategory == 'Others',
                                onTap: () {
                                  widget.onCategoryChanged('Others');
                                  _hideMenu();
                                },
                                primary: primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_entry!);
  }

  void _hideMenu() {
    if (_entry != null) {
      _entry!.remove();
      _entry = null;
      _menuOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasActive = widget.selectedCategory != null;
    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        onEnter: (_) => _showMenu(),
        child: GestureDetector(
          onTap: _showMenu,
          child: Container(
            key: _anchorKey,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.category_outlined, size: 18, color: primary),
                const SizedBox(width: 8),
                Text(
                  'Category',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).iconTheme.color,
                ),
                if (hasActive) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A73E8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.primary,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primary;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [primary, primary.withOpacity(0.85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected ? primary : Theme.of(context).dividerColor,
              width: isSelected ? 2 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComplaintsList extends StatelessWidget {
  const _ComplaintsList({this.selectedCategory, this.selectedStatus});

  final String? selectedCategory;
  final String? selectedStatus;

  Color _getStatusColor(String status, bool isDarkMode) {
    switch (status.toLowerCase()) {
      case 'pending':
        return isDarkMode ? const Color(0xFF3E2723) : const Color(0xFFFFEBEE);
      case 'in progress':
        return isDarkMode
            ? const Color(0xFF3E2723)
            : const Color(0xFFFFF3E0); // Adjust for dark mode
      case 'resolved':
        return isDarkMode ? const Color(0xFF1B5E20) : const Color(0xFFE7F5ED);
      default:
        return isDarkMode ? const Color(0xFF424242) : const Color(0xFFF5F5F5);
    }
  }

  Color _getStatusTextColor(String status, bool isDarkMode) {
    switch (status.toLowerCase()) {
      case 'pending':
        return isDarkMode ? const Color(0xFFFFCDD2) : const Color(0xFFD32F2F);
      case 'in progress':
        return isDarkMode ? const Color(0xFFFFE0B2) : const Color(0xFFCC8A0E);
      case 'resolved':
        return isDarkMode ? const Color(0xFFA5D6A7) : const Color(0xFF2E7D32);
      default:
        return isDarkMode ? const Color(0xFFBDBDBD) : const Color(0xFF666666);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('problems')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return TrackComplaintSkeleton(
            baseColor: isDarkMode
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFE0E0E0),
            highlightColor: isDarkMode
                ? const Color(0xFF3A3A3A)
                : const Color(0xFFF5F5F5),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to Load Complaints',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ErrorHandler.getErrorMessage(snapshot.error!),
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // The StreamBuilder will automatically retry on rebuild
                      // This is handled by the parent widget's refresh mechanism
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
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

        // Filter complaints client-side to avoid composite index requirement
        var complaints = snapshot.data!.docs.where((doc) {
          final data = doc.data();

          // Apply category filter
          if (selectedCategory != null &&
              data['category'] != selectedCategory) {
            return false;
          }

          // Apply status filter
          if (selectedStatus != null && data['status'] != selectedStatus) {
            return false;
          }

          return true;
        }).toList();

        return Column(
          children: complaints.map((doc) {
            final data = doc.data();
            final status = data['status'] ?? 'Pending';
            final chipColor = _getStatusColor(status, isDarkMode);
            final textColor = _getStatusTextColor(status, isDarkMode);

            return _ComplaintCard(
              data: _ComplaintCardData(
                title: data['issue'] ?? 'Unknown Issue',
                id: data['complaintId'] ?? 'FX-XXXXXX',
                category: data['category'] ?? 'Uncategorized',
                status: status,
                chipColor: chipColor,
                textColor: textColor,
                description: data['description'] ?? '',
                location: data['location'] ?? '',
              ),
              onViewDetails: () => _showComplaintDetails(context, data),
            );
          }).toList(),
        );
      },
    );
  }

  void _showComplaintDetails(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ComplaintDetailsSheet(data: data),
    );
  }
}

class _CreateDemoButton extends StatelessWidget {
  const _CreateDemoButton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final accent = Theme.of(context).colorScheme.secondary;
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
            color: Theme.of(context).textTheme.headlineMedium?.color,
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
        const _TrackingForm(),
      ],
    );
  }
}

class _TrackingForm extends StatefulWidget {
  const _TrackingForm();

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
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
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
              cursorColor:
                  Theme.of(context).textSelectionTheme.cursorColor ?? primary,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: InputBorder.none,
                hintText: 'Enter Tracking ID (e.g., FX-2024-001234)',
                hintStyle: TextStyle(color: Theme.of(context).hintColor),
                prefixIcon: Icon(Icons.search, color: primary),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
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
                  final data = snapshot.docs.first.data();
                  final status = data['status'] ?? 'Unknown';
                  final category = data['category'] ?? 'Uncategorized';
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Complaint Details'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Status:',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        Text(
                                          status,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Colors.green,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Category:',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        Text(
                                          category,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        );
                      },
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
  const _DemoIds();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        Text(
          'Try these demo tracking IDs:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: const [
            _Chip(text: 'FX-2024-342891'),
            _Chip(text: 'FX-2024-567123'),
            _Chip(text: 'FX-2024-789456'),
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
        color: Theme.of(context).cardColor,
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
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
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
    required this.description,
    required this.location,
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
  const _ComplaintCard({required this.data, required this.onViewDetails});

  final _ComplaintCardData data;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        data.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
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
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.category,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onViewDetails,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 18,
                        color: const Color(0xFF0D47A1),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'View Tracking Details',
                        style: TextStyle(
                          color: const Color(0xFF0D47A1),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: const Color(0xFF0D47A1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplaintDetailsSheet extends StatelessWidget {
  const _ComplaintDetailsSheet({required this.data});

  final Map<String, dynamic> data;

  Color _getStatusColor(String status) {
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

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      final date = (timestamp as Timestamp).toDate();
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = data['status'] ?? 'Unknown';
    final statusColor = _getStatusColor(status);

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.35,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D47A1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.assignment,
                              color: const Color(0xFF0D47A1),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Complaint Details',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1B2430),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data['complaintId'] ?? 'FX-XXXXXX',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              status.toLowerCase() == 'resolved'
                                  ? Icons.check_circle
                                  : status.toLowerCase() == 'in progress'
                                  ? Icons.pending_actions
                                  : Icons.schedule,
                              color: statusColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Status',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Details Sections
                      _DetailItem(
                        icon: Icons.category,
                        label: 'Category',
                        value: data['category'] ?? 'N/A',
                      ),
                      const SizedBox(height: 16),
                      _DetailItem(
                        icon: Icons.report_problem_outlined,
                        label: 'Issue Type',
                        value: data['issue'] ?? 'N/A',
                      ),
                      const SizedBox(height: 16),
                      _DetailItem(
                        icon: Icons.description_outlined,
                        label: 'Description',
                        value: data['description'] ?? 'No description provided',
                        maxLines: null,
                      ),
                      const SizedBox(height: 16),
                      _DetailItem(
                        icon: Icons.location_on_outlined,
                        label: 'Location',
                        value: data['location'] ?? 'N/A',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      _DetailItem(
                        icon: Icons.access_time,
                        label: 'Submitted On',
                        value: _formatTimestamp(data['createdAt']),
                      ),
                      const SizedBox(height: 32),

                      // Close Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D47A1),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.maxLines = 1,
  });

  final IconData icon;
  final String label;
  final String value;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF0D47A1)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B2430),
                    height: 1.4,
                  ),
                  maxLines: maxLines,
                  overflow: maxLines != null ? TextOverflow.ellipsis : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplaintCardOld extends StatelessWidget {
  const _ComplaintCardOld({required this.data});

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
  const _TopBar();

  void _onMenuSelected(BuildContext context, String value) async {
    if (value == 'profile') {
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
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: Colors.transparent,
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.png',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (value) => _onMenuSelected(context, value),
          icon: const Icon(Icons.menu),
          color: Theme.of(context).cardColor,
          itemBuilder: (context) => [
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
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final accent = Theme.of(context).colorScheme.secondary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
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
                backgroundColor: Colors.transparent,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CivicGrievance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A transparent and efficient platform for citizens to raise and track civic complaints with Urban Local Bodies.',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Quick Links',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '• Submit Complaint\n• Track Status\n• Admin Portal',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Contact',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Helpline: 1800-XXX-XXXX\nEmail: support@civicgrievance.gov\nMon - Sat: 9AM - 6PM',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        height: 1.5,
                      ),
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
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
