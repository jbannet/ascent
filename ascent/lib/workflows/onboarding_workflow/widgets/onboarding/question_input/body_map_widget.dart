import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget that displays an interactive body map for selecting pain areas and injuries.
/// 
/// Features:
/// - Visual body outline with tappable regions
/// - Single tap: Mark as pain (will strengthen the area)
/// - Double tap: Mark as injury (will avoid the area)
/// - Clear visual feedback with colors and labels
class BodyMapWidget extends StatefulWidget {
  final String questionId;
  final String title;
  final String? subtitle;
  final Function(String questionId, List<String> values) onAnswerChanged;
  final List<String>? selectedValues;

  const BodyMapWidget({
    super.key,
    required this.questionId,
    required this.title,
    this.subtitle,
    required this.onAnswerChanged,
    this.selectedValues,
  });

  /// Creates BodyMapWidget from configuration map with validation
  BodyMapWidget.fromConfig(Map<String, dynamic> config, {super.key})
      : questionId = config['questionId'] ??
            (throw ArgumentError('BodyMapWidget: questionId is required')),
        title = config['title'] ??
            (throw ArgumentError('BodyMapWidget: title is required')),
        subtitle = config['subtitle'] as String?,
        onAnswerChanged = config['onAnswerChanged'] ??
            (throw ArgumentError('BodyMapWidget: onAnswerChanged is required')),
        selectedValues = config['selectedValues'] as List<String>?;

  @override
  State<BodyMapWidget> createState() => _BodyMapWidgetState();
}

class _BodyMapWidgetState extends State<BodyMapWidget> {
  final Map<String, BodyPartState> _bodyPartStates = {};
  
  @override
  void initState() {
    super.initState();
    _initializeFromSelectedValues();
  }

  void _initializeFromSelectedValues() {
    if (widget.selectedValues == null) return;
    
    for (final value in widget.selectedValues!) {
      if (value.startsWith('pain_')) {
        final part = value.replaceFirst('pain_', '');
        _bodyPartStates[part] = BodyPartState.pain;
      } else if (value.startsWith('injury_')) {
        final part = value.replaceFirst('injury_', '');
        _bodyPartStates[part] = BodyPartState.injury;
      }
    }
  }

  List<String> _getSelectedValues() {
    final values = <String>[];
    _bodyPartStates.forEach((part, state) {
      if (state == BodyPartState.pain) {
        values.add('pain_$part');
      } else if (state == BodyPartState.injury) {
        values.add('injury_$part');
      }
    });
    return values;
  }

  void _handleSingleTap(String bodyPart) {
    setState(() {
      if (_bodyPartStates[bodyPart] == BodyPartState.pain) {
        _bodyPartStates.remove(bodyPart);
      } else {
        _bodyPartStates[bodyPart] = BodyPartState.pain;
      }
    });
    widget.onAnswerChanged(widget.questionId, _getSelectedValues());
  }

