import 'dart:async';
import 'package:rolodoct/models/user_model.dart';
import 'package:rolodoct/services/storage_service.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  final StorageService _storageService = StorageService();
  final _authStateController = StreamController<UserModel?>.broadcast();

  // Get authentication state changes stream
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  // Initialize auth service and check current user
  Future<void> initialize() async {
    // Seed sample data for demo purposes
    await _storageService.seedInitialData();

    // Check if user is logged in
    final currentUser = await _storageService.getCurrentUser();
    _authStateController.add(currentUser);
  }

  // Get current logged-in user
  Future<UserModel?> getCurrentUser() async {
    return await _storageService.getCurrentUser();
  }

  // Patient quick login flow
  Future<UserModel> patientLogin({required String name, String? phone}) async {
    // Search for existing patient with this name and phone
    final patients = await _storageService.getUsersByRole('patient');
    final existingPatient =
        patients
            .where(
              (p) =>
                  p.name.toLowerCase() == name.toLowerCase() &&
                  (phone == null || p.phone == phone),
            )
            .toList();

    // Return existing patient or create new one
    UserModel patient;
    if (existingPatient.isNotEmpty) {
      patient = existingPatient.first;
    } else {
      // Create new patient
      patient = UserModel(
        id: const Uuid().v4(),
        name: name,
        phone: phone,
        role: 'patient',
        createdAt: DateTime.now(),
      );

      // Save new patient to storage
      await _storageService.saveUser(patient);
    }

    // Set as current user and notify listeners
    await _storageService.saveCurrentUser(patient);
    _authStateController.add(patient);

    return patient;
  }

  // Validate doctor registration code
  Future<bool> validateAdminCode(String code) async {
    return await _storageService.validateAdminCode(code);
  }

  // Doctor registration flow
  Future<UserModel> doctorRegister({
    required String name,
    required String email,
    required String phone,
    required String specialization,
    required String adminCode,
  }) async {
    // Validate admin code
    final isCodeValid = await _storageService.validateAdminCode(adminCode);
    if (!isCodeValid) {
      throw Exception('Invalid doctor verification code');
    }

    // Create new doctor
    final doctor = UserModel(
      id: const Uuid().v4(),
      name: name,
      email: email,
      phone: phone,
      role: 'doctor',
      specialization: specialization,
      createdAt: DateTime.now(),
    );

    // Save to storage
    final savedDoctor = await _storageService.saveUser(doctor);

    // Set as current user and notify
    await _storageService.saveCurrentUser(savedDoctor);
    _authStateController.add(savedDoctor);

    return savedDoctor;
  }

  // Logout current user
  Future<void> signOut() async {
    await _storageService.clearCurrentUser();
    _authStateController.add(null);
  }

  // Get all doctors
  Future<List<UserModel>> getAllDoctors() async {
    return await _storageService.getUsersByRole('doctor');
  }

  // Get all patients
  Future<List<UserModel>> getAllPatients() async {
    return await _storageService.getUsersByRole('patient');
  }

  // Dispose resources
  void dispose() {
    _authStateController.close();
  }
}
