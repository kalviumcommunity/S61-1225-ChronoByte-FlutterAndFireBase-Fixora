import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class RaiseIssuePage extends StatefulWidget {
  const RaiseIssuePage({super.key});

  @override
  State<RaiseIssuePage> createState() => _RaiseIssuePageState();
}

class _RaiseIssuePageState extends State<RaiseIssuePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  LatLng? _selectedLatLng;

  String? _category;
  String? _issue;
  bool _submitting = false;
  bool _agreeToTerms = false;

  // Images (optional)
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = []; // stores picked images (optional)
  static const int _maxImages = 4; // limit to avoid excessive uploads

  // Dynamic colors based on theme
  Color get _primaryBlue => Theme.of(context).colorScheme.primary;
  Color get _darkBlue => Theme.of(context).colorScheme.secondary;
  Color get _lightBlue => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF1E293B)
      : const Color(0xFFDEEAFF);
  Color get _backgroundColor => Theme.of(context).scaffoldBackgroundColor;
  Color get _surfaceColor => Theme.of(context).cardColor;
  Color get _textColor =>
      Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
  Color get _secondaryTextColor =>
      Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

  static const _issuesMap = {
    'Road & Transportation': [
      'Potholes',
      'Broken Signals',
      'Traffic Congestion',
    ],
    'Waste Management': ['Garbage Overflow', 'Irregular Collection'],
    'Water Supply': ['No Water', 'Low Pressure', 'Contaminated Water'],
    'Drainage & Sewage': ['Overflow', 'Blocked Drains'],
    'Noise & Air Pollution': ['Loud Construction', 'Vehicle Pollution'],
    'Parks & Public Spaces': ['Damaged Equipment', 'Poor Maintenance'],
    'Public Safety': ['Street Lights Not Working', 'Unsafe Area'],
  };

  int get _wordCount => _descriptionController.text
      .trim()
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
      final random =
          DateTime.now().millisecondsSinceEpoch % 1000000; // 6-digit number
      final complaintId = 'FX-$year-${random.toString().padLeft(6, '0')}';

      // If images were selected, upload them first and collect URLs
      List<String> imageUrls = [];
      if (_images.isNotEmpty) {
        for (int i = 0; i < _images.length; i++) {
          final xfile = _images[i];
          final file = File(xfile.path);
          final ext = xfile.path.split('.').last;
          final storageRef = FirebaseStorage.instance.ref().child(
            'problems/$complaintId/images/image_$i.$ext',
          );
          final uploadTask = await storageRef.putFile(file);
          final downloadUrl = await uploadTask.ref.getDownloadURL();
          imageUrls.add(downloadUrl);
        }
      }

      await FirebaseFirestore.instance.collection('problems').doc().set({
        'complaintId': complaintId,
        'userId': user.uid,
        'category': _category,
        'issue': _issue,
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        if (_selectedLatLng != null)
          'geo': GeoPoint(
            _selectedLatLng!.latitude,
            _selectedLatLng!.longitude,
          ),
        'images': imageUrls, // optional list of image URLs
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
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
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
      _selectedLatLng = null;
      _agreeToTerms = false;
      _images.clear();
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
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) => _buildBody(constraints),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _surfaceColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: _textColor),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
      ),
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            },
            child: _brandLogo(size: 28),
          ),
          const SizedBox(width: 12),
          Text(
            'Fixora - Raise Issue',
            style: TextStyle(
              color: _textColor,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ],
      ),
      systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
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
                _buildSectionHeader(
                  'Complaint Details',
                  Icons.description,
                  isSmall,
                ),
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
                      validator: (_) => _validDescription
                          ? null
                          : 'Minimum 20 words required (current: $_wordCount)',
                      helperText:
                          'Provide detailed information about the issue',
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
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _openMapPicker,
                            icon: const Icon(Icons.map),
                            label: const Text('Select on Map'),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedLatLng != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Selected: ${_selectedLatLng!.latitude.toStringAsFixed(6)}, ${_selectedLatLng!.longitude.toStringAsFixed(6)}',
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildImagePicker(isSmall),
                  ],
                ),
                SizedBox(height: isSmall ? 24 : 32),
                _buildCheckboxField(isSmall),
                SizedBox(height: isSmall ? 16 : 20),
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
      padding: EdgeInsets.symmetric(
        vertical: isSmall ? 24 : 32,
        horizontal: isSmall ? 16 : 24,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _lightBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _brandLogo(size: isSmall ? 36 : 48),
          ),
          SizedBox(height: isSmall ? 16 : 20),
          Text(
            'Submit a Complaint',
            style: TextStyle(
              fontSize: isSmall ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          SizedBox(height: isSmall ? 8 : 12),
          Text(
            'Fill out the form below to register your civic grievance. All fields marked with * are required.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmall ? 14 : 15,
              color: _secondaryTextColor,
              height: 1.5,
            ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: ClipRRect(
        borderRadius: circular
            ? BorderRadius.circular(999)
            : BorderRadius.circular(8),
        child: Image.asset(
          'assets/images/logo.png',
          height: size,
          width: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stack) => Icon(
            Icons.image_not_supported_outlined,
            color: _primaryBlue,
            size: size,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isSmall) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isSmall ? 12 : 16,
        horizontal: isSmall ? 16 : 20,
      ),
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
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------ Image Picker Helpers ------------------
  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
            ),
            if (_images.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remove all images'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _images.clear());
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 75);
      if (picked != null && picked.isNotEmpty) {
        setState(() {
          final available = _maxImages - _images.length;
          _images.addAll(picked.take(available));
        });
      }
    } catch (e) {
      _showSnackBar('Error picking images: ${e.toString()}', isError: true);
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
      );
      if (picked != null) {
        setState(() {
          if (_images.length < _maxImages) _images.add(picked);
        });
      }
    } catch (e) {
      _showSnackBar('Error taking photo: ${e.toString()}', isError: true);
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  Widget _buildImagePicker(bool isSmall) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Images (optional)',
          style: TextStyle(color: _textColor, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (int i = 0; i < _images.length; i++)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_images[i].path),
                            width: 100,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(i),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (_images.length < _maxImages)
                    GestureDetector(
                      onTap: _showImageSourceSheet,
                      child: Container(
                        width: 100,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _lightBlue,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                color: _primaryBlue,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add',
                                style: TextStyle(
                                  color: _primaryBlue,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (_images.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${_images.length} / $_maxImages selected',
                    style: TextStyle(color: _secondaryTextColor),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(bool isSmall, {required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 16 : 20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
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
      hint: Text(hint, style: TextStyle(color: _secondaryTextColor)),
      style: TextStyle(color: _textColor), // dark text for visibility
      dropdownColor: _surfaceColor,
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item, style: TextStyle(color: _textColor)),
            ),
          )
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
      style: TextStyle(color: _textColor),
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
      labelStyle: TextStyle(color: _secondaryTextColor),
      floatingLabelStyle: TextStyle(color: _primaryBlue),
      hintStyle: TextStyle(color: _secondaryTextColor),
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
        borderSide: BorderSide(color: _primaryBlue, width: 2),
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
      fillColor: _surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildCheckboxField(bool isSmall) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 12 : 16,
        vertical: isSmall ? 12 : 14,
      ),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _agreeToTerms ? _primaryBlue : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: _agreeToTerms,
              onChanged: (value) =>
                  setState(() => _agreeToTerms = value ?? false),
              activeColor: _primaryBlue,
              side: BorderSide(color: _primaryBlue, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          SizedBox(width: isSmall ? 12 : 14),
          Expanded(
            child: Text(
              'I agree to provide accurate information and accept the Fixora Terms & Conditions',
              style: TextStyle(
                fontSize: isSmall ? 13 : 14,
                color: _textColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(bool isSmall) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: (_submitting || !_agreeToTerms) ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _primaryBlue.withOpacity(0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
                    style: TextStyle(
                      fontSize: isSmall ? 16 : 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFooter(bool isSmall) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _brandLogo(size: 28),
              const SizedBox(width: 8),
              Text(
                'Fixora',
                style: TextStyle(
                  color: _textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'A transparent and efficient platform for citizens to raise and track civic complaints with Urban Local Bodies.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmall ? 13 : 14,
              color: _secondaryTextColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            '© 2025 Fixora Portal. All rights reserved.',
            style: TextStyle(
              fontSize: isSmall ? 12 : 13,
              color: _secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(builder: (_) => const _MapPickerPage()),
    );
    if (result != null) {
      setState(() {
        _selectedLatLng = result;
        _locationController.text =
            'Lat: ${result.latitude.toStringAsFixed(6)}, Lng: ${result.longitude.toStringAsFixed(6)}';
      });
    }
  }
}

class _MapPickerPage extends StatefulWidget {
  const _MapPickerPage({Key? key}) : super(key: key);

  @override
  State<_MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<_MapPickerPage> {
  GoogleMapController? _controller;
  LatLng? _picked;
  bool _locating = false;

  static const LatLng _defaultCenter = LatLng(12.9716, 77.5946);

  @override
  void initState() {
    super.initState();
    _ensureLocationPermission();
  }

  Future<void> _ensureLocationPermission() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
  }

  Future<void> _goToCurrentLocation() async {
    try {
      setState(() => _locating = true);
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final target = LatLng(pos.latitude, pos.longitude);
      await _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: 16),
        ),
      );
      setState(() {
        _picked = target;
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Location')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _defaultCenter,
              zoom: 12,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (c) => _controller = c,
            onTap: (latLng) => setState(() => _picked = latLng),
            markers: {
              if (_picked != null)
                Marker(markerId: const MarkerId('picked'), position: _picked!),
            },
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'locate',
                  onPressed: _locating ? null : _goToCurrentLocation,
                  child: _locating
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.my_location),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _picked == null
                      ? null
                      : () => Navigator.pop(context, _picked),
                  icon: const Icon(Icons.check),
                  label: const Text('Use this location'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
