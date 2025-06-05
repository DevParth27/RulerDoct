import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rolodoct/models/patient_model.dart';
import 'package:rolodoct/models/user_model.dart';
import 'package:rolodoct/screens/doctor/Appointment/handleAppointment.dart';
import 'package:rolodoct/widgets/common_widgets.dart';

class DoctorHomeWidget extends StatelessWidget {
  final UserModel doctor;
  final List<UserModel> patients;
  final bool isLoading;
  final Function() onRefresh;
  final Function(UserModel) onPatientSelected;

  const DoctorHomeWidget({
    super.key,
    required this.doctor,
    required this.patients,
    required this.isLoading,
    required this.onRefresh,
    required this.onPatientSelected,
  });
  Future<List<Patient>> fetchPatients() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Patient').get();

    return snapshot.docs.map((doc) => Patient.fromMap(doc.data())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM d');
    final formattedDate = dateFormat.format(now);

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: theme.colorScheme.primary,
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Doctor Greeting
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    doctor.name.isNotEmpty ? doctor.name[0].toUpperCase() : 'D',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back Doctor! ,',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      doctor.name,
                      style: theme.textTheme.headlineSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      doctor.specialization ?? 'Doctor',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Date and Stats
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.onSurface.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Stats Cards
                FutureBuilder<QuerySnapshot>(
                  future:
                      FirebaseFirestore.instance
                          .collection('appointments')
                          .get(),
                  builder: (context, snapshot) {
                    // Default values
                    String totalCount = '0';
                    String pendingCount = '0';
                    String patientCount1 = '0';
                    // Calculate counts only if we have data
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData &&
                        snapshot.data != null) {
                      final docs = snapshot.data!.docs;
                      totalCount = docs.length.toString();

                      int pending = 0;
                      for (var doc in docs) {
                        try {
                          final data = doc.data() as Map<String, dynamic>;
                          if (data['status']?.toString().toLowerCase() ==
                              'pending') {
                            pending++;
                          }
                        } catch (e) {
                          // Skip problematic documents
                        }
                      }
                      int patientCount = 0;

                      for (var doc in snapshot.data!.docs) {
                        if (doc.exists) {
                          patientCount++;
                        }
                      }
                      pendingCount = pending.toString();
                      patientCount1 = patientCount.toString();
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            theme,
                            Icons.people_alt_outlined,
                            patientCount1,
                            'Patients',
                            theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            theme,
                            Icons.calendar_month_outlined,
                            totalCount,
                            'Appointments',
                            theme.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            theme,
                            Icons.pending_actions_outlined,
                            pendingCount,
                            'Pending',
                            theme.colorScheme.tertiary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Today's Appointments
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('appointments')
                          .orderBy('timeSlot') // Order by time
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        children: [
                          _buildLoadingAppointmentItem(theme),
                          Divider(
                            color: theme.colorScheme.onPrimary.withOpacity(0.2),
                            height: 20,
                          ),
                          _buildLoadingAppointmentItem(theme),
                        ],
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading appointments',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary.withOpacity(0.8),
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_busy,
                              color: theme.colorScheme.onPrimary.withOpacity(
                                0.6,
                              ),
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No appointments today',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimary.withOpacity(
                                  0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final appointments = snapshot.data!.docs;

                    return Column(
                      children: [
                        // Show maximum 5 appointments to avoid overflow
                        ...appointments.take(5).map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final time = data['timeSlot'] ?? '00:00 AM';
                          final patientName =
                              data['patientName'] ?? 'Unknown Patient';
                          final reason =
                              data['reason'] ?? 'General Consultation';

                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  // Navigate to appointment details
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => AppointmentHandlerPage(
                                            patientName: patientName,
                                            appointmentData: data,
                                          ),
                                    ),
                                  );
                                },
                                child: _buildAppointmentItem(
                                  theme,
                                  time,
                                  patientName,
                                  reason,
                                ),
                              ),
                              if (appointments.indexOf(doc) <
                                  appointments.take(5).length - 1)
                                Divider(
                                  color: theme.colorScheme.onPrimary
                                      .withOpacity(0.2),
                                  height: 20,
                                ),
                            ],
                          );
                        }),

                        // Show "View All" if there are more than 5 appointments
                        if (appointments.length > 5) ...[
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () {
                              // Navigate to full appointments list
                              // Navigator.push(context, MaterialPageRoute(builder: (context) => AllAppointmentsPage()));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onPrimary.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: theme.colorScheme.onPrimary
                                      .withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                '+${appointments.length - 5} more appointments',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimary
                                      .withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Patients Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Patients',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: onRefresh,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Refresh',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.refresh,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Patients List
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (patients.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 48,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No patients registered yet',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'New patients will appear here after they register',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            )
          else
            FutureBuilder<List<Patient>>(
              future: fetchPatients(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No patients found.'));
                }

                final patients = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    return PatientCard(
                      name: patient.name,
                      phone: patient.phone,
                      onTap:
                          () => onPatientSelected(
                            UserModel(
                              id: '', // Add doc.id here if available
                              name: patient.name,
                              phone: patient.phone,
                              email: null,
                              role: 'patient',
                              specialization: null,
                              createdAt:
                                  DateTime.now(), // or use proper timestamp if available
                            ),
                          ),
                      // ✅ no cast needed
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    IconData icon,
    String count,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // String _getTodayDateString() {
  //   final now = DateTime.now();
  //   return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  // }

  Widget _buildLoadingAppointmentItem(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.onPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '...',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onPrimary.withOpacity(0.5),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 16,
                width: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 14,
                width: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.onPrimary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_forward_ios,
            color: theme.colorScheme.onPrimary.withOpacity(0.5),
            size: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentItem(
    ThemeData theme,
    String time,
    String patientName,
    String reason,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.onPrimary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            time,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patientName,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                reason,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.onPrimary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_forward_ios,
            color: theme.colorScheme.onPrimary,
            size: 16,
          ),
        ),
      ],
    );
  }
}
