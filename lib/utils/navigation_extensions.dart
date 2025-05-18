import 'package:flutter/material.dart';
import 'package:rolodoct/models/user_model.dart';
import 'package:rolodoct/screens/doctor/doctor_dashboard.dart';

extension NavigationExtensions on BuildContext {
  void slideToDoctorDashboard(UserModel doctor) {
    Navigator.of(this).pushAndRemoveUntil(
      _createSlideRoute(DoctorDashboard(doctor: doctor)),
      (route) => false,
    );
  }

  PageRouteBuilder _createSlideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }
}
