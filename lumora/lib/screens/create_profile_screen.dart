import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'permissions_screen.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  static const _primary = Color(0xFF0C56D0);
  static const _border = Color(0xFFC3C6D6);
  static const _label = Color(0xFF595F66);
  static const _healthRed = Color(0xFFCC0000);

  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _notesController = TextEditingController();

  File? _profileImage;
  String? _gender;
  String? _bloodGroup;

  bool _isSaving = false;

  static const _genders = ['Male', 'Female', 'Other', 'Prefer not to say'];
  static const _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(BuildContext context) async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name.')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'userId': user.uid,
          'name': _nameController.text.trim(),
          'phone': user.phoneNumber ?? '',
          'dob': _dobController.text.trim(),
          'gender': _gender ?? '',
          'bloodGroup': _bloodGroup ?? '',
          'notes': _notesController.text.trim(),
          'guardianMode': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const PermissionsScreen()),
      );
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    }
  }

  Future<void> _pickProfilePhoto() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;
    setState(() => _profileImage = File(image.path));
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: _primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null || !mounted) return;
    setState(() {
      _dobController.text =
          '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
    });
  }

  InputDecoration _fieldDecoration({
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF737685)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF8FB),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded, color: _primary),
                      tooltip: 'Go back',
                    ),
                  ),
                  const Text(
                    'Create Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _primary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  children: [
                    _ProfilePhotoSection(
                      image: _profileImage,
                      onTap: _pickProfilePhoto,
                    ),
                    const SizedBox(height: 24),
                    _SectionCard(
                      icon: Icons.badge_outlined,
                      iconColor: _primary,
                      title: 'Personal Details',
                      children: [
                        const _FieldLabel('Full Name (Required)'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                          decoration: _fieldDecoration(hintText: 'e.g. Sarah Sharma'),
                        ),
                        const SizedBox(height: 20),
                        const _FieldLabel('Gender'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _genders.map((option) {
                            final selected = _gender == option;
                            return SizedBox(
                              width: (MediaQuery.sizeOf(context).width - 72) / 2,
                              child: _GenderChip(
                                label: option,
                                selected: selected,
                                onTap: () => setState(() => _gender = option),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        const _FieldLabel('Date of Birth (Optional)'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _dobController,
                          readOnly: true,
                          onTap: _pickDateOfBirth,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                          decoration: _fieldDecoration(
                            hintText: 'mm/dd/yyyy',
                            suffixIcon: IconButton(
                              onPressed: _pickDateOfBirth,
                              icon: const Icon(Icons.calendar_today_outlined, color: _label, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      icon: Icons.health_and_safety_outlined,
                      iconColor: _healthRed,
                      title: 'Health & Safety',
                      children: [
                        const _FieldLabel('Blood Group (Optional)'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _bloodGroup,
                          hint: const Text(
                            'Select Blood Group',
                            style: TextStyle(fontSize: 15, color: Color(0xFF737685)),
                          ),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _label),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                          decoration: _fieldDecoration(),
                          items: _bloodGroups
                              .map(
                                (group) => DropdownMenuItem<String>(
                                  value: group,
                                  child: Text(group),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(() => _bloodGroup = value),
                        ),
                        const SizedBox(height: 20),
                        const _FieldLabel('Emergency Medical Notes (Optional)'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _notesController,
                          maxLines: 4,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A1A),
                          ),
                          decoration: _fieldDecoration(
                            hintText: 'Allergies, medications, or chronic conditions...',
                          ).copyWith(
                            contentPadding: const EdgeInsets.all(16),
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isSaving ? null : () => _saveProfile(context),
                child: _isSaving
                    ? const SizedBox(
                        height: 22, width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Complete Profile', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePhotoSection extends StatelessWidget {
  const _ProfilePhotoSection({
    required this.image,
    required this.onTap,
  });

  final File? image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE8EAEF),
                border: Border.all(color: const Color(0xFFC3C6D6)),
                image: image != null
                    ? DecorationImage(
                        image: FileImage(image!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: image == null
                  ? const Icon(Icons.person_outline_rounded, size: 56, color: Color(0xFF737685))
                  : null,
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Material(
                color: const Color(0xFF0C56D0),
                shape: const CircleBorder(),
                elevation: 2,
                child: InkWell(
                  onTap: onTap,
                  customBorder: const CircleBorder(),
                  child: const SizedBox(
                    width: 36,
                    height: 36,
                    child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Profile Photo (Optional)',
          style: TextStyle(fontSize: 14, color: Color(0xFF595F66), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC3C6D6)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0C56D0),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF595F66),
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF0C56D0).withValues(alpha: 0.08) : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? const Color(0xFF0C56D0) : const Color(0xFFC3C6D6),
              width: selected ? 1.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? const Color(0xFF0C56D0) : const Color(0xFF1A1A1A),
            ),
          ),
        ),
      ),
    );
  }
}
