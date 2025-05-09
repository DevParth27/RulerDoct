import 'dart:convert';
import 'package:rolodoct/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static const String _currentUserKey = 'current_user';
  static const String _usersKey = 'users';
  static const String _adminCodeKey = 'admin_code';

  // Hardcoded admin code for doctor registration validation
  static const String defaultAdminCode = 'DOCTOR123';

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
}
