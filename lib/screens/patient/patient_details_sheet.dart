import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rolodoct/models/user_model.dart';
import 'package:rolodoct/screens/patient/book_appointment_page.dart';
import 'package:rolodoct/widgets/common_widgets.dart';

class PatientDetailsSheet extends StatefulWidget {
  final UserModel patient;

  const PatientDetailsSheet({super.key, required this.patient});

  @override
  State<PatientDetailsSheet> createState() => _PatientDetailsSheetState();
}

class _PatientDetailsSheetState extends State<PatientDetailsSheet> {
  bool _isEditingHealth = false;
  bool _isLoading = true;
  bool _isSaving = false;

  late TextEditingController _bloodTypeController;
  late TextEditingController _recentVisitController;
  late TextEditingController _ongoingTreatmentController;

  // Health data variables
  String _bloodType = '';
  String _recentVisit = '';
  String _ongoingTreatment = '';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _bloodTypeController = TextEditingController();
    _recentVisitController = TextEditingController();
    _ongoingTreatmentController = TextEditingController();
    _loadHealthData();
  }

  @override
  void dispose() {
    _bloodTypeController.dispose();
    _recentVisitController.dispose();
    _ongoingTreatmentController.dispose();
    super.dispose();
  }

  Future<void> _loadHealthData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get patient document from Firestore
      DocumentSnapshot patientDoc =
          await _firestore
              .collection('Patient')
              .doc(widget.patient.id) // Assuming patient has uid field
              .get();

      if (patientDoc.exists) {
        Map<String, dynamic> data = patientDoc.data() as Map<String, dynamic>;

        // Get health summary data
        Map<String, dynamic>? healthSummary =
            data['healthSummary'] as Map<String, dynamic>?;

        setState(() {
          _bloodType = healthSummary?['bloodType'] ?? 'Not specified';
          _recentVisit = healthSummary?['recentVisit'] ?? 'No recent visits';
          _ongoingTreatment = healthSummary?['ongoingTreatment'] ?? 'None';

          _bloodTypeController.text = _bloodType;
          _recentVisitController.text = _recentVisit;
          _ongoingTreatmentController.text = _ongoingTreatment;
          _isLoading = false;
        });
      } else {
        // If document doesn't exist, set default values
        setState(() {
          _bloodType = 'Not specified';
          _recentVisit = 'No recent visits';
          _ongoingTreatment = 'None';

          _bloodTypeController.text = _bloodType;
          _recentVisitController.text = _recentVisit;
          _ongoingTreatmentController.text = _ongoingTreatment;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        AppToast.show(context, 'Error loading health data: ${e.toString()}');
      }
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditingHealth = !_isEditingHealth;
    });
  }

  Future<void> _saveHealthData() async {
    try {
      setState(() {
        _isSaving = true;
      });

      // Prepare health summary data
      Map<String, dynamic> healthSummaryData = {
        'bloodType': _bloodTypeController.text.trim(),
        'recentVisit': _recentVisitController.text.trim(),
        'ongoingTreatment': _ongoingTreatmentController.text.trim(),
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await _firestore.collection('Patient').doc(widget.patient.id).set({
        'healthSummary': healthSummaryData,
      }, SetOptions(merge: true)); // Use merge to not overwrite other fields

      // Update local state
      setState(() {
        _bloodType = _bloodTypeController.text.trim();
        _recentVisit = _recentVisitController.text.trim();
        _ongoingTreatment = _ongoingTreatmentController.text.trim();
        _isEditingHealth = false;
        _isSaving = false;
      });

      if (mounted) {
        AppToast.show(context, 'Health summary updated successfully!');
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        AppToast.show(context, 'Error saving health data: ${e.toString()}');
      }
    }
  }

  void _cancelEdit() {
    // Reset controllers to original values
    _bloodTypeController.text = _bloodType;
    _recentVisitController.text = _recentVisit;
    _ongoingTreatmentController.text = _ongoingTreatment;

    setState(() {
      _isEditingHealth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Patient Details',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: theme.colorScheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Patient profile
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
                  child: Text(
                    widget.patient.name.isNotEmpty
                        ? widget.patient.name[0].toUpperCase()
                        : 'P',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.patient.name,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                if (widget.patient.phone != null &&
                    widget.patient.phone!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.patient.phone!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Patient health summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.5),
              ),
            ),
            child:
                _isLoading
                    ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Health Summary',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (!_isEditingHealth)
                              IconButton(
                                onPressed: _toggleEdit,
                                icon: Icon(
                                  Icons.edit,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                                tooltip: 'Edit Health Summary',
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (_isEditingHealth) ...[
                          // Edit mode
                          _buildEditableHealthMetric(
                            theme,
                            'Blood Type',
                            _bloodTypeController,
                            Icons.bloodtype,
                          ),
                          Divider(
                            color: theme.colorScheme.outline.withOpacity(0.3),
                          ),
                          _buildEditableHealthMetric(
                            theme,
                            'Recent Visit',
                            _recentVisitController,
                            Icons.event_note,
                          ),
                          Divider(
                            color: theme.colorScheme.outline.withOpacity(0.3),
                          ),
                          _buildEditableHealthMetric(
                            theme,
                            'Ongoing Treatment',
                            _ongoingTreatmentController,
                            Icons.medical_services,
                          ),
                          const SizedBox(height: 16),

                          // Save/Cancel buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isSaving ? null : _saveHealthData,
                                  icon:
                                      _isSaving
                                          ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                          : const Icon(Icons.save, size: 18),
                                  label: Text(_isSaving ? 'Saving...' : 'Save'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _isSaving ? null : _cancelEdit,
                                  icon: const Icon(Icons.cancel, size: 18),
                                  label: const Text('Cancel'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: theme.colorScheme.error,
                                    side: BorderSide(
                                      color: theme.colorScheme.error,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          // View mode
                          _buildHealthMetricRow(
                            theme,
                            'Blood Type',
                            _bloodType,
                            Icons.bloodtype,
                          ),
                          Divider(
                            color: theme.colorScheme.outline.withOpacity(0.3),
                          ),
                          _buildHealthMetricRow(
                            theme,
                            'Recent Visit',
                            _recentVisit,
                            Icons.event_note,
                          ),
                          Divider(
                            color: theme.colorScheme.outline.withOpacity(0.3),
                          ),
                          _buildHealthMetricRow(
                            theme,
                            'Ongoing Treatment',
                            _ongoingTreatment,
                            Icons.medical_services,
                          ),
                        ],
                      ],
                    ),
          ),
          const SizedBox(height: 32),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => (AppointmentBookingPage()),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: theme.colorScheme.onPrimary,
                  ),
                  label: Text(
                    'New Appointment',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    AppToast.show(
                      context,
                      'Medical history feature coming soon!',
                    );
                  },
                  icon: Icon(Icons.history, color: theme.colorScheme.primary),
                  label: Text(
                    'View History',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetricRow(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
          Flexible(
            child: Text(
              value.isEmpty ? 'Not specified' : value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableHealthMetric(
    ThemeData theme,
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
          const SizedBox(width: 16),
          SizedBox(
            width: 140,
            child: TextField(
              controller: controller,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
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
