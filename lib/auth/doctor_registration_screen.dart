import 'package:flutter/material.dart';
import 'package:rolodoct/screens/doctor/doctor_dashboard.dart';
import 'package:rolodoct/services/auth_service.dart';
import 'package:rolodoct/widgets/common_widgets.dart';

class DoctorRegistrationScreen extends StatefulWidget {
  const DoctorRegistrationScreen({super.key});

  @override
  State<DoctorRegistrationScreen> createState() =>
      _DoctorRegistrationScreenState();
}

class _DoctorRegistrationScreenState extends State<DoctorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _adminCodeController = TextEditingController();
  final AuthService _authService = AuthService();

  String _selectedSpecialization = 'General Medicine';
  bool _isLoading = false;
  bool _isCodeVerified = false;
  int _codeAttempts = 0;

  final List<String> _specializations = [
    'General Medicine',
    'Pediatrics',
    'Gynecology',
    'Dermatology',
    'Ophthalmology',
    'Orthopedics',
    'Cardiology',
    'Dentistry',
    'Mental Health',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _adminCodeController.dispose();
    super.dispose();
  }

  Future<void> _verifyAdminCode() async {
    if (_adminCodeController.text.isEmpty) {
      AppToast.show(
        context,
        'Please enter the verification code',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isValid = await _authService.validateAdminCode(
        _adminCodeController.text,
      );

      setState(() {
        _isCodeVerified = isValid;
        _codeAttempts++;
        _isLoading = false;
      });

      if (isValid) {
        AppToast.show(context, 'Code verified successfully!');
      } else {
        if (_codeAttempts >= 3) {
          AppToast.show(
            context,
            'Too many incorrect attempts. Please contact support.',
            isError: true,
          );
        } else {
          AppToast.show(
            context,
            'Invalid code. ${3 - _codeAttempts} attempts remaining.',
            isError: true,
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      AppToast.show(
        context,
        'Verification failed: ${e.toString()}',
        isError: true,
      );
    }
  }

  Future<void> _registerDoctor() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isCodeVerified) {
      AppToast.show(
        context,
        'Please verify the admin code first',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final doctor = await _authService.doctorRegister(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        specialization: _selectedSpecialization,
        adminCode: _adminCodeController.text.trim(),
      );

      if (mounted) {
        // Registration successful, navigate to doctor dashboard
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    DoctorDashboard(doctor: doctor),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;
              var tween = Tween(
                begin: begin,
                end: end,
              ).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          'Registration failed: ${e.toString()}',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const PageHeader(
                  title: 'Doctor Registration',
                  subtitle: 'Join our healthcare network',
                  icon: Icons.medical_services_rounded,
                  showBackButton: true,
                ),

                const SizedBox(height: 32),

                // Verification Code Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        _isCodeVerified
                            ? theme.colorScheme.secondary.withOpacity(0.1)
                            : theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          _isCodeVerified
                              ? theme.colorScheme.secondary.withOpacity(0.3)
                              : theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isCodeVerified ? Icons.verified : Icons.shield,
                            color:
                                _isCodeVerified
                                    ? theme.colorScheme.secondary
                                    : theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Verification Code',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color:
                                  _isCodeVerified
                                      ? theme.colorScheme.secondary
                                      : theme.colorScheme.primary,
                            ),
                          ),
                          if (_isCodeVerified) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Verified',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Enter the verification code provided by administrators.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color:
                              _isCodeVerified
                                  ? theme.colorScheme.onSurface.withOpacity(0.7)
                                  : theme.colorScheme.onSurface.withOpacity(
                                    0.7,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _adminCodeController,
                              enabled: !_isCodeVerified && _codeAttempts < 3,
                              obscureText: true,
                              style: theme.textTheme.bodyLarge,
                              decoration: InputDecoration(
                                hintText: 'Enter code',
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color:
                                      _isCodeVerified
                                          ? theme.colorScheme.secondary
                                          : theme.colorScheme.primary,
                                ),
                                filled: true,
                                fillColor:
                                    _adminCodeController.text.isNotEmpty
                                        ? (_isCodeVerified
                                            ? theme.colorScheme.secondary
                                                .withOpacity(0.05)
                                            : theme.colorScheme.error
                                                .withOpacity(0.05))
                                        : theme.colorScheme.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color:
                                        _isCodeVerified
                                            ? theme.colorScheme.secondary
                                            : theme.colorScheme.outline,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color:
                                        _isCodeVerified
                                            ? theme.colorScheme.secondary
                                            : theme.colorScheme.outline,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color:
                                        _isCodeVerified
                                            ? theme.colorScheme.secondary
                                            : theme.colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed:
                                  _isCodeVerified ||
                                          _codeAttempts >= 3 ||
                                          _isLoading
                                      ? null
                                      : _verifyAdminCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _isCodeVerified
                                        ? theme.colorScheme.secondary
                                        : theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 0,
                                ),
                              ),
                              child:
                                  _isLoading
                                      ? SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: theme.colorScheme.onPrimary,
                                          strokeWidth: 3,
                                        ),
                                      )
                                      : Text(
                                        'Verify',
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                              color:
                                                  theme.colorScheme.onPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Registration Form
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: _isCodeVerified ? 1.0 : 0.5,
                  child: IgnorePointer(
                    ignoring: !_isCodeVerified,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Name
                        RuralHealthcareInputField(
                          label: 'Full Name',
                          hintText: 'Dr. John Smith',
                          controller: _nameController,
                          prefixIcon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),

                        // Email
                        RuralHealthcareInputField(
                          label: 'Email Address',
                          hintText: 'doctor@example.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
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

                        // Phone
                        RuralHealthcareInputField(
                          label: 'Phone Number',
                          hintText: '+91 98765 43210',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),

                        // Specialization
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              'Specialization',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Specialization options as selection chips
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children:
                                          _specializations.map((
                                            specialization,
                                          ) {
                                            final isSelected =
                                                _selectedSpecialization ==
                                                specialization;
                                            return ChoiceChip(
                                              label: Text(specialization),
                                              selected: isSelected,
                                              labelStyle: TextStyle(
                                                color:
                                                    isSelected
                                                        ? theme
                                                            .colorScheme
                                                            .onPrimary
                                                        : theme
                                                            .colorScheme
                                                            .onSurface,
                                                fontWeight:
                                                    isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                              ),
                                              backgroundColor:
                                                  theme.colorScheme.surface,
                                              selectedColor:
                                                  theme.colorScheme.primary,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                side: BorderSide(
                                                  color:
                                                      isSelected
                                                          ? Colors.transparent
                                                          : theme
                                                              .colorScheme
                                                              .outline,
                                                  width: 1,
                                                ),
                                              ),
                                              onSelected: (selected) {
                                                if (selected) {
                                                  setState(() {
                                                    _selectedSpecialization =
                                                        specialization;
                                                  });
                                                }
                                              },
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Submit Button
                        RuralHealthcareButton(
                          text: 'Complete Registration',
                          icon: Icons.how_to_reg,
                          onPressed: _registerDoctor,
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
