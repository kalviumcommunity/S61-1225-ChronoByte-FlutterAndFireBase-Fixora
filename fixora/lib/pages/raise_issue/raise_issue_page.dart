import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RaiseIssuePage extends StatefulWidget {
  const RaiseIssuePage({super.key});

  @override
  State<RaiseIssuePage> createState() => _RaiseIssuePageState();
}

class _RaiseIssuePageState extends State<RaiseIssuePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _description = TextEditingController();
  String? _category;
  String? _issue;
  bool _submitting = false;

  final Map<String, List<String>> _map = {
    'Road & Transportation': ['Potholes', 'Broken Signals', 'Traffic Congestion'],
    'Waste Management': ['Garbage Overflow', 'Irregular Collection'],
    'Water Supply': ['No Water', 'Low Pressure', 'Contaminated Water'],
    'Drainage & Sewage': ['Overflow', 'Blocked Drains'],
    'Noise & Air Pollution': ['Loud Construction', 'Vehicle Pollution'],
    'Parks & Public Spaces': ['Damaged Equipment', 'Poor Maintenance'],
    'Public Safety': ['Street Lights Not Working', 'Unsafe Area'],
  };

  int _wordCount() {
    return _description.text.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
  }

  bool _validDescription() => _wordCount() >= 20;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      var user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        try {
          final anon = await FirebaseAuth.instance.signInAnonymously();
          user = anon.user;
        } catch (e) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in to submit')));
          return;
        }
      }

      final doc = FirebaseFirestore.instance.collection('problems').doc();
      await doc.set({
        'userId': user!.uid,
        'category': _category,
        'issue': _issue,
        'description': _description.text.trim(),
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Issue submitted')));
        setState(() {
          _category = null;
          _issue = null;
          _description.clear();
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report an Issue')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                items: _map.keys.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                value: _category,
                onChanged: (v) => setState(() { _category = v; _issue = null; }),
                validator: (v) => v == null ? 'Required' : null,
              ),
              if (_category != null) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Issue'),
                  items: _map[_category]!.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
                  value: _issue,
                  onChanged: (v) => setState(() => _issue = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                maxLines: 6,
                decoration: InputDecoration(labelText: 'Description (min 20 words) [${_wordCount()}/20]'),
                validator: (_) => _validDescription() ? null : 'Minimum 20 words required (${_wordCount()}/20)',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Issue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
