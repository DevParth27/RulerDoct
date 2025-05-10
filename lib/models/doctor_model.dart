// import 'package:cloud_firestore/cloud_firestore.dart';

// class Doctor1 {
//   final String id;
//   final String name;
//   final String email;
//   final String phone;
//   final String specialization;
//   final DateTime registrationDate;
//   final bool isActive;
//   final String adminCode;

//   Doctor1({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.phone,
//     required this.specialization,
//     required this.registrationDate,
//     required this.isActive,
//     required this.adminCode,
//   });

//   // Convert Doctor object to a map for Firestore
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'email': email,
//       'phone': phone,
//       'specialization': specialization,
//       'registrationDate': registrationDate,
//       'isActive': isActive,
//       'adminCode': adminCode,
//     };
//   }

//   // Create a Doctor object from a Firestore document
//   factory Doctor1.fromMap(Map<String, dynamic> map) {
//     return Doctor1(
//       id: map['id'] ?? '',
//       name: map['name'] ?? '',
//       email: map['email'] ?? '',
//       phone: map['phone'] ?? '',
//       specialization: map['specialization'] ?? '',
//       registrationDate:
//           map['registrationDate'] is Timestamp
//               ? (map['registrationDate'] as Timestamp).toDate()
//               : DateTime.parse(map['registrationDate'].toString()),
//       isActive: map['isActive'] ?? false,
//       adminCode: map['adminCode'] ?? '',
//     );
//   }
// }
