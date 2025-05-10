import 'dart:convert';
import 'package:rolodoct/models/user_model.dart';
import 'package:rolodoct/models/appointment_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static const String _currentUserKey = 'current_user';
  static const String _usersKey = 'users';
  static const String _adminCodeKey = 'admin_code';
  static const String _appointmentsKey = 'appointments';

  // Hardcoded admin code for doctor registration validation
  static const String defaultAdminCode = 'testDoctor1';

  // Get currently logged-in user
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);

    if (userJson == null) return null;

    try {
      return UserModel.fromMap(json.decode(userJson));
    } catch (e) {
      await prefs.remove(_currentUserKey);
      return null;
    }
  }

  // Save current user session
  Future<void> saveCurrentUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, json.encode(user.toMap()));
  }

  // Clear current user (logout)
  Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // Get all saved users
  Future<List<UserModel>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_usersKey) ?? [];

    return usersJson
        .map((userStr) => UserModel.fromMap(json.decode(userStr)))
        .toList();
  }

  // Get users by role
  Future<List<UserModel>> getUsersByRole(String role) async {
    final users = await getAllUsers();
    return users.where((user) => user.role == role).toList();
  }

  // Add new user
  Future<UserModel> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_usersKey) ?? [];

    // Generate ID if new user
    final newUser =
        user.id.isEmpty ? user.copyWith(id: const Uuid().v4()) : user;

    // Check if user already exists and update
    final updatedUsers = await _updateExistingUser(usersJson, newUser);

    await prefs.setStringList(_usersKey, updatedUsers);
    return newUser;
  }

  // Update or add user to storage
  Future<List<String>> _updateExistingUser(
    List<String> usersJson,
    UserModel newUser,
  ) async {
    bool found = false;
    final updatedUsers = <String>[];

    for (final userStr in usersJson) {
      final user = UserModel.fromMap(json.decode(userStr));

      if (user.id == newUser.id) {
        updatedUsers.add(json.encode(newUser.toMap()));
        found = true;
      } else {
        updatedUsers.add(userStr);
      }
    }

    if (!found) {
      updatedUsers.add(json.encode(newUser.toMap()));
    }

    return updatedUsers;
  }

  // Validate doctor registration code
  Future<bool> validateAdminCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_adminCodeKey) ?? defaultAdminCode;

    return code == savedCode;
  }

  // Seed initial data (for sample/demo purposes)
  Future<void> seedInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_usersKey);

    // Only seed if no data exists
    if (usersJson == null || usersJson.isEmpty) {
      final sampleDoctors = [
        UserModel(
          id: const Uuid().v4(),
          name: 'Dr. Sarah Johnson',
          email: 'sarah.johnson@example.com',
          phone: '+1234567890',
          role: 'doctor',
          specialization: 'General Medicine',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        UserModel(
          id: const Uuid().v4(),
          name: 'Dr. Rajesh Patel',
          email: 'rajesh.patel@example.com',
          phone: '+0987654321',
          role: 'doctor',
          specialization: 'Pediatrics',
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
        ),
      ];

      final samplePatients = [
        UserModel(
          id: const Uuid().v4(),
          name: 'Mary Smith',
          phone: '+1122334455',
          role: 'patient',
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
        UserModel(
          id: const Uuid().v4(),
          name: 'John Kumar',
          phone: '+5566778899',
          role: 'patient',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ];

      final allUsers = [...sampleDoctors, ...samplePatients];
      final encodedUsers = allUsers.map((u) => json.encode(u.toMap())).toList();

      await prefs.setStringList(_usersKey, encodedUsers);
    }
  }

  // ==================== APPOINTMENT METHODS ====================

  // Get all appointments
  Future<List<AppointmentModel>> getAllAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final appointmentsJson = prefs.getStringList(_appointmentsKey) ?? [];

    return appointmentsJson
        .map((appointmentStr) => AppointmentModel.fromJson(appointmentStr))
        .toList();
  }

  // Get appointments by patient ID
  Future<List<AppointmentModel>> getAppointmentsByPatientId(
    String patientId,
  ) async {
    final appointments = await getAllAppointments();
    return appointments
        .where((appointment) => appointment.patientId == patientId)
        .toList();
  }

  // Get appointments by doctor type (specialization)
  Future<List<AppointmentModel>> getAppointmentsByDoctorType(
    String doctorType,
  ) async {
    final appointments = await getAllAppointments();
    return appointments
        .where((appointment) => appointment.doctorType == doctorType)
        .toList();
  }

  // Save new appointment
  Future<AppointmentModel> saveAppointment(AppointmentModel appointment) async {
    final prefs = await SharedPreferences.getInstance();
    final appointmentsJson = prefs.getStringList(_appointmentsKey) ?? [];

    // Generate ID if new appointment
    final newAppointment =
        appointment.id.isEmpty
            ? appointment.copyWith(id: const Uuid().v4())
            : appointment;

    // Check if appointment exists and update, or add new
    final updatedAppointments = <String>[];
    bool found = false;

    for (final appointmentStr in appointmentsJson) {
      final existingAppointment = AppointmentModel.fromJson(appointmentStr);

      if (existingAppointment.id == newAppointment.id) {
        updatedAppointments.add(newAppointment.toJson());
        found = true;
      } else {
        updatedAppointments.add(appointmentStr);
      }
    }

    if (!found) {
      updatedAppointments.add(newAppointment.toJson());
    }

    await prefs.setStringList(_appointmentsKey, updatedAppointments);
    return newAppointment;
  }

  // Update appointment status
  Future<AppointmentModel> updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    final appointments = await getAllAppointments();
    final appointmentToUpdate = appointments.firstWhere(
      (appointment) => appointment.id == appointmentId,
      orElse: () => throw Exception('Appointment not found'),
    );

    final updatedAppointment = appointmentToUpdate.copyWith(status: status);
    await saveAppointment(updatedAppointment);

    return updatedAppointment;
  }

  // Delete appointment
  Future<void> deleteAppointment(String appointmentId) async {
    final prefs = await SharedPreferences.getInstance();
    final appointmentsJson = prefs.getStringList(_appointmentsKey) ?? [];

    final updatedAppointments =
        appointmentsJson.where((appointmentStr) {
          final appointment = AppointmentModel.fromJson(appointmentStr);
          return appointment.id != appointmentId;
        }).toList();

    await prefs.setStringList(_appointmentsKey, updatedAppointments);
  }

  // Check if a time slot is available on a specific date
  Future<bool> isTimeSlotAvailable(
    String doctorType,
    DateTime date,
    String timeSlot,
  ) async {
    final appointments = await getAllAppointments();

    return !appointments.any(
      (appointment) =>
          appointment.doctorType == doctorType &&
          appointment.date.year == date.year &&
          appointment.date.month == date.month &&
          appointment.date.day == date.day &&
          appointment.timeSlot == timeSlot &&
          appointment.status != 'cancelled',
    );
  }

  // Get available time slots
  List<String> getAvailableTimeSlots() {
    // Standard time slots from 9 AM to 5 PM
    return [
      '09:00 AM - 09:30 AM',
      '09:30 AM - 10:00 AM',
      '10:00 AM - 10:30 AM',
      '10:30 AM - 11:00 AM',
      '11:00 AM - 11:30 AM',
      '11:30 AM - 12:00 PM',
      '12:00 PM - 12:30 PM',
      '12:30 PM - 01:00 PM',
      '02:00 PM - 02:30 PM',
      '02:30 PM - 03:00 PM',
      '03:00 PM - 03:30 PM',
      '03:30 PM - 04:00 PM',
      '04:00 PM - 04:30 PM',
      '04:30 PM - 05:00 PM',
    ];
  }

  // Get available specializations from existing doctors
  // Future<List<String>> getAvailableSpecializations() async {
  //   final doctors = await getUsersByRole('doctor');
  //   final specializations =
  //       doctors
  //           .map((doctor) => doctor.specialization)
  //           .where((spec) => spec.isNotEmpty)
  //           .toSet()
  //           .toList();

  //   return specializations.isEmpty
  //       ? [
  //         'General Medicine',
  //         'Pediatrics',
  //         'Cardiology',
  //         'Orthopedics',
  //         'Dermatology',
  //       ] // Default if no doctors
  //       : specializations;
  // }
}
