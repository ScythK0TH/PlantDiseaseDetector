import 'package:flutter/material.dart';

/*
  Refference
  https://www.youtube.com/watch?v=V0_baZFor8U
*/

class Responsive extends StatelessWidget {
  final Widget smallMobile;
  final Widget mobile;
  final Widget tablet;
  final Widget? desktop;

  const Responsive({
    super.key,
    required this.smallMobile,
    required this.mobile,
    required this.tablet,
    this.desktop,
  });

  static const int smallMobileMax = 419;
  static const int mobileMax = 767;
  static const int tabletMax = 1999;

  static bool isSmallMobile(BuildContext context) =>
      MediaQuery.of(context).size.width <= smallMobileMax;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width > smallMobileMax &&
      MediaQuery.of(context).size.width <= mobileMax;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width > mobileMax &&
      MediaQuery.of(context).size.width <= tabletMax;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > tabletMax;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    if (width > tabletMax) {
      return desktop ?? tablet;
    } else if (width > mobileMax) {
      return tablet;
    } else if (width > smallMobileMax) {
      return mobile;
    } else {
      return smallMobile;
    }
  }
}
