import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AppointmentHandlerPage extends StatefulWidget {
  final String patientName;
  final Map<String, dynamic>? appointmentData;

  const AppointmentHandlerPage({
    super.key,
    required this.patientName,
    this.appointmentData,
  });

  @override
  State<AppointmentHandlerPage> createState() => _AppointmentHandlerPageState();
}

class _AppointmentHandlerPageState extends State<AppointmentHandlerPage> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _prescriptionController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();

  bool _isLoading = false;
  String _currentStatus = 'pending';

  @override
  void initState() {
    super.initState();
    if (widget.appointmentData != null) {
      _currentStatus = widget.appointmentData!['status'] ?? 'pending';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _prescriptionController.dispose();
    _diagnosisController.dispose();
    super.dispose();
  }

  Future<void> _updateAppointmentStatus(String newStatus) async {
    setState(() => _isLoading = true);

    try {
      // Query to find the appointment document by patient name
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('appointments')
              .where('patientName', isEqualTo: widget.patientName)
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception(
          'Appointment not found for patient: ${widget.patientName}',
        );
      }

      final appointmentDoc = querySnapshot.docs.first;

      await appointmentDoc.reference.update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
        'handledBy': 'Dr. Current User', // Replace with actual doctor name
      });

      setState(() => _currentStatus = newStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment status updated to $newStatus'),
          backgroundColor: _getStatusColor(newStatus),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _completeAppointment() async {
    if (_diagnosisController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a diagnosis before completing'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Query to find the appointment document by patient name
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('appointments')
              .where('patientName', isEqualTo: widget.patientName)
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception(
          'Appointment not found for patient: ${widget.patientName}',
        );
      }

      final appointmentDoc = querySnapshot.docs.first;

      await appointmentDoc.reference.update({
        'status': 'completed',
        'diagnosis': _diagnosisController.text.trim(),
        'prescription': _prescriptionController.text.trim(),
        'doctorNotes': _notesController.text.trim(),
        'completedAt': FieldValue.serverTimestamp(),
        'handledBy': 'Dr. Current User', // Replace with actual doctor name
      });

      setState(() => _currentStatus = 'completed');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Optionally navigate back after completion
      // Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error completing appointment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'in_progress':
        return Icons.healing;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Handle Appointment'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('appointments')
                .where('patientName', isEqualTo: widget.patientName)
                .limit(1)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No appointment found for patient: ${widget.patientName}',
              ),
            );
          }

          final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          _currentStatus = data['status'] ?? 'pending';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient Information Card
                _buildPatientInfoCard(data),
                const SizedBox(height: 16),

                // Appointment Details Card
                _buildAppointmentDetailsCard(data),
                const SizedBox(height: 16),

                // Status Management Card
                _buildStatusManagementCard(),
                const SizedBox(height: 16),

                // Medical Information Card (only show if in progress or completed)
                if (_currentStatus == 'in_progress' ||
                    _currentStatus == 'completed')
                  _buildMedicalInfoCard(data),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPatientInfoCard(Map<String, dynamic> data) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Patient Information',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('Name', data['patientName'] ?? 'Unknown'),
            _buildInfoRow('Phone', data['phoneNumber'] ?? 'Not provided'),
            _buildInfoRow('Reason', data['reason'] ?? 'General consultation'),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentDetailsCard(Map<String, dynamic> data) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Appointment Details',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('Time Slot', data['timeSlot'] ?? 'Not specified'),
            _buildInfoRow('Date', _formatDate(data['appointmentDate'])),
            _buildInfoRow('Created', _formatDate(data['createdAt'])),
            Row(
              children: [
                const Text(
                  'Status: ',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(_currentStatus).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(_currentStatus)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(_currentStatus),
                        size: 16,
                        color: _getStatusColor(_currentStatus),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _currentStatus.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(_currentStatus),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusManagementCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.manage_accounts, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Manage Appointment',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Status Action Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_currentStatus == 'pending')
                  ElevatedButton.icon(
                    onPressed:
                        _isLoading
                            ? null
                            : () => _updateAppointmentStatus('confirmed'),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Confirm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),

                if (_currentStatus == 'confirmed')
                  ElevatedButton.icon(
                    onPressed:
                        _isLoading
                            ? null
                            : () => _updateAppointmentStatus('in_progress'),
                    icon: const Icon(Icons.healing),
                    label: const Text('Start Treatment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),

                if (_currentStatus != 'completed' &&
                    _currentStatus != 'cancelled')
                  ElevatedButton.icon(
                    onPressed:
                        _isLoading
                            ? null
                            : () => _updateAppointmentStatus('cancelled'),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalInfoCard(Map<String, dynamic> data) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medical_services, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Medical Information',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),

            // Diagnosis Field
            TextField(
              controller: _diagnosisController,
              decoration: const InputDecoration(
                labelText: 'Diagnosis *',
                hintText: 'Enter patient diagnosis...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Prescription Field
            TextField(
              controller: _prescriptionController,
              decoration: const InputDecoration(
                labelText: 'Prescription',
                hintText:
                    'Enter prescribed medications or Handover to patient...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Doctor Notes Field
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Doctor Notes',
                hintText: 'Additional notes...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Complete Appointment Button
            if (_currentStatus == 'in_progress')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _completeAppointment,
                  icon:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.check_circle),
                  label: Text(
                    _isLoading ? 'Completing...' : 'Complete Appointment',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Not specified';

    try {
      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is String) {
        date = DateTime.parse(timestamp);
      } else {
        return timestamp.toString();
      }
      return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }
}
