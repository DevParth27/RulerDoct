import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rolodoct/models/appointment_model.dart';
import 'package:rolodoct/models/user_model.dart';
import 'package:rolodoct/screens/patient/book_appointment_page.dart';
import 'package:rolodoct/services/storage_service.dart';
import 'package:rolodoct/widgets/common_widgets.dart';

class MyAppointmentsPage extends StatefulWidget {
  const MyAppointmentsPage({Key? key}) : super(key: key);

  @override
  State<MyAppointmentsPage> createState() => _MyAppointmentsPageState();
}

class _MyAppointmentsPageState extends State<MyAppointmentsPage> {
  final _storageService = StorageService();
  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _currentUser = await _storageService.getCurrentUser();

      if (_currentUser != null) {
        if (_currentUser!.role == 'patient') {
          _appointments = await _storageService.getAppointmentsByPatientId(
            _currentUser!.id,
          );
          // } else if (_currentUser!.role == 'doctor') {
          //   // If it's a doctor, we could filter by their specialization
          //   _appointments = await _storageService.getAppointmentsByDoctorType(
          //     _currentUser!.specialization,
          //   );
        }

        // Sort appointments by date and time (most recent first)
        _appointments.sort((a, b) {
          final dateComparison = b.date.compareTo(a.date);
          if (dateComparison != 0) return dateComparison;
          return a.timeSlot.compareTo(b.timeSlot);
        });
      }
    } catch (e) {
      AppToast.show(context, 'Error loading appointments: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelAppointment(AppointmentModel appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Appointment'),
            content: const Text(
              'Are you sure you want to cancel this appointment?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('NO'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('YES'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _storageService.updateAppointmentStatus(
          appointment.id,
          'cancelled',
        );
        AppToast.show(context, 'Appointment cancelled successfully');
        _loadAppointments(); // Refresh the list
      } catch (e) {
        AppToast.show(context, 'Error cancelling appointment: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToBookAppointment() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const BookAppointmentPage()),
    );

    if (result == true) {
      _loadAppointments(); // Refresh appointments if new one was booked
    }
  }

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    final bool isPast = appointment.date.isBefore(
      DateTime.now().subtract(const Duration(hours: 1)),
    );

    final bool isCancelled = appointment.status == 'cancelled';

    Color statusColor;
    if (isCancelled) {
      statusColor = Colors.red;
    } else if (isPast) {
      statusColor = Colors.grey;
    } else if (appointment.status == 'confirmed') {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.orange;
    }

    String statusText =
        isCancelled
            ? 'Cancelled'
            : isPast
            ? 'Completed'
            : appointment.status == 'confirmed'
            ? 'Confirmed'
            : 'Pending';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Dr. Type: ${appointment.doctorType}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEE, MMM d, yyyy').format(appointment.date),
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  appointment.timeSlot,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  appointment.patientPhone,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),

            if (!isPast && !isCancelled && _currentUser?.role == 'patient')
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _cancelAppointment(appointment),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser != null && _currentUser!.role != 'patient') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Appointments'),
          backgroundColor: Colors.blueAccent,
        ),
        body: const Center(
          child: Text(
            'Only patients can view appointments on this page',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: Colors.blueAccent,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _appointments.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 70,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No appointments found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _navigateToBookAppointment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Book an Appointment'),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadAppointments,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _appointments.length,
                  itemBuilder: (context, index) {
                    return _buildAppointmentCard(_appointments[index]);
                  },
                ),
              ),
      floatingActionButton:
          _currentUser?.role == 'patient'
              ? FloatingActionButton(
                onPressed: _navigateToBookAppointment,
                backgroundColor: Colors.blueAccent,
                child: const Icon(Icons.add),
              )
              : null,
    );
  }
}
