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
        final isMedium = constraints.maxWidth >= 600 && constraints.maxWidth < 1200;
        final crossAxisCount = isSmall ? 2 : (isMedium ? 3 : 4);
        
        const spacing = 10.0;
        final itemWidth = (constraints.maxWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: itemWidth,
              child: _buildCard(
                "Total Issues",
                total.toString(),
                Icons.folder_copy_outlined,
                primary,
                primary.withOpacity(0.1),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _buildCard(
                "Pending",
                pending.toString(),
                Icons.pending_outlined,
                Colors.red.shade600,
                Colors.red.shade50,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _buildCard(
                "In Progress",
                inProgress.toString(),
                Icons.timelapse_outlined,
                Colors.amber.shade700,
                Colors.amber.shade50,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _buildCard(
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

  Widget _buildCard(String title, String count, IconData icon, Color iconColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}