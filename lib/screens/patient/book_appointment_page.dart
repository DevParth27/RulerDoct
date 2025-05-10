import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rolodoct/models/appointment_model.dart';
import 'package:rolodoct/models/user_model.dart';
import 'package:rolodoct/services/storage_service.dart';
import 'package:rolodoct/widgets/common_widgets.dart';

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _storageService = StorageService();

  // Form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _selectedDoctorType = '';
  String _selectedTimeSlot = '';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  // Lists for dropdowns
  List<String> _doctorTypes = [];
  List<String> _availableTimeSlots = [];

  bool _isLoading = false;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load current user
      _currentUser = await _storageService.getCurrentUser();

      // If we have a current user and they're a patient, pre-fill the form
      // if (_currentUser != null && _currentUser!.role == 'patient') {
      //   _nameController.text = _currentUser!.name;
      //   _phoneController.text = _currentUser!.phone;
      // }

      // Load doctor types/specializations
      //  _doctorTypes = await _storageService.getAvailableSpecializations();

      // Load time slots
      _availableTimeSlots = _storageService.getAvailableTimeSlots();

      if (_doctorTypes.isNotEmpty) {
        _selectedDoctorType = _doctorTypes.first;
      }

      if (_availableTimeSlots.isNotEmpty) {
        _selectedTimeSlot = _availableTimeSlots.first;
      }
    } catch (e) {
      AppToast.show(context, 'Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black38,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot =
            _availableTimeSlots.first; // Reset time slot when date changes
      });
      _updateAvailableTimeSlots();
    }
  }

  Future<void> _updateAvailableTimeSlots() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allTimeSlots = _storageService.getAvailableTimeSlots();
      final availableSlots = <String>[];

      for (final slot in allTimeSlots) {
        final isAvailable = await _storageService.isTimeSlotAvailable(
          _selectedDoctorType,
          _selectedDate,
          slot,
        );

        if (isAvailable) {
          availableSlots.add(slot);
        }
      }

      setState(() {
        _availableTimeSlots =
            availableSlots.isEmpty ? allTimeSlots : availableSlots;
        if (_availableTimeSlots.isNotEmpty &&
            !_availableTimeSlots.contains(_selectedTimeSlot)) {
          _selectedTimeSlot = _availableTimeSlots.first;
        }
      });
    } catch (e) {
      AppToast.show(context, 'Error checking available time slots');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _bookAppointment() async {
    if (_currentUser == null || _currentUser!.role != 'patient') {
      AppToast.show(context, 'Only patients can book appointments');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final appointment = AppointmentModel(
        id: '',
        patientId: _currentUser!.id,
        patientName: _nameController.text,
        patientPhone: _phoneController.text,
        doctorType: _selectedDoctorType,
        timeSlot: _selectedTimeSlot,
        date: _selectedDate,
      );

      await _storageService.saveAppointment(appointment);

      AppToast.show(context, 'Appointment booked successfully!');
      Navigator.of(context).pop(true); // Return success to previous screen
    } catch (e) {
      AppToast.show(context, 'Error booking appointment: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if current user is a patient
    if (_currentUser != null && _currentUser!.role != 'patient') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Book Appointment'),
          backgroundColor: Colors.blueAccent,
        ),
        body: const Center(
          child: Text(
            'Only patients can book appointments',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: Colors.blueAccent,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone field
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Doctor Type dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value:
                                _selectedDoctorType.isEmpty
                                    ? null
                                    : _selectedDoctorType,
                            hint: const Text('Select Doctor Type'),
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedDoctorType = newValue;
                                });
                                _updateAvailableTimeSlots();
                              }
                            },
                            items:
                                _doctorTypes.map<DropdownMenuItem<String>>((
                                  String value,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Date picker
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today),
                              const SizedBox(width: 8),
                              Text(
                                'Date: ${DateFormat('EEE, MMM d, yyyy').format(_selectedDate)}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Time slot dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value:
                                _selectedTimeSlot.isEmpty
                                    ? null
                                    : _selectedTimeSlot,
                            hint: const Text('Select Time Slot'),
                            isExpanded: true,
                            icon: const Icon(Icons.access_time),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedTimeSlot = newValue;
                                });
                              }
                            },
                            items:
                                _availableTimeSlots
                                    .map<DropdownMenuItem<String>>((
                                      String value,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    })
                                    .toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Submit button
                      RuralHealthcareButton(
                        text: 'Book Appointment',
                        icon: Icons.calendar_today,
                        isLoading: _isLoading,
                        onPressed: _bookAppointment,
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
