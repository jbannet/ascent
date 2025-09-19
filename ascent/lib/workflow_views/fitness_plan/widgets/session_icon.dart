import 'package:flutter/material.dart';
import '../../../constants_and_enums/session_type.dart';
import '../../../constants_and_enums/workout_style_enum.dart';

class SessionIcon extends StatelessWidget {
  final SessionType type;
  final WorkoutStyle style;
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
    final iconSize = isMicro ? size * 0.65 : size; // Micro is 65% size, Full is 100% = better visibility
    final borderRadius = isMicro ? iconSize / 2 : iconSize * 0.2; // Micro is circular, full is rounded square

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
              : null, // Full is filled
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
                color: style.color,
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
      case SessionType.full:
        return Colors.purple.shade100;
    }
  }

}
