class UserModel {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String role; // 'doctor' or 'patient'
  final String? specialization; // For doctors only
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.role,
    this.specialization,
    required this.createdAt,
  });

  // Convert user to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'specialization': specialization,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create user from map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      role: map['role'],
      specialization: map['specialization'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  // Create copy of user with optional new values
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? specialization,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      specialization: specialization ?? this.specialization,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
