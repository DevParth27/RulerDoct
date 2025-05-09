import 'package:flutter/material.dart';
import 'package:rolodoct/auth/auth_screen.dart';
import 'package:rolodoct/models/user_model.dart';
import 'package:rolodoct/screens/doctor/doctor_home_widget.dart';
import 'package:rolodoct/screens/doctor/doctor_profile_widget.dart';
import 'package:rolodoct/screens/patient/patient_details_sheet.dart';
import 'package:rolodoct/services/auth_service.dart';
import 'package:rolodoct/widgets/common_widgets.dart';

class DoctorDashboard extends StatefulWidget {
  final UserModel doctor;

  const DoctorDashboard({super.key, required this.doctor});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final AuthService _authService = AuthService();
  List<UserModel> _patients = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => _isLoading = true);
    try {
      final patients = await _authService.getAllPatients();
      setState(() {
        _patients = patients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AppToast.show(
          context,
          'Failed to load patients: ${e.toString()}',
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

  void _showPatientDetails(UserModel patient) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PatientDetailsSheet(patient: patient),
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
            DoctorHomeWidget(
              doctor: widget.doctor,
              patients: _patients,
              isLoading: _isLoading,
              onRefresh: _loadPatients,
              onPatientSelected: _showPatientDetails,
            ),

            // Profile Page
            DoctorProfileWidget(
              doctor: widget.doctor,
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
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton(
                onPressed: () {
                  AppToast.show(context, 'Add patient feature coming soon!');
                },
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 4,
                child: const Icon(Icons.add),
              )
              : null,
    );
  }
}
