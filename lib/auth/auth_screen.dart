import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rolodoct/auth/doctor_registration_screen.dart';
import 'package:rolodoct/models/doctor_model.dart';
import 'package:rolodoct/screens/patient/patient_dashboard.dart';
import 'package:rolodoct/services/auth_service.dart';
import 'package:rolodoct/widgets/common_widgets.dart';
import 'package:rolodoct/widgets/terms_conditions_modal.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    // Clear form when switching tabs
    if (_tabController.indexIsChanging) {
      _nameController.clear();
      _phoneController.clear();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _patientLogin() async {
    if (!_formKey.currentState!.validate()) {
      // Add subtle shake animation for invalid form
      _animateInvalidForm();
      return;
    }

    setState(() => _isLoading = true);

    // Add vibration feedback if available
    // HapticFeedback.mediumImpact();

    final name = _nameController.text.trim();
    final phone =
        _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim();

    try {
      // Step 1: Call your existing auth service
      final patient = await _authService.patientLogin(name: name, phone: phone);

      // Step 2: Save patient info to Firestore (optional if already stored by AuthService)
      await FirebaseFirestore.instance.collection('Patient').add({
        'Patient Name': name,
        'Patient Number': phone ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'device_info': {
          'platform': Theme.of(context).platform.toString(),
          'last_login': DateTime.now().toIso8601String(),
        },
      });

      // Step 3: Navigate to dashboard with animation
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    PatientDashboard(patient: patient),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeOutQuart;
              final tween = Tween(
                begin: begin,
                end: end,
              ).chain(CurveTween(curve: curve));

              // Add fade transition along with the slide
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          'Login failed: ${e.toString()}',
          isError: true,
          //    duration: const Duration(seconds: 4),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Animation for invalid form submission
  void _animateInvalidForm() {
    const int count = 3;
    const double distance = 10;
    const Duration duration = Duration(milliseconds: 80);

    final controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: count * 2 * duration.inMilliseconds),
    );

    final Animation<Offset> animation = TweenSequence<Offset>(
      List.generate(count * 2, (index) {
        final bool isEven = index.isEven;
        final double direction = isEven ? 1 : -1;
        final double tween = isEven ? distance : 0;

        return TweenSequenceItem(
          tween: Tween(
            begin: Offset(direction * tween, 0),
            end: Offset(direction * (isEven ? 0 : distance), 0),
          ),
          weight: 1,
        );
      }),
    ).animate(controller);

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      }
    });

    controller.forward();

    // Add the animation to the form field container
    setState(() {});
  }

  void _navigateToDoctorRegistration() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                const DoctorRegistrationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenSize.height * 0.05),

                  // Header with logo
                  Hero(
                    tag: 'app_logo',
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.local_hospital_rounded,
                            color: theme.colorScheme.primary,
                            size: 36,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rural Care',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Healthcare for everyone',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenSize.height * 0.08),

                  // Welcome message with animation
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      'Welcome! 👋',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Choose how you want to continue',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenSize.height * 0.05),

                  // Role selection tabs
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.08),
                          blurRadius: 12,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      padding: const EdgeInsets.all(4),
                      labelStyle: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelStyle: theme.textTheme.titleMedium,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: theme.colorScheme.primary,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      labelColor: theme.colorScheme.onPrimary,
                      unselectedLabelColor: theme.colorScheme.onSurface,
                      dividerColor: Colors.transparent,
                      splashBorderRadius: BorderRadius.circular(12),
                      overlayColor: WidgetStateProperty.resolveWith<Color?>((
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.hovered))
                          return theme.colorScheme.primary.withOpacity(0.1);
                        return null;
                      }),
                      tabs: const [
                        Tab(
                          height: 58,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_rounded),
                              SizedBox(width: 8),
                              Text('Patient'),
                            ],
                          ),
                        ),
                        Tab(
                          height: 58,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.medical_services_rounded),
                              SizedBox(width: 8),
                              Text('Doctor'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenSize.height * 0.03),

                  // Tab content
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _tabController.index == 0 ? 400 : 300,
                      curve: Curves.easeInOut,
                      child: TabBarView(
                        controller: _tabController,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          // Patient login form
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 400),
                            opacity: _tabController.index == 0 ? 1.0 : 0.0,
                            child: Card(
                              elevation: 0,
                              color: theme.colorScheme.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: theme.colorScheme.outline.withOpacity(
                                    0.2,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Enter your details',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                    ),
                                    const SizedBox(height: 10),
                                    RuralHealthcareInputField(
                                      label: 'Full Name',
                                      hintText: 'Enter your name',
                                      controller: _nameController,
                                      prefixIcon: Icons.person_outline_rounded,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your name';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    RuralHealthcareInputField(
                                      label: 'Phone Number',
                                      hintText: 'Enter your phone number',
                                      controller: _phoneController,
                                      prefixIcon: Icons.phone_outlined,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your number';
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.phone,
                                    ),
                                    const SizedBox(height: 5),
                                    RuralHealthcareButton(
                                      text: 'Continue as Patient',
                                      icon: Icons.arrow_forward_rounded,
                                      onPressed: _patientLogin,
                                      isLoading: _isLoading,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Doctor registration navigation
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 400),
                            opacity: _tabController.index == 1 ? 1.0 : 0.0,
                            child: Card(
                              elevation: 0,
                              color: theme.colorScheme.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: theme.colorScheme.outline.withOpacity(
                                    0.2,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Doctor info text
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline_rounded,
                                            color: theme.colorScheme.primary,
                                            size: 26,
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              'Doctors need to register with a verification code provided by administrators.',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color:
                                                        theme
                                                            .colorScheme
                                                            .onSurface,
                                                    height: 1.3,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    RuralHealthcareButton(
                                      text: 'Register as Doctor',
                                      icon: Icons.app_registration_rounded,
                                      onPressed: _navigateToDoctorRegistration,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom message
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          children: [
                            const TextSpan(
                              text: 'By continuing, you agree to our ',
                            ),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  const TermsAndConditionsModal(),
                                        ),
                                      );
                                    },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
