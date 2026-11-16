import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 650;
  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 650 && MediaQuery.of(context).size.width < 1100;
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1100) {
          return desktop;
        } else if (constraints.maxWidth >= 650) {
          return tablet ?? desktop;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Helper container untuk membatasi lebar agar UI tidak terlihat melebar 
/// saat dibuka pada Desktop / Web browser layar besar.
class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final bool wrapInCenter;

  const MaxWidthContainer({
    super.key, 
    required this.child, 
    this.maxWidth = 850,
    this.wrapInCenter = true,
  });

  @override
  Widget build(BuildContext context) {
    final constrained = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    );
    return wrapInCenter ? Center(child: constrained) : constrained;
  }
}
