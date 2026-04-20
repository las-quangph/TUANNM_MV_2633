import 'package:flutter/material.dart';

extension DeviceExt on BuildContext {
  bool get isPhone => MediaQuery.of(this).size.shortestSide < 600;
  bool get isTablet => MediaQuery.of(this).size.shortestSide >= 600;

  double scale({
    required double phone,
    double? tablet,
  }) {
    if (isTablet) return tablet ?? phone * 1.3;
    return phone;
  }

  EdgeInsets padding({
    required EdgeInsets phone,
    EdgeInsets? tablet,
  }) {
    if (isTablet) return tablet ?? phone;
    return phone;
  }
}
