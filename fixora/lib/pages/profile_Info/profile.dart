import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../../widgets/skeleton_loaders.dart';
import '../../utils/error_handler.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _usernameController.text = _currentUser?.displayName ?? '';
    _emailController.text = _currentUser?.email ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool error = false}) {
    if (!mounted) return;
    if (error) {
      ErrorHandler.showError(context, message: message);
    } else {
      ErrorHandler.showSuccess(context, message: message);
    }
  }

  Future<void> _handleUpdateProfile() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();

    try {
      if (_currentUser == null) {
        ErrorHandler.showError(
          context,
          message: 'Please sign in to update your profile',
        );
        return;
      }

      await _currentUser!.updateDisplayName(username);
      // Email update requires re-auth; skip for now and show message

      ErrorHandler.showSuccess(
        context,
        message: 'Profile updated successfully',
      );
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(
          context,
          title: 'Update Failed',
          message: ErrorHandler.getErrorMessage(e),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
        ErrorHandler.showSuccess(context, message: 'Logged out successfully');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(
          context,
          title: 'Logout Failed',
          message: ErrorHandler.getErrorMessage(e),
        );
      }
    }
  }

  Future<void> _showEditDialog(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final TextEditingController descCtrl = TextEditingController(
      text: data['description'] ?? '',
    );
    final TextEditingController locCtrl = TextEditingController(
      text: data['location'] ?? '',
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Complaint'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descCtrl,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: locCtrl,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true) {
      try {
        await FirebaseFirestore.instance
            .collection('problems')
            .doc(doc.id)
            .update({
              'description': descCtrl.text.trim(),
              'location': locCtrl.text.trim(),
            });
        if (mounted) _showMessage('Complaint updated');
      } catch (e) {
        if (mounted) _showMessage('Error updating complaint: $e', error: true);
      }
    }
  }

  Future<void> _confirmDelete(DocumentSnapshot doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Complaint'),
        content: const Text(
          'Are you sure you want to delete this complaint? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('problems')
            .doc(doc.id)
            .delete();
        if (mounted) _showMessage('Complaint deleted');
      } catch (e) {
        if (mounted) _showMessage('Error deleting complaint: $e', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: user == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Please sign in to view your profile.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: const Text('Sign in'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Your Profile',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _handleUpdateProfile,
                    child: const Text('Update Profile'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _handleLogout,
                    child: const Text('Logout'),
                  ),

                  const SizedBox(height: 16),
                  // Auth debug card: shows ID token claims and allows refresh
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Auth Info',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              TextButton(
                                onPressed: () async {
                                  // Force token refresh
                                  try {
                                    await user?.getIdTokenResult(true);
                                    setState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Token refreshed'),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error refreshing token: $e',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Refresh'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<IdTokenResult?>(
                            future: user?.getIdTokenResult(false),
                            builder: (context, tokSnap) {
                              if (tokSnap.connectionState ==
                                  ConnectionState.waiting) {
                                return SizedBox(
                                  height: 40,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              if (tokSnap.hasError)
                                return Text(
                                  'Error getting token: ${tokSnap.error}',
                                );
                              final claims = tokSnap.data?.claims ?? {};
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'UID: ${user?.uid ?? '-'}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Email: ${user?.email ?? '-'}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Claims:',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (claims.isEmpty)
                                    const Text('No custom claims detected'),
                                  if (claims.isNotEmpty) ...[
                                    for (final entry in claims.entries)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 4,
                                        ),
                                        child: Text(
                                          '${entry.key}: ${entry.value}',
                                        ),
                                      ),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          final text =
                                              'uid=${user?.uid}\nemail=${user?.email}\nclaims=${claims.toString()}';
                                          Clipboard.setData(
                                            ClipboardData(text: text),
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Auth info copied to clipboard',
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text('Copy'),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton(
                                        onPressed: () async {
                                          // open login page for re-auth
                                          await Navigator.pushNamed(
                                            context,
                                            '/login',
                                          );
                                        },
                                        child: const Text('Re-auth / Login'),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Raised Complaints',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  StreamBuilder<QuerySnapshot>(
                    // NOTE: Avoid server-side composite index requirement by not ordering in the query.
                    // We'll fetch complaints filtered by userId and sort them client-side by 'createdAt'.
                    stream: FirebaseFirestore.instance
                        .collection('problems')
                        .where('userId', isEqualTo: user.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 3,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ComplaintCardSkeleton(
                              baseColor: const Color(0xFFE0E0E0),
                              highlightColor: const Color(0xFFF5F5F5),
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        final err = snapshot.error;

                        // If Firestore asks for an index, show helpful guidance
                        if (err is FirebaseException &&
                            (err.code == 'failed-precondition' ||
                                (err.message ?? '').toLowerCase().contains(
                                  'requires an index',
                                ))) {
                          return Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'This query requires a Firestore composite index.',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'To create it: Open Firebase Console → Firestore → Indexes → Add Index, then set:',
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Collection: problems',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const Text(
                                  'Fields: userId (Ascending), createdAt (Descending)',
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        // Copy a short instruction to clipboard to help the developer create the index
                                        Clipboard.setData(
                                          const ClipboardData(
                                            text:
                                                'Collection: problems\nFields: userId (Ascending)\ncreatedAt (Descending)',
                                          ),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Index instructions copied to clipboard',
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Copy index instructions',
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        final url =
                                            'https://console.firebase.google.com/project/fixora-291df/firestore/indexes';
                                        Clipboard.setData(
                                          ClipboardData(text: url),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Firestore indexes URL copied - paste in browser',
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Copy Firestore Console URL',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }

                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final docs = List<DocumentSnapshot>.from(
                        snapshot.data?.docs ?? [],
                      );

                      // Sort locally by createdAt (descending)
                      docs.sort((a, b) {
                        final aData = a.data() as Map<String, dynamic>?;
                        final bData = b.data() as Map<String, dynamic>?;
                        final aTs = aData?['createdAt'];
                        final bTs = bData?['createdAt'];

                        DateTime aDate = DateTime.fromMillisecondsSinceEpoch(0);
                        DateTime bDate = DateTime.fromMillisecondsSinceEpoch(0);

                        if (aTs is Timestamp)
                          aDate = aTs.toDate();
                        else if (aTs is DateTime)
                          aDate = aTs;

                        if (bTs is Timestamp)
                          bDate = bTs.toDate();
                        else if (bTs is DateTime)
                          bDate = bTs;

                        return bDate.compareTo(aDate);
                      });

                      if (docs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'You have not raised any complaints yet.',
                          ),
                        );
                      }

                      return Column(
                        children: docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final status = data['status'] ?? 'Pending';
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(data['issue'] ?? 'Complaint'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ID: ${data['complaintId'] ?? ''} • Status: $status',
                                  ),
                                  const SizedBox(height: 6),
                                  Text(data['description'] ?? ''),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Location: ${data['location'] ?? ''}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _showEditDialog(doc),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _confirmDelete(doc),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
