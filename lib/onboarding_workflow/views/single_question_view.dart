import 'package:flutter/material.dart';

class SingleQuestionView extends StatelessWidget {
  final String reason;
  final String? questionNumber;
  final String? questionText;
  final Widget answerWidget;
  final Color? accentColor;

  const SingleQuestionView({
    super.key,
    required this.reason,
    this.questionNumber,
    this.questionText,
    required this.answerWidget,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = accentColor ?? const Color(0xFF8B5FBF); // Purple default
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reason Section with Purple Swoosh
        Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 24),
            child: ClipPath(
              clipper: _SwooshClipper(),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor,
                      primaryColor.withValues(alpha: 0.8),
                      primaryColor.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 40, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Purple circle emoji indicator
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(right: 12, top: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          '🟣',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    
                    // Reason content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // "REASON:" label
                          Text(
                            'REASON:',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          
                          const SizedBox(height: 6),
                          
                          // Explanation text
                          Text(
                            reason,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        
        // Question Number Section
        if (questionNumber != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              questionNumber!,
              style: theme.textTheme.labelMedium?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Additional Question Text
        if (questionText != null) ...[
          Text(
            questionText!,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Answer Widget Section
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: answerWidget,
        ),
      ],
    );
  }
}

// Custom clipper for the swoosh effect
class _SwooshClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Start from top left
    path.moveTo(0, 0);
    
    // Top edge with slight curve
    path.quadraticBezierTo(size.width * 0.1, 0, size.width * 0.9, 0);
    
    // Right edge with swoosh
    path.quadraticBezierTo(
      size.width * 0.95, 
      size.height * 0.3, 
      size.width * 0.85, 
      size.height * 0.7
    );
    path.quadraticBezierTo(
      size.width * 0.8, 
      size.height * 0.9, 
      size.width * 0.75, 
      size.height
    );
    
    // Bottom edge
    path.lineTo(0, size.height);
    
    // Close the path
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}