import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'issue_card.dart';

class IssuesList extends StatelessWidget {
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final bool showActions;
  final String searchQuery;
  final String statusFilter;
  final void Function(QueryDocumentSnapshot<Map<String, dynamic>> doc, String oldStatus, String newStatus) onStatusSelected;

  const IssuesList({
    Key? key,
    required this.stream,
    required this.showActions,
    required this.searchQuery,
    required this.statusFilter,
    required this.onStatusSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 3),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorWidget(context, snapshot.error.toString());
        }

        final docs = _sortAndFilterDocs(snapshot.data?.docs ?? []);

        if (docs.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, i) => IssueCard(
            doc: docs[i],
            showActions: showActions,
            onStatusSelected: onStatusSelected,
          ),
        );
      },
    );
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortAndFilterDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    // Sort by createdAt descending
    docs.sort((a, b) {
      final aTs = a.data()['createdAt'] as Timestamp?;
      final bTs = b.data()['createdAt'] as Timestamp?;
      return (bTs?.compareTo(aTs ?? Timestamp(0, 0))) ?? 0;
    });

    // Filter by status and search query
    return docs.where((d) {
      final data = d.data();
      final title = (data['title'] ?? '').toString().toLowerCase();
      final id = d.id.toLowerCase();
      final email = (data['email'] ?? '').toString().toLowerCase();
      final status = (data['status'] ?? '').toString();

      if (statusFilter != 'All' && status != statusFilter) return false;

      final q = searchQuery.trim().toLowerCase();
      if (q.isEmpty) return true;

      return title.contains(q) || id.contains(q) || email.contains(q);
    }).toList();
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    final needsIndex = error.contains('requires an index');
    final isOffline = error.contains('Unable to resolve host') ||
        error.contains('UNAVAILABLE') ||
        error.contains('UnknownHostException');

    String? indexUrl;
    if (needsIndex) {
      final match = RegExp(r'https://console\.firebase\.google\.com/[^\s)]+').firstMatch(error);
      if (match != null) indexUrl = match.group(0);
    }

    final message = needsIndex
        ? 'Query requires a composite index. Create it in Firebase Console.'
        : (isOffline
            ? 'Network unavailable. Showing cached data if available.'
            : 'Firestore query failed: ${error.split('\n').first}');

    final icon = needsIndex
        ? Icons.storage_outlined
        : (isOffline ? Icons.wifi_off_outlined : Icons.error_outline);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade50, Colors.orange.shade100],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade300),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.orange.shade700, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      needsIndex ? 'Index Required' : (isOffline ? 'Offline Mode' : 'Error'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.orange.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (indexUrl != null) ...[
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final uri = Uri.parse(indexUrl!);
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } catch (e) {
                      debugPrint('Failed to open index URL: $e');
                    }
                  },
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Open'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildFallbackStream(context)),
      ],
    );
  }

  Widget _buildFallbackStream(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('problems').snapshots(),
      builder: (context, fallback) {
        if (fallback.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 3));
        }

        if (fallback.hasError) {
          return Center(
            child: Text(
              'Unable to load data: ${fallback.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final docs = _sortAndFilterDocs(fallback.data?.docs ?? []);

        if (docs.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, i) => IssueCard(
            doc: docs[i],
            showActions: showActions,
            onStatusSelected: onStatusSelected,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No issues found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty
                ? 'Try adjusting your search'
                : 'Issues will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}