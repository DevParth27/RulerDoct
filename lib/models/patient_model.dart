class Patient {
  final String name;
  final String phone;

  Patient({required this.name, required this.phone});

  factory Patient.fromMap(Map<String, dynamic> data) {
    return Patient(
      name: data['Patient Name'] ?? 'Unknown',
      phone: data['Patient Number'] ?? 'No number',
    );
  }
}