  void _handleDoubleTap(String bodyPart) {
    setState(() {
      if (_bodyPartStates[bodyPart] == BodyPartState.injury) {
        _bodyPartStates.remove(bodyPart);
      } else {
        _bodyPartStates[bodyPart] = BodyPartState.injury;
      }
    });
    widget.onAnswerChanged(widget.questionId, _getSelectedValues());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instructions
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.touch_app, 
                       size: 20, 
                       color: Colors.amber.shade700),
                  const SizedBox(width: 8),
                  Text('Single tap: Pain (Strengthen)',
                       style: TextStyle(
                         fontWeight: FontWeight.w500,
                         color: Colors.amber.shade700,
                       )),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.touch_app, 
                       size: 20, 
                       color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Text('Double tap: Injury (Avoid)',
                       style: TextStyle(
                         fontWeight: FontWeight.w500,
                         color: Colors.red.shade700,
                       )),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Body Map
        Center(
          child: SizedBox(
            width: 300,
            height: 500,
            child: CustomPaint(
              painter: BodyMapPainter(
                bodyPartStates: _bodyPartStates,
                theme: theme,
              ),
              child: Stack(
                children: _buildInteractiveRegions(theme),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Selected Items Summary
        if (_bodyPartStates.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_bodyPartStates.values.contains(BodyPartState.pain)) ...[
                  Row(
                    children: [
                      Icon(Icons.fitness_center, 
                           size: 16, 
                           color: Colors.amber.shade700),
                      const SizedBox(width: 8),
                      Text('Pain to strengthen: ',
                           style: TextStyle(
                             fontWeight: FontWeight.w600,
                             color: Colors.amber.shade700,
                           )),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _bodyPartStates.entries
                        .where((e) => e.value == BodyPartState.pain)
                        .map((e) => _formatBodyPartName(e.key))
                        .join(', '),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                if (_bodyPartStates.values.contains(BodyPartState.injury)) ...[
                  if (_bodyPartStates.values.contains(BodyPartState.pain))
                    const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.warning, 
                           size: 16, 
                           color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Text('Injuries to avoid: ',
                           style: TextStyle(
                             fontWeight: FontWeight.w600,
                             color: Colors.red.shade700,
                           )),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _bodyPartStates.entries
                        .where((e) => e.value == BodyPartState.injury)
                        .map((e) => _formatBodyPartName(e.key))
                        .join(', '),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _formatBodyPartName(String part) {
    return part.replaceAll('_', ' ').split(' ').map((word) {
      return word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '';
    }).join(' ');
  }

  List<Widget> _buildInteractiveRegions(ThemeData theme) {
    return [
      // Head/Neck
      _buildBodyPartRegion('neck', theme,
          left: 130, top: 50, width: 40, height: 30),
      
      // Shoulders
      _buildBodyPartRegion('shoulder_left', theme,
          left: 80, top: 80, width: 50, height: 40),
      _buildBodyPartRegion('shoulder_right', theme,
          left: 170, top: 80, width: 50, height: 40),
      
      // Upper Back
      _buildBodyPartRegion('upper_back', theme,
          left: 120, top: 100, width: 60, height: 50),
      
      // Chest
      _buildBodyPartRegion('chest', theme,
          left: 120, top: 120, width: 60, height: 50),
      
      // Lower Back
      _buildBodyPartRegion('lower_back', theme,
          left: 120, top: 170, width: 60, height: 50),
      
      // Core/Abs
      _buildBodyPartRegion('core', theme,
          left: 120, top: 190, width: 60, height: 50),
      
      // Hips
      _buildBodyPartRegion('hip_left', theme,
          left: 100, top: 240, width: 40, height: 40),
      _buildBodyPartRegion('hip_right', theme,
          left: 160, top: 240, width: 40, height: 40),
      
      // Knees
      _buildBodyPartRegion('knee_left', theme,
          left: 100, top: 320, width: 40, height: 40),
      _buildBodyPartRegion('knee_right', theme,
          left: 160, top: 320, width: 40, height: 40),
      
      // Ankles
      _buildBodyPartRegion('ankle_left', theme,
          left: 100, top: 420, width: 40, height: 30),
      _buildBodyPartRegion('ankle_right', theme,
          left: 160, top: 420, width: 40, height: 30),
      
      // Wrists (on arms)
      _buildBodyPartRegion('wrist_left', theme,
          left: 50, top: 180, width: 30, height: 30),
      _buildBodyPartRegion('wrist_right', theme,
          left: 220, top: 180, width: 30, height: 30),
      
      // Elbows
      _buildBodyPartRegion('elbow_left', theme,
          left: 60, top: 140, width: 30, height: 30),
      _buildBodyPartRegion('elbow_right', theme,
          left: 210, top: 140, width: 30, height: 30),
    ];
  }

  Widget _buildBodyPartRegion(String bodyPart, ThemeData theme,
      {required double left, 
       required double top, 
       required double width, 
       required double height}) {
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: () => _handleSingleTap(bodyPart),
        onDoubleTap: () => _handleDoubleTap(bodyPart),
        behavior: HitTestBehavior.translucent,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            painter: DottedBorderPainter(
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
              strokeWidth: 1.5,
              dashLength: 4,
              gapLength: 3,
            ),
          ),
        ),
      ),
    );
  }
}

enum BodyPartState {
  none,
  pain,
  injury,
}

/// Custom painter for drawing the body outline and highlighting selected parts
class BodyMapPainter extends CustomPainter {
  final Map<String, BodyPartState> bodyPartStates;
  final ThemeData theme;

  BodyMapPainter({
    required this.bodyPartStates,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = theme.colorScheme.outline.withOpacity(0.5);

    final fillPaint = Paint()
      ..style = PaintingStyle.fill;

    // Draw body outline
    _drawBodyOutline(canvas, size, paint);
    
    // Draw dotted outlines for clickable areas
    _drawClickableAreaOutlines(canvas, size);
    
    // Draw highlighted regions
    _drawHighlightedRegions(canvas, size, fillPaint);
  }

  void _drawBodyOutline(Canvas canvas, Size size, Paint paint) {
    // Head
    canvas.drawCircle(Offset(150, 40), 25, paint);
    
    // Neck
    canvas.drawLine(Offset(150, 65), Offset(150, 80), paint);
    
    // Shoulders
    canvas.drawLine(Offset(100, 90), Offset(200, 90), paint);
    
    // Arms
    canvas.drawLine(Offset(100, 90), Offset(70, 140), paint);
    canvas.drawLine(Offset(70, 140), Offset(60, 200), paint);
    canvas.drawLine(Offset(200, 90), Offset(230, 140), paint);
    canvas.drawLine(Offset(230, 140), Offset(240, 200), paint);
    
    // Torso
    canvas.drawRect(Rect.fromLTWH(120, 90, 60, 150), paint);
    
    // Hips
    canvas.drawLine(Offset(120, 240), Offset(110, 280), paint);
    canvas.drawLine(Offset(180, 240), Offset(190, 280), paint);
    
    // Legs
    canvas.drawLine(Offset(110, 280), Offset(110, 360), paint);
    canvas.drawLine(Offset(110, 360), Offset(110, 450), paint);
    canvas.drawLine(Offset(190, 280), Offset(190, 360), paint);
    canvas.drawLine(Offset(190, 360), Offset(190, 450), paint);
    
    // Feet
    canvas.drawRect(Rect.fromLTWH(95, 450, 30, 10), paint);
    canvas.drawRect(Rect.fromLTWH(175, 450, 30, 10), paint);
  }

  void _drawClickableAreaOutlines(Canvas canvas, Size size) {
    final dottedPaint = Paint()
      ..color = theme.colorScheme.primary.withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw dotted outlines for all clickable regions using the same coordinates
    // as in _buildInteractiveRegions
    
    // Head/Neck
    _drawDottedRect(canvas, Rect.fromLTWH(130, 50, 40, 30), dottedPaint);
    
    // Shoulders
    _drawDottedRect(canvas, Rect.fromLTWH(80, 80, 50, 40), dottedPaint);
    _drawDottedRect(canvas, Rect.fromLTWH(170, 80, 50, 40), dottedPaint);
    
    // Upper Back
    _drawDottedRect(canvas, Rect.fromLTWH(120, 100, 60, 50), dottedPaint);
    
    // Chest  
    _drawDottedRect(canvas, Rect.fromLTWH(120, 120, 60, 50), dottedPaint);
    
    // Lower Back
    _drawDottedRect(canvas, Rect.fromLTWH(120, 170, 60, 50), dottedPaint);
    
    // Core/Abs
    _drawDottedRect(canvas, Rect.fromLTWH(120, 190, 60, 50), dottedPaint);
    
    // Hips
    _drawDottedRect(canvas, Rect.fromLTWH(100, 240, 40, 40), dottedPaint);
    _drawDottedRect(canvas, Rect.fromLTWH(160, 240, 40, 40), dottedPaint);
    
    // Knees
    _drawDottedCircle(canvas, Offset(120, 340), 20, dottedPaint);
    _drawDottedCircle(canvas, Offset(180, 340), 20, dottedPaint);
    
    // Ankles
    _drawDottedRect(canvas, Rect.fromLTWH(100, 420, 40, 30), dottedPaint);
    _drawDottedRect(canvas, Rect.fromLTWH(160, 420, 40, 30), dottedPaint);
    
    // Wrists
    _drawDottedRect(canvas, Rect.fromLTWH(50, 180, 30, 30), dottedPaint);
    _drawDottedRect(canvas, Rect.fromLTWH(220, 180, 30, 30), dottedPaint);
    
    // Elbows
    _drawDottedRect(canvas, Rect.fromLTWH(60, 140, 30, 30), dottedPaint);
    _drawDottedRect(canvas, Rect.fromLTWH(210, 140, 30, 30), dottedPaint);
  }

  void _drawDottedRect(Canvas canvas, Rect rect, Paint paint) {
    const dashLength = 3.0;
    const gapLength = 2.0;
    
    // Top border
    _drawDottedLine(canvas, Offset(rect.left, rect.top), Offset(rect.right, rect.top), paint, dashLength, gapLength);
    // Right border
    _drawDottedLine(canvas, Offset(rect.right, rect.top), Offset(rect.right, rect.bottom), paint, dashLength, gapLength);
    // Bottom border
    _drawDottedLine(canvas, Offset(rect.right, rect.bottom), Offset(rect.left, rect.bottom), paint, dashLength, gapLength);
    // Left border  
    _drawDottedLine(canvas, Offset(rect.left, rect.bottom), Offset(rect.left, rect.top), paint, dashLength, gapLength);
  }

  void _drawDottedCircle(Canvas canvas, Offset center, double radius, Paint paint) {
    const dashLength = 3.0;
    const gapLength = 2.0;
    final circumference = 2 * 3.14159 * radius;
    final dashCount = (circumference / (dashLength + gapLength)).floor();
    final anglePerDash = (2 * 3.14159) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * anglePerDash;
      final endAngle = startAngle + (anglePerDash * dashLength / (dashLength + gapLength));
      
      final startX = center.dx + radius * math.cos(startAngle);
      final startY = center.dy + radius * math.sin(startAngle);
      final endX = center.dx + radius * math.cos(endAngle);
      final endY = center.dy + radius * math.sin(endAngle);
      
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  void _drawDottedLine(Canvas canvas, Offset start, Offset end, Paint paint, double dashLength, double gapLength) {
    final distance = (end - start).distance;
    final dashCount = (distance / (dashLength + gapLength)).floor();
    final direction = (end - start) / distance;

    for (int i = 0; i < dashCount; i++) {
      final dashStart = start + direction * (i * (dashLength + gapLength));
      final dashEnd = dashStart + direction * dashLength;
      canvas.drawLine(dashStart, dashEnd, paint);
    }
  }

  void _drawHighlightedRegions(Canvas canvas, Size size, Paint fillPaint) {
    bodyPartStates.forEach((part, state) {
      if (state == BodyPartState.none) return;
      
      fillPaint.color = state == BodyPartState.pain 
          ? Colors.amber.withOpacity(0.3)
          : Colors.red.withOpacity(0.3);
      
      // Draw highlights for each body part
      switch (part) {
        case 'neck':
          canvas.drawRect(Rect.fromLTWH(130, 50, 40, 30), fillPaint);
          break;
        case 'shoulder_left':
          canvas.drawRect(Rect.fromLTWH(80, 80, 50, 40), fillPaint);
          break;
        case 'shoulder_right':
          canvas.drawRect(Rect.fromLTWH(170, 80, 50, 40), fillPaint);
          break;
        case 'upper_back':
          canvas.drawRect(Rect.fromLTWH(120, 100, 60, 50), fillPaint);
          break;
        case 'chest':
          canvas.drawRect(Rect.fromLTWH(120, 120, 60, 50), fillPaint);
          break;
        case 'lower_back':
          canvas.drawRect(Rect.fromLTWH(120, 170, 60, 50), fillPaint);
          break;
        case 'core':
          canvas.drawRect(Rect.fromLTWH(120, 190, 60, 50), fillPaint);
          break;
        case 'hip_left':
          canvas.drawRect(Rect.fromLTWH(100, 240, 40, 40), fillPaint);
          break;
        case 'hip_right':
          canvas.drawRect(Rect.fromLTWH(160, 240, 40, 40), fillPaint);
          break;
        case 'knee_left':
          canvas.drawCircle(Offset(120, 340), 20, fillPaint);
          break;
        case 'knee_right':
          canvas.drawCircle(Offset(180, 340), 20, fillPaint);
          break;
        case 'ankle_left':
          canvas.drawCircle(Offset(120, 435), 15, fillPaint);
          break;
        case 'ankle_right':
          canvas.drawCircle(Offset(180, 435), 15, fillPaint);
          break;
        case 'wrist_left':
          canvas.drawCircle(Offset(65, 195), 12, fillPaint);
          break;
        case 'wrist_right':
          canvas.drawCircle(Offset(235, 195), 12, fillPaint);
          break;
        case 'elbow_left':
          canvas.drawCircle(Offset(75, 155), 12, fillPaint);
          break;
        case 'elbow_right':
          canvas.drawCircle(Offset(225, 155), 12, fillPaint);
          break;
      }
    });
  }

  @override
  bool shouldRepaint(covariant BodyMapPainter oldDelegate) {
    return oldDelegate.bodyPartStates != bodyPartStates;
  }
}

/// Custom painter for drawing dotted borders around clickable regions
class DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  const DottedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Draw dotted rectangle border
    _drawDottedRect(canvas, Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _drawDottedRect(Canvas canvas, Rect rect, Paint paint) {
    // Top border
    _drawDottedLine(
      canvas,
      Offset(rect.left, rect.top),
      Offset(rect.right, rect.top),
      paint,
    );
    
    // Right border
    _drawDottedLine(
      canvas,
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.bottom),
      paint,
    );
    
    // Bottom border
    _drawDottedLine(
      canvas,
      Offset(rect.right, rect.bottom),
      Offset(rect.left, rect.bottom),
      paint,
    );
    
    // Left border
    _drawDottedLine(
      canvas,
      Offset(rect.left, rect.bottom),
      Offset(rect.left, rect.top),
      paint,
    );
  }

  void _drawDottedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final distance = (end - start).distance;
    final dashCount = (distance / (dashLength + gapLength)).floor();
    final direction = (end - start) / distance;

    for (int i = 0; i < dashCount; i++) {
      final dashStart = start + direction * (i * (dashLength + gapLength));
      final dashEnd = dashStart + direction * dashLength;
      canvas.drawLine(dashStart, dashEnd, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DottedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth ||
           oldDelegate.dashLength != dashLength ||
           oldDelegate.gapLength != gapLength;
  }
}