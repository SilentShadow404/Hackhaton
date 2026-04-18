import 'package:flutter/material.dart';

class BrandShell extends StatelessWidget {
  final Widget child;

  const BrandShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F6EE), Color(0xFFE8F2ED)],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}
