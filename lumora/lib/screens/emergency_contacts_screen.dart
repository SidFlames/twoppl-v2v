import 'package:flutter/material.dart';
import 'voice_enrollment_intro_screen.dart';

class ContactItem {
  final String name;
  final String phone;
  final bool isPrimary;
  final String? imageAsset; // We can use a letter avatar or initials if no image

  ContactItem({
    required this.name,
    required this.phone,
    this.isPrimary = false,
    this.imageAsset,
  });

  ContactItem copyWith({
    String? name,
    String? phone,
    bool? isPrimary,
    String? imageAsset,
  }) {
    return ContactItem(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      isPrimary: isPrimary ?? this.isPrimary,
      imageAsset: imageAsset ?? this.imageAsset,
    );
  }
}

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  static const _primary = Color(0xFF0C56D0);
  static const _surface = Color(0xFFFCF8FB);
  static const _onSurface = Color(0xFF1B1B1D);
  static const _secondary = Color(0xFF595F66);
  static const _border = Color(0xFFC3C6D6);
  static const _lightBlue = Color(0xFFE8F0FE);

  final List<ContactItem> _contacts = [
    ContactItem(name: 'Mom', phone: '+1 (555) 012-3456', isPrimary: true),
    ContactItem(name: 'Dad', phone: '+1 (555) 098-7654'),
    ContactItem(name: 'Sarah Sharma', phone: '+1 (555) 443-2211'),
  ];

  void _addNewContact(String name, String phone, bool isPrimary) {
    if (_contacts.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Limit: 5 active contacts reached.')),
      );
      return;
    }

    setState(() {
      if (isPrimary) {
        // Reset other primary contacts
        for (var i = 0; i < _contacts.length; i++) {
          _contacts[i] = _contacts[i].copyWith(isPrimary: false);
        }
      }
      _contacts.add(ContactItem(name: name, phone: phone, isPrimary: isPrimary));
    });
  }

  void _showAddContactSheet() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    bool isPrimary = _contacts.isEmpty;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Add New Contact',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _onSurface,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Contact Name',
                      hintText: 'e.g. Mom, Partner, Friend',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '+1 (555) 000-0000',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: isPrimary,
                        activeColor: _primary,
                        onChanged: (val) {
                          setSheetState(() {
                            isPrimary = val ?? false;
                          });
                        },
                      ),
                      const Text(
                        'Set as Primary Emergency Contact',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      if (nameController.text.trim().isEmpty ||
                          phoneController.text.trim().isEmpty) {
                        return;
                      }
                      _addNewContact(
                        nameController.text.trim(),
                        phoneController.text.trim(),
                        isPrimary,
                      );
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Add Contact',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showContactMenu(int index) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.star_border_rounded, color: _primary),
                title: const Text('Make Primary Contact'),
                onTap: () {
                  setState(() {
                    for (var i = 0; i < _contacts.length; i++) {
                      _contacts[i] = _contacts[i].copyWith(isPrimary: i == index);
                    }
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                title: const Text('Remove Contact', style: TextStyle(color: Colors.red)),
                onTap: () {
                  setState(() {
                    _contacts.removeAt(index);
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Emergency Contacts',
          style: TextStyle(
            color: _primary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 8,
                bottom: 120, // Space for bottom action button
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Add people you trust to be notified during an emergency.',
                    style: TextStyle(
                      fontSize: 16,
                      color: _onSurface,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Icon(Icons.info_outline_rounded, size: 16, color: _primary),
                      SizedBox(width: 6),
                      Text(
                        'Limit: 5 active contacts',
                        style: TextStyle(
                          fontSize: 14,
                          color: _primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: Container(
                      height: 5,
                      color: _border.withValues(alpha: 0.3),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 6, // progress indicator
                            child: Container(color: _primary),
                          ),
                          const Expanded(
                            flex: 4, // remaining indicator
                            child: SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Contacts List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _contacts.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final contact = _contacts[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _border.withValues(alpha: 0.4)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.015),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Avatar Icon or Initial
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: _primary.withValues(alpha: 0.1),
                              child: Text(
                                contact.name.isNotEmpty ? contact.name[0].toUpperCase() : 'C',
                                style: const TextStyle(
                                  color: _primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        contact.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _onSurface,
                                        ),
                                      ),
                                      if (contact.isPrimary) ...[
                                        const SizedBox(width: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _lightBlue,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'Primary',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: _primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    contact.phone,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: _secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Action Button
                            IconButton(
                              icon: const Icon(Icons.more_vert_rounded, color: _secondary),
                              onPressed: () => _showContactMenu(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Add New Contact Dotted Button
                  if (_contacts.length < 5) ...[
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: _showAddContactSheet,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _border.withValues(alpha: 0.6),
                            style: BorderStyle.solid, // Use simple solid or custom painter for dashes
                          ),
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.person_add_alt_1_rounded, size: 28, color: _secondary),
                            SizedBox(height: 8),
                            Text(
                              '+ Add New Contact',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: _secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Privacy Information Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9FB),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.verified_user_outlined, color: _primary, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your contacts are only notified when you trigger a "High-Priority" SOS or fail to check-in. Their data is encrypted and never shared.',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              color: _secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                border: Border(
                  top: BorderSide(
                    color: _border.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const VoiceEnrollmentIntroScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Save & Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
