import 'package:flutter/material.dart';

/// Skeleton Loaders for the entire Fixora app
/// Provides reusable shimmer loading placeholders for various UI components

/// Base Skeleton Loader with shimmer effect
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final Color baseColor;
  final Color highlightColor;

  const SkeletonLoader({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  }) : super(key: key);

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                _animationController.value - 0.5,
                _animationController.value,
                _animationController.value + 0.5,
              ],
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Complaint Card Skeleton
class ComplaintCardSkeleton extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;

  const ComplaintCardSkeleton({
    Key? key,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonLoader(
                  width: 200,
                  height: 16,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
                SkeletonLoader(
                  width: 60,
                  height: 24,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SkeletonLoader(
              width: double.infinity,
              height: 14,
              baseColor: baseColor,
              highlightColor: highlightColor,
            ),
            const SizedBox(height: 8),
            SkeletonLoader(
              width: 250,
              height: 14,
              baseColor: baseColor,
              highlightColor: highlightColor,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SkeletonLoader(
                  width: 100,
                  height: 12,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
                const SizedBox(width: 16),
                SkeletonLoader(
                  width: 100,
                  height: 12,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Profile Section Skeleton
class ProfileSectionSkeleton extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;

  const ProfileSectionSkeleton({
    Key? key,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Row(
            children: [
              SkeletonLoader(
                width: 80,
                height: 80,
                borderRadius: const BorderRadius.all(Radius.circular(40)),
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(
                      width: 150,
                      height: 18,
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                    ),
                    const SizedBox(height: 8),
                    SkeletonLoader(
                      width: 200,
                      height: 14,
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Profile Info Items
          for (int i = 0; i < 3; i++) ...[
            SkeletonLoader(
              width: double.infinity,
              height: 16,
              baseColor: baseColor,
              highlightColor: highlightColor,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

/// Admin Dashboard Skeleton
class AdminDashboardSkeleton extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;

  const AdminDashboardSkeleton({
    Key? key,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Summary Cards Row
          Row(
            children: [
              for (int i = 0; i < 4; i++) ...[
                Expanded(
                  child: SkeletonLoader(
                    width: double.infinity,
                    height: 100,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                  ),
                ),
                if (i < 3) const SizedBox(width: 12),
              ],
            ],
          ),
          const SizedBox(height: 24),
          // Complaints List
          for (int i = 0; i < 5; i++) ...[
            ComplaintCardSkeleton(
              baseColor: baseColor,
              highlightColor: highlightColor,
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

/// Summary Grid Skeleton (for admin dashboard stats)
class SummaryGridSkeleton extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;

  const SummaryGridSkeleton({
    Key? key,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
          4,
          (index) => SkeletonLoader(
            width: double.infinity,
            height: 120,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),
        ),
      ),
    );
  }
}

/// Track Complaint Page Skeleton
class TrackComplaintSkeleton extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;

  const TrackComplaintSkeleton({
    Key? key,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar skeleton
          SkeletonLoader(
            width: double.infinity,
            height: 50,
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),
          const SizedBox(height: 16),
          // Filter bar skeleton
          Row(
            children: [
              Expanded(
                child: SkeletonLoader(
                  width: double.infinity,
                  height: 40,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
              ),
              const SizedBox(width: 8),
              SkeletonLoader(
                width: 100,
                height: 40,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Complaint cards
          for (int i = 0; i < 5; i++) ...[
            ComplaintCardSkeleton(
              baseColor: baseColor,
              highlightColor: highlightColor,
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

/// Form Input Skeleton
class FormFieldSkeleton extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;

  const FormFieldSkeleton({
    Key? key,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(
            width: 100,
            height: 14,
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),
          const SizedBox(height: 8),
          SkeletonLoader(
            width: double.infinity,
            height: 50,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),
        ],
      ),
    );
  }
}

/// List Item Skeleton
class ListItemSkeleton extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;

  const ListItemSkeleton({
    Key? key,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          SkeletonLoader(
            width: 50,
            height: 50,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(
                  width: 150,
                  height: 16,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
                const SizedBox(height: 8),
                SkeletonLoader(
                  width: 200,
                  height: 12,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Minimal Loading Skeleton (circular progress with text)
class MinimalLoadingSkeleton extends StatelessWidget {
  final String? message;
  final Color? primaryColor;

  const MinimalLoadingSkeleton({
    Key? key,
    this.message = 'Loading...',
    this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              primaryColor ?? Theme.of(context).colorScheme.primary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
