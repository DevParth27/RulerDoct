import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rolodoct/models/user_model.dart';
import 'package:rolodoct/utils/aboutUs.dart';
import 'package:rolodoct/widgets/common_widgets.dart';

class DoctorProfileWidget extends StatefulWidget {
  final UserModel doctor;
  final Function() onSignOut;

  const DoctorProfileWidget({
    super.key,
    required this.doctor,
    required this.onSignOut,
  });

  @override
  State<DoctorProfileWidget> createState() => _DoctorProfileWidgetState();
}

class _DoctorProfileWidgetState extends State<DoctorProfileWidget> {
  late UserModel currentDoctor;

  @override
  void initState() {
    super.initState();
    currentDoctor = widget.doctor;
  }

  // Method to refresh doctor data after editing
  void _updateDoctorData(Map<String, dynamic> updatedData) {
    setState(() {
      // Update the current doctor data
      currentDoctor = UserModel(
        id: currentDoctor.id,
        // Use updated data if available, otherwise keep current values
        role: currentDoctor.role,
        name: updatedData['name'] ?? currentDoctor.name,
        email: updatedData['email'] ?? currentDoctor.email,
        phone: updatedData['phone'] ?? currentDoctor.phone,
        specialization:
            updatedData['specialization'] ?? currentDoctor.specialization,
        createdAt: currentDoctor.createdAt,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        // Profile Header
        const PageHeader(
          title: 'Doctor Profile',
          icon: Icons.medical_services_rounded,
        ),
        const SizedBox(height: 24),

        // Profile image and name
        Center(
          child: Column(
            children: [
              Hero(
                tag: 'profile-${currentDoctor.id}',
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  child: Text(
                    currentDoctor.name.isNotEmpty
                        ? currentDoctor.name[0].toUpperCase()
                        : 'D',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                currentDoctor.name,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  currentDoctor.specialization ?? 'Doctor',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (currentDoctor.phone != null &&
                  currentDoctor.phone!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    currentDoctor.phone!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Contact Information Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Phone
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.phone,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phone',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          currentDoctor.phone ?? 'Not provided',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Email
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.email,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          currentDoctor.email ?? 'Not provided',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Account Settings
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit,
                    color: theme.colorScheme.secondary,
                    size: 20,
                  ),
                ),
                title: const Text('Edit Profile'),
                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                onTap: () async {
                  // Navigate to edit profile screen
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => EditDoctorProfileScreen(
                            doctor: {
                              'name': currentDoctor.name,
                              'specialization': currentDoctor.specialization,
                              'phone': currentDoctor.phone,
                              'email': currentDoctor.email,
                            },
                          ),
                    ),
                  );

                  // If data was updated, refresh the current screen
                  if (result != null) {
                    _updateDoctorData(result);
                  }
                },
              ),
              Divider(color: theme.colorScheme.outline.withOpacity(0.3)),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.info,
                    color: theme.colorScheme.tertiary,
                    size: 20,
                  ),
                ),
                title: const Text('About Us'),
                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutUsPage()),
                  );
                },
              ),
              Divider(color: theme.colorScheme.outline.withOpacity(0.3)),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.logout,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                ),
                title: const Text('Sign Out'),
                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                onTap: widget.onSignOut,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // App version
        Center(
          child: Text(
            'Version 1.1.2',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// Edit Doctor Profile Screen
class EditDoctorProfileScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const EditDoctorProfileScreen({super.key, required this.doctor});

  @override
  State<EditDoctorProfileScreen> createState() =>
      _EditDoctorProfileScreenState();
}

class _EditDoctorProfileScreenState extends State<EditDoctorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _specializationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill the form with current doctor data
    _nameController.text = widget.doctor['name'] ?? '';
    _specializationController.text = widget.doctor['specialization'] ?? '';
    _phoneController.text = widget.doctor['phone'] ?? '';
    _emailController.text = widget.doctor['email'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specializationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final query =
        await FirebaseFirestore.instance
            .collection('doctors')
            //  .where('email', isEqualTo: _emailController.text.trim())
            .where('email', isEqualTo: widget.doctor['email'])
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      final docId = query.docs.first.id;

      await FirebaseFirestore.instance.collection('doctors').doc(docId).update({
        'name': _nameController.text.trim(),
        'specialization': _specializationController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, {
          'name': _nameController.text.trim(),
          'specialization': _specializationController.text.trim(),
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
        });
      }
    } else {
      throw Exception('Doctor profile not found.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                    child: Text(
                      _nameController.text.isNotEmpty
                          ? _nameController.text[0].toUpperCase()
                          : 'D',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Edit Profile Information',
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Name Field
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onChanged: (value) {
                  // Update avatar when name changes
                  setState(() {});
                },
              ),
            ),

            // Specialization Field
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: _specializationController,
                decoration: InputDecoration(
                  labelText: 'Specialization',
                  prefixIcon: const Icon(Icons.medical_services),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your specialization';
                  }
                  return null;
                },
              ),
            ),

            // Phone Field
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (value.trim().length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
            ),

            // Email Field
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
