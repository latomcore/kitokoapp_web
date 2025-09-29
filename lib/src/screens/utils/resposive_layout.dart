
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget tiny;
  final Widget tablet;
  // final Widget largeTablet;
  final Widget computer;
  const ResponsiveLayout(
      {super.key,
      required this.tiny,
      required this.tablet,
      // required this.largeTablet,
      required this.computer});

  static const int phoneLimit = 550;
  static const int tabletLimit = 800;

  @override
  Widget build(BuildContext context) {
    
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < phoneLimit) {
        return tiny;
      }
      if (constraints.maxWidth < tabletLimit) {
        return tablet;
      }
       else {
        return computer;
      }
    });
  }
}