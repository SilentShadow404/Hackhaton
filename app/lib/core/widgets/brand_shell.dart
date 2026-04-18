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
          colors: [Color(0xFFF1F6F6), Color(0xFFE8F1EE)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0E4A4A).withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -110,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEF6C00).withValues(alpha: 0.08),
              ),
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}
