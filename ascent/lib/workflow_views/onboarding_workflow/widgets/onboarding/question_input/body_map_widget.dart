import 'package:flutter/material.dart';
import '../../../../../services_and_utilities/general_utilities/body_map_coordinates.dart';
import '../../../question_bank/questions/demographics/gender_question.dart';

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
  final Widget? subtitleWidget;
  final Function(String questionId, List<String> values) onAnswerChanged;
  final List<String>? selectedValues;
  final Map<String, dynamic>? currentAnswers;

  const BodyMapWidget({
    super.key,
    required this.questionId,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
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
        subtitleWidget = config['subtitleWidget'] as Widget?,
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
  final GlobalKey _actualImageKey = GlobalKey();
  double _actualImageWidth = 300.0;
  double _actualImageHeight = 500.0;
  double _imageOffsetX = 0.0;
  double _imageOffsetY = 0.0;
  
  @override
  void initState() {
    super.initState();
    _initializeFromSelectedValues();
    _determineGender();
    
    // Check actual rendered size after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkActualImageSize();
    });
  }
  
  void _checkActualImageSize() {
    final RenderBox? renderBox = _actualImageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      // Size check for future positioning logic if needed
    }
  }
  
  void _determineGender() {
    _userGender = GenderQuestion.instance.genderAnswer;
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
    setState(() {
      final currentState = _bodyPartStates[bodyPart];
      
      if (currentState == null) {
        _bodyPartStates[bodyPart] = BodyPartState.pain;
      } else if (currentState == BodyPartState.pain) {
        _bodyPartStates[bodyPart] = BodyPartState.injury;
      } else if (currentState == BodyPartState.injury) {
        _bodyPartStates.remove(bodyPart);
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
        // Body Map with Gender-Specific Image
        Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Use width-based sizing to eliminate white space
              // Let the image aspect ratio determine the height
              final targetImageWidth = 400.0; // Target width for the body image
              
              // Calculate height based on actual image aspect ratios
              // Male: 1024x1024 (1:1 ratio), Female: 1024x1536 (~0.67:1 ratio)
              final isFemale = _userGender?.toLowerCase() == 'female';
              final imageAspectRatio = isFemale ? (1024.0 / 1536.0) : (1024.0 / 1024.0);
              final availableHeight = targetImageWidth / imageAspectRatio;
              
              // Since we're using exact sizing, actual image dimensions match container
              _actualImageWidth = targetImageWidth;
              _actualImageHeight = availableHeight;
              _imageOffsetX = 0.0;
              _imageOffsetY = 0.0;
              
              
              return SizedBox(
                width: targetImageWidth,
                height: availableHeight,
                child: Stack(
                  children: [
                    // Gender-specific body image
                    Image.asset(
                      _getBodyImagePath(),
                      key: _actualImageKey,
                      fit: BoxFit.fill,
                      width: targetImageWidth,
                      height: availableHeight,
                    ),
                    // Visual feedback overlay for selected regions (BEHIND clickable regions)
                    ..._buildSelectedRegionOverlays(),
                    // Interactive regions overlay (ON TOP so they can receive taps)
                    ..._buildClickableRegions(),
                  ],
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Body Part Pills
        _buildBodyPartPills(theme),
      ],
    );
  }

  String _formatBodyPartName(String part) {
    return part.replaceAll('_', ' ').split(' ').map((word) {
      return word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '';
    }).join(' ');
  }

  /// Build body part pills in anatomical order
  Widget _buildBodyPartPills(ThemeData theme) {
    // Define anatomical order (head to toe)
    const anatomicalOrder = [
      'neck', 'shoulders', 'chest', 'lats', 'traps',
      'biceps', 'triceps', 'elbows', 'forearms', 'wrists',
      'abdominals', 'lower_back',
      'hips', 'glutes', 'quadriceps', 'hamstrings',
      'knees', 'calves', 'shins', 'ankles', 'feet'
    ];
    
    return Wrap(
      spacing: 3,
      runSpacing: 3,
      children: anatomicalOrder.map((bodyPart) {
        final state = _bodyPartStates[bodyPart];
        final isSelected = state != null;
        final isPain = state == BodyPartState.pain;
        final isInjury = state == BodyPartState.injury;
        
        Color backgroundColor;
        Color textColor;
        Border border;
        
        if (isPain) {
          backgroundColor = Colors.amber.shade700;
          textColor = Colors.white;
          border = Border.all(color: Colors.amber.shade700);
        } else if (isInjury) {
          backgroundColor = Colors.red.shade700;
          textColor = Colors.white;
          border = Border.all(color: Colors.red.shade700);
        } else {
          backgroundColor = Colors.transparent;
          textColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
          border = Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3));
        }
        
        return GestureDetector(
          onTap: () => _handleTap(bodyPart),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: border,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _formatBodyPartName(bodyPart),
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
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
    final width = (region.widthPercent / 100.0) * _actualImageWidth;
    final height = (region.heightPercent / 100.0) * _actualImageHeight;
    
    // Stored coordinates are CENTER of cell, so subtract half width/height to get top-left corner
    final left = _imageOffsetX + (region.xPercent / 100.0) * _actualImageWidth - width / 2;
    final top = _imageOffsetY + (region.yPercent / 100.0) * _actualImageHeight - height / 2;
    
    // Log just the first region of the first body part for debugging
    if (bodyPart == 'chest' && region.xPercent < 50) {
    }
    
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        onTapUp: (details) {
          _handleTap(bodyPart);
        },
        onTapDown: (details) {
        },
        behavior: HitTestBehavior.translucent,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.transparent, // Make clickable regions invisible
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
          final width = (region.widthPercent / 100.0) * _actualImageWidth;
          final height = (region.heightPercent / 100.0) * _actualImageHeight;
          final left = _imageOffsetX + (region.xPercent / 100.0) * _actualImageWidth - width / 2;
          final top = _imageOffsetY + (region.yPercent / 100.0) * _actualImageHeight - height / 2;
          
          overlays.add(
            Positioned(
              left: left,
              top: top,
              width: width,
              height: height,
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