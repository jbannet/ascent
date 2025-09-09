import 'package:flutter/material.dart';
import '../../../../../models/body_map_coordinates.dart';
import '../../../../../workflows/question_bank/questions/demographics/gender_question.dart';

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
  final Map<String, dynamic>? currentAnswers;

  const BodyMapWidget({
    super.key,
    required this.questionId,
    required this.title,
    this.subtitle,
    required this.onAnswerChanged,
    this.selectedValues,
    this.currentAnswers,
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
        selectedValues = config['selectedValues'] as List<String>?,
        currentAnswers = config['currentAnswers'] as Map<String, dynamic>?;

  @override
  State<BodyMapWidget> createState() => _BodyMapWidgetState();
}

class _BodyMapWidgetState extends State<BodyMapWidget> {
  final Map<String, BodyPartState> _bodyPartStates = {};
  String? _userGender;
  final GlobalKey _imageKey = GlobalKey();
  double _imageWidth = 300.0;
  double _imageHeight = 500.0;
  double _actualImageWidth = 300.0;
  double _actualImageHeight = 500.0;
  double _imageOffsetX = 0.0;
  double _imageOffsetY = 0.0;
  
  @override
  void initState() {
    super.initState();
    _initializeFromSelectedValues();
    _determineGender();
  }
  
  void _determineGender() {
    if (widget.currentAnswers != null) {
      _userGender = GenderQuestion.instance.getGender(widget.currentAnswers!);
    }
    _userGender ??= 'male'; // Default to male if gender not specified
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

  void _handleTap(String bodyPart) {
    print('*** TAP HANDLER CALLED FOR $bodyPart ***'); // Debug logging
    setState(() {
      final currentState = _bodyPartStates[bodyPart];
      print('DEBUG: Current state for $bodyPart: $currentState');
      print('DEBUG: All states: $_bodyPartStates');
      
      if (currentState == null) {
        _bodyPartStates[bodyPart] = BodyPartState.pain;
        print('DEBUG: Set $bodyPart to pain');
      } else if (currentState == BodyPartState.pain) {
        _bodyPartStates[bodyPart] = BodyPartState.injury;
        print('DEBUG: Set $bodyPart to injury');
      } else if (currentState == BodyPartState.injury) {
        _bodyPartStates.remove(bodyPart);
        print('DEBUG: Removed $bodyPart from selection');
      }
      
      print('DEBUG: New state for $bodyPart: ${_bodyPartStates[bodyPart]}');
      print('DEBUG: All states after change: $_bodyPartStates');
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
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
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
        
        // Body Map with Gender-Specific Image
        Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Use the same approach as the mapping tool - let the image size itself with BoxFit.contain
              // and use the available space
              final availableWidth = constraints.maxWidth - 40;
              final availableHeight = 500.0;
              
              // Store the container dimensions
              _imageWidth = availableWidth;
              _imageHeight = availableHeight;
              
              // Calculate actual rendered image dimensions with BoxFit.contain
              // Use actual image dimensions: man.png=1024x1024 (1.0), woman.png=1024x1536 (0.667)
              final imageAspectRatio = _userGender?.toLowerCase() == 'female' ? (1024.0 / 1536.0) : (1024.0 / 1024.0);
              final containerAspectRatio = availableWidth / availableHeight;
              
              if (containerAspectRatio > imageAspectRatio) {
                // Container is wider, image is constrained by height
                _actualImageHeight = availableHeight;
                _actualImageWidth = availableHeight * imageAspectRatio;
                _imageOffsetX = (availableWidth - _actualImageWidth) / 2;
                _imageOffsetY = 0.0;
              } else {
                // Container is taller, image is constrained by width
                _actualImageWidth = availableWidth;
                _actualImageHeight = availableWidth / imageAspectRatio;
                _imageOffsetX = 0.0;
                _imageOffsetY = (availableHeight - _actualImageHeight) / 2;
              }
              
              return SizedBox(
                width: availableWidth,
                height: availableHeight,
                child: Stack(
                  children: [
                    // Gender-specific body image
                    Image.asset(
                      _getBodyImagePath(),
                      key: _imageKey,
                      fit: BoxFit.contain,
                      width: availableWidth,
                      height: availableHeight,
                    ),
                    // Interactive regions overlay
                    ..._buildClickableRegions(),
                    // Visual feedback overlay for selected regions
                    ..._buildSelectedRegionOverlays(),
                  ],
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Selected Items Summary
        if (_bodyPartStates.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
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

  /// Get the appropriate body image path based on user gender
  String _getBodyImagePath() {
    switch (_userGender?.toLowerCase()) {
      case 'female':
        return 'assets/images/woman.png';
      case 'male':
      default:
        return 'assets/images/man.png';
    }
  }

  /// Build clickable regions based on coordinate data
  List<Widget> _buildClickableRegions() {
    final regions = BodyMapCoordinates.getRegionsForGender(_userGender);
    final clickableWidgets = <Widget>[];
    
    for (final entry in regions.entries) {
      final bodyPart = entry.key;
      final bodyRegions = entry.value;
      
      for (final region in bodyRegions) {
        clickableWidgets.add(
          _buildClickableRegion(bodyPart, region),
        );
      }
    }
    
    return clickableWidgets;
  }

  /// Build a single clickable region
  Widget _buildClickableRegion(String bodyPart, BodyRegion region) {
    final left = _imageOffsetX + (region.xPercent / 100.0) * _actualImageWidth;
    final top = _imageOffsetY + (region.yPercent / 100.0) * _actualImageHeight;
    final width = (region.widthPercent / 100.0) * _actualImageWidth;
    final height = (region.heightPercent / 100.0) * _actualImageHeight;
    
    // Removed excessive build logging
    
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        onTapUp: (details) {
          print('DEBUG: GestureDetector onTapUp fired for $bodyPart');
          _handleTap(bodyPart);
        },
        onTapDown: (details) {
          print('DEBUG: onTapDown detected for $bodyPart at ${details.localPosition}');
        },
        behavior: HitTestBehavior.translucent,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.3), // More visible for debugging
            border: Border.all(
              color: Colors.red,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              bodyPart.substring(0, 2).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build visual overlays for selected regions
  List<Widget> _buildSelectedRegionOverlays() {
    if (_bodyPartStates.isEmpty) return [];
    
    final regions = BodyMapCoordinates.getRegionsForGender(_userGender);
    final overlays = <Widget>[];
    
    for (final entry in _bodyPartStates.entries) {
      final bodyPart = entry.key;
      final state = entry.value;
      final bodyRegions = regions[bodyPart];
      
      if (bodyRegions != null) {
        final color = state == BodyPartState.pain 
            ? Colors.amber.withValues(alpha: 0.6)
            : Colors.red.withValues(alpha: 0.6);
        
        for (final region in bodyRegions) {
          overlays.add(
            Positioned(
              left: _imageOffsetX + (region.xPercent / 100.0) * _actualImageWidth,
              top: _imageOffsetY + (region.yPercent / 100.0) * _actualImageHeight,
              width: (region.widthPercent / 100.0) * _actualImageWidth,
              height: (region.heightPercent / 100.0) * _actualImageHeight,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                ),
              ),
            ),
          );
        }
      }
    }
    
    return overlays;
  }

}

enum BodyPartState {
  none,
  pain,
  injury,
}