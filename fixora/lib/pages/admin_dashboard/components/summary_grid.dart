import 'package:flutter/material.dart';

class SummaryGrid extends StatelessWidget {
  final int total;
  final int pending;
  final int inProgress;
  final int resolved;
  final Color primary;

  const SummaryGrid({
    Key? key,
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.resolved,
    required this.primary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 600;
        final isMedium =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1200;

        final crossAxisCount = isSmall ? 2 : (isMedium ? 3 : 4);

        const spacing = 8.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
                crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            _cardWrapper(
              itemWidth,
              _buildCard(
                "Total Issues",
                total.toString(),
                Icons.folder_copy_outlined,
                primary,
                primary.withOpacity(0.1),
              ),
            ),
            _cardWrapper(
              itemWidth,
              _buildCard(
                "Pending",
                pending.toString(),
                Icons.pending_outlined,
                Colors.red.shade600,
                Colors.red.shade50,
              ),
            ),
            _cardWrapper(
              itemWidth,
              _buildCard(
                "In Progress",
                inProgress.toString(),
                Icons.timelapse_outlined,
                Colors.amber.shade700,
                Colors.amber.shade50,
              ),
            ),
            _cardWrapper(
              itemWidth,
              _buildCard(
                "Resolved",
                resolved.toString(),
                Icons.check_circle_outline,
                Colors.green.shade600,
                Colors.green.shade50,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _cardWrapper(double width, Widget child) {
    return SizedBox(
      width: width,
      child: child,
    );
  }

  Widget _buildCard(
    String title,
    String count,
    IconData icon,
    Color iconColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            count,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
