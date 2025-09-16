import 'package:flutter/material.dart';
import '../../../enums/session_type.dart';
import '../../../enums/exercise_style.dart';

class SessionIcon extends StatelessWidget {
  final SessionType type;
  final ExerciseStyle style;
  final double size;
  final bool showBadge;

  const SessionIcon({
    super.key,
    required this.type,
    required this.style,
    this.size = 24,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMicro = type == SessionType.micro;
    final iconSize = isMicro ? size * 0.65 : size; // Micro is 65% size, Macro is 100% = better visibility
    final borderRadius = isMicro ? iconSize / 2 : iconSize * 0.2; // Micro is circular, macro is rounded square

    return Stack(
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(borderRadius),
            border: isMicro
              ? Border.all(color: Colors.grey.shade300, width: 2) // Micro has subtle outline
              : null, // Macro is filled
          ),
          child: isMicro
              ? _buildClockFaceBackground(iconSize)
              : Center(
                  child: Text(
                    style.icon,
                    style: TextStyle(
                      fontSize: iconSize * 0.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ),
        if (showBadge)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: iconSize * 0.4,
              height: iconSize * 0.4,
              decoration: BoxDecoration(
                color: _getStyleColor(),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Center(
                child: Text(
                  style.icon,
                  style: TextStyle(fontSize: iconSize * 0.2),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildClockFaceBackground(double iconSize) {
    return Stack(
      children: [
        // Clock face background
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        // Clock markings (12, 3, 6, 9 positions)
        ...List.generate(4, (index) {
          final angle = index * (3.14159 / 2); // 90 degrees apart
          final markSize = iconSize * 0.08;
          final distance = iconSize * 0.35;

          return Positioned(
            left: iconSize / 2 + distance * (index == 1 ? 1 : index == 3 ? -1 : 0) - markSize / 2,
            top: iconSize / 2 + distance * (index == 2 ? 1 : index == 0 ? -1 : 0) - markSize / 2,
            child: Container(
              width: markSize,
              height: markSize,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
        // Center style icon
        Center(
          child: Text(
            style.icon,
            style: TextStyle(
              fontSize: iconSize * 0.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case SessionType.micro:
        return Colors.white; // Clean white for clock face
      case SessionType.macro:
        return Colors.purple.shade100;
    }
  }

  Color _getTypeColor() {
    switch (type) {
      case SessionType.micro:
        return Colors.blue.shade400;
      case SessionType.macro:
        return Colors.purple.shade400;
    }
  }

  Color _getStyleColor() {
    switch (style) {
      case ExerciseStyle.cardio:
        return Colors.red.shade400;
      case ExerciseStyle.strength:
        return Colors.orange.shade400;
      case ExerciseStyle.flexibility:
        return Colors.green.shade400;
      case ExerciseStyle.balance:
        return Colors.blue.shade400;
      case ExerciseStyle.functional:
        return Colors.brown.shade400;
    }
  }
}