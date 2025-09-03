import 'package:flutter/material.dart';

/// Custom clipper for creating a swoosh effect
class SwooshClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Start from top left
    path.moveTo(0, 0);
    
    // Top edge
    path.lineTo(size.width, 0);
    
    // Right edge with swoosh curve
    path.lineTo(size.width, size.height - 20);
    
    // Create the swoosh curve at bottom right
    path.quadraticBezierTo(
      size.width - 10, size.height - 10,
      size.width - 20, size.height,
    );
    
    // Bottom edge with curve
    path.lineTo(20, size.height);
    path.quadraticBezierTo(
      10, size.height - 5,
      0, size.height - 10,
    );
    
    // Left edge back to start
    path.lineTo(0, 0);
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}