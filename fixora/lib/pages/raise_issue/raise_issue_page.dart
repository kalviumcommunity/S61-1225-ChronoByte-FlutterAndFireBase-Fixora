import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class RaiseIssuePage extends StatefulWidget {
  const RaiseIssuePage({super.key});

  @override
  State<RaiseIssuePage> createState() => _RaiseIssuePageState();
}

class _RaiseIssuePageState extends State<RaiseIssuePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  String? _category;
  String? _issue;
  bool _submitting = false;

  // Blue color scheme
  static const _primaryBlue = Color(0xFF2563EB);
  static const _darkBlue = Color(0xFF1E40AF);
  static const _lightBlue = Color(0xFFDEEAFF);

  static const _issuesMap = {
    'Road & Transportation': ['Potholes', 'Broken Signals', 'Traffic Congestion'],
    'Waste Management': ['Garbage Overflow', 'Irregular Collection'],
    'Water Supply': ['No Water', 'Low Pressure', 'Contaminated Water'],
    'Drainage & Sewage': ['Overflow', 'Blocked Drains'],
    'Noise & Air Pollution': ['Loud Construction', 'Vehicle Pollution'],
    'Parks & Public Spaces': ['Damaged Equipment', 'Poor Maintenance'],
    'Public Safety': ['Street Lights Not Working', 'Unsafe Area'],
  };

  int get _wordCount => _descriptionController.text.trim()
      .split(RegExp(r'\s+'))
      .where((s) => s.isNotEmpty)
      .length;

  bool get _validDescription => _wordCount >= 20;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please fill all required fields correctly', isError: true);
      return;
    }

    // Check if user is authenticated
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('Please sign in to submit an issue', isError: true);
      return;
    }
    
    setState(() => _submitting = true);
    
    try {
      // Generate unique complaint ID
      final now = DateTime.now();
      final year = now.year;
      final random = DateTime.now().millisecondsSinceEpoch % 1000000; // 6-digit number
      final complaintId = 'FX-$year-${random.toString().padLeft(6, '0')}';

      await FirebaseFirestore.instance.collection('problems').doc().set({
        'complaintId': complaintId,
        'userId': user.uid,
        'category': _category,
        'issue': _issue,
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _showSnackBar('Issue submitted successfully! ID: $complaintId');
        _clearForm();
      }
    } catch (e) {
      if (mounted) _showSnackBar('Error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : _primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _category = null;
      _issue = null;
      _descriptionController.clear();
      _locationController.clear();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(primary: _primaryBlue, secondary: _darkBlue),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(),
        body: LayoutBuilder(
          builder: (context, constraints) => _buildBody(constraints),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          _brandLogo(size: 28),
          const SizedBox(width: 12),
          const Text(
            'Fixora - Raise Issue',
            style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w600, fontSize: 18),
          ),
        ],
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  Widget _buildBody(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final isSmall = width < 600;
    final maxWidth = width >= 768 ? 700.0 : double.infinity;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 16 : 24,
            vertical: isSmall ? 0 : 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(isSmall),
                _buildSectionHeader('Complaint Details', Icons.description, isSmall),
                const SizedBox(height: 16),
                _buildCard(
                  isSmall,
                  children: [
                    _buildDropdown(
                      label: 'Category',
                      value: _category,
                      hint: 'Select complaint category',
                      items: _issuesMap.keys.toList(),
                      onChanged: (v) => setState(() {
                        _category = v;
                        _issue = null;
                      }),
                      icon: Icons.category_outlined,
                    ),
                    if (_category != null) ...[
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Issue',
                        value: _issue,
                        hint: 'Select specific issue',
                        items: _issuesMap[_category]!,
                        onChanged: (v) => setState(() => _issue = v),
                        icon: Icons.report_problem_outlined,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description (min 20 words) [$_wordCount/20]',
                      icon: Icons.description_outlined,
                      maxLines: 5,
                      validator: (_) => _validDescription ? null : 'Minimum 20 words required (current: $_wordCount)',
                      helperText: 'Provide detailed information about the issue',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _locationController,
                      label: 'Location',
                      icon: Icons.location_on_outlined,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Location is required'
                          : v.trim().length < 5
                              ? 'Please provide a detailed location'
                              : null,
                      helperText: 'Street address, ward number, or landmark',
                    ),
                  ],
                ),
                SizedBox(height: isSmall ? 24 : 32),
                _buildSubmitButton(isSmall),
                SizedBox(height: isSmall ? 24 : 32),
                _buildFooter(isSmall),
                SizedBox(height: isSmall ? 16 : 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmall) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: isSmall ? 24 : 32, horizontal: isSmall ? 16 : 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _lightBlue, borderRadius: BorderRadius.circular(16)),
            child: _brandLogo(size: isSmall ? 36 : 48),
          ),
          SizedBox(height: isSmall ? 16 : 20),
          Text(
            'Submit a Complaint',
            style: TextStyle(
              fontSize: isSmall ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: isSmall ? 8 : 12),
          Text(
            'Fill out the form below to register your civic grievance. All fields marked with * are required.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: isSmall ? 14 : 15, color: const Color(0xFF64748B), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _brandLogo({double size = 36, bool circular = true}) {
    final double padding = size > 36 ? 10 : 8;
    return Container(
      height: size + padding,
      width: size + padding,
      padding: EdgeInsets.all(padding / 2),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular ? null : BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: Offset(0, 3))],
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: ClipRRect(
        borderRadius: circular ? BorderRadius.circular(999) : BorderRadius.circular(8),
        child: Image.asset(
          'assets/images/logo.png',
          height: size,
          width: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stack) => Icon(Icons.image_not_supported_outlined, color: _primaryBlue, size: size),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isSmall) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: isSmall ? 12 : 16, horizontal: isSmall ? 16 : 20),
      decoration: BoxDecoration(
        color: _lightBlue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: _primaryBlue, size: isSmall ? 20 : 22),
          SizedBox(width: isSmall ? 8 : 12),
          Text(
            title,
            style: TextStyle(
              fontSize: isSmall ? 16 : 17,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(bool isSmall, {required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      decoration: _inputDecoration(label: '$label *', icon: icon),
      value: value,
      hint: Text(hint, style: const TextStyle(color: Color(0xFF94A3B8))),
      style: const TextStyle(color: Color(0xFF0F172A)), // dark text for visibility
      dropdownColor: Colors.white,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(color: Color(0xFF0F172A)))))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Please select $label' : null,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = true,
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Color(0xFF0F172A)),
      cursorColor: _darkBlue,
      decoration: _inputDecoration(
        label: '$label${required ? ' *' : ''}',
        icon: icon,
        helperText: helperText,
      ),
      validator: validator,
      onChanged: (_) => setState(() {}),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? helperText,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF64748B)),
      floatingLabelStyle: TextStyle(color: _primaryBlue),
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      helperText: helperText,
      helperMaxLines: 2,
      prefixIcon: Icon(icon, color: _primaryBlue, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildSubmitButton(bool isSmall) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _submitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _primaryBlue.withOpacity(0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _submitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Submit Complaint',
                    style: TextStyle(fontSize: isSmall ? 16 : 17, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFooter(bool isSmall) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _brandLogo(size: 28),
              const SizedBox(width: 8),
              const Text('Fixora', style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'A transparent and efficient platform for citizens to raise and track civic complaints with Urban Local Bodies.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: isSmall ? 13 : 14, color: const Color(0xFF64748B), height: 1.5),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            '© 2025 Fixora Portal. All rights reserved.',
            style: TextStyle(fontSize: isSmall ? 12 : 13, color: const Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}