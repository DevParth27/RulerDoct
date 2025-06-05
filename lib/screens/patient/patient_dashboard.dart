import 'package:flutter/material.dart';
import 'package:rolodoct/auth/auth_screen.dart';
import 'package:rolodoct/models/user_model.dart';
import 'package:rolodoct/screens/doctor/doctor_details_sheet.dart';
import 'package:rolodoct/screens/patient/patient_home_widget.dart';
import 'package:rolodoct/screens/patient/patient_profile_widget.dart';
import 'package:rolodoct/services/auth_service.dart';
import 'package:rolodoct/widgets/common_widgets.dart';

class PatientDashboard extends StatefulWidget {
  final UserModel patient;

  const PatientDashboard({super.key, required this.patient});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final AuthService _authService = AuthService();
  List<UserModel> _doctors = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() => _isLoading = true);
    try {
      final doctors = await _authService.getAllDoctors();
      setState(() {
        _doctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AppToast.show(
          context,
          'Failed to load doctors: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(
          context,
          'Sign out failed: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  void _showDoctorDetails(UserModel doctor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DoctorDetailsSheet(doctor: doctor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            // Home Page
            PatientHomeWidget(
              patient: widget.patient,
              doctors: _doctors,
              isLoading: _isLoading,
              onRefresh: _loadDoctors,
              onDoctorSelected: _showDoctorDetails,
            ),

            // Profile Page
            PatientProfileWidget(
              patient: widget.patient,
              onSignOut: _handleSignOut,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
