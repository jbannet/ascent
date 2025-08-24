import 'package:flutter/material.dart';
import 'single_question_view.dart';

class OnboardingSurveyContainer extends StatefulWidget {
  final Function(Map<String, dynamic> answers)? onComplete;
  final Function(Map<String, dynamic> answers)? onSaveProgress;
  final Map<String, dynamic>? initialAnswers;

  const OnboardingSurveyContainer({
    super.key,
    this.onComplete,
    this.onSaveProgress,
    this.initialAnswers,
  });

  @override
  State<OnboardingSurveyContainer> createState() => _OnboardingSurveyContainerState();
}

class _OnboardingSurveyContainerState extends State<OnboardingSurveyContainer> {
  // Current position in the survey
  int currentQuestionIndex = 0;
  int currentSectionIndex = 0;
  bool showingSummaryCard = false;
  
  // Answer storage
  Map<String, dynamic> answers = {};
  
  // TODO: Section tracking - this should come from external configuration
  // TODO: Move to separate file: config/onboarding_sections.dart
  final List<String> sectionTitles = [
    'Personal Information',
    'Motivation Style', 
    'Fitness Goals',
    'Current Fitness Level',
    'Health & Medical',
    'Lifestyle & Schedule',
    'Equipment & Location',
  ];
//TODO: add the following sections.
 //  1. Local storage integration
 // 2. Smooth animations
 // 3. Validation logic
 // 4. Firebase integration
 // 5. Error handling

  @override
  void initState() {
    super.initState();
    if (widget.initialAnswers != null) {
      answers = Map<String, dynamic>.from(widget.initialAnswers!);
    }
  }

  // Get the current content to display
  Widget _getCurrentContent() {
    if (showingSummaryCard) {
      return _buildSummaryCard();
    } else {
      return _buildCurrentQuestion();
    }
  }

  // Build the current question
  Widget _buildCurrentQuestion() {
    // For now, we'll create a simple placeholder
    // This is where we'll integrate with our question configuration later
    //TODO: Replace with actual question widget
    return Text("Underconstruction");
  }


  // Get current section title
  String _getCurrentSectionTitle() {
    if (currentSectionIndex < sectionTitles.length) {
      return 'Section ${currentSectionIndex + 1}: ${sectionTitles[currentSectionIndex]}';
    }
    return 'Onboarding';
  }

  // TODO: Build the appropriate question widget - should come from question configuration
  // TODO: Replace with QuestionFactory.buildWidget(currentQuestionConfig, answers, _handleAnswerChanged)
  Widget _buildQuestionWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Text(
            'Question ${currentQuestionIndex + 1} placeholder',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Text('This will be replaced with actual question widgets'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Simulate answering a question
              _handleAnswerChanged('placeholder_$currentQuestionIndex', 'test_answer');
            },
            child: const Text('Simulate Answer'),
          ),
        ],
      ),
    );
  }

  // Handle answer changes
  void _handleAnswerChanged(String questionId, dynamic value) {
    setState(() {
      answers[questionId] = value;
    });
    
    // Auto-save progress
    if (widget.onSaveProgress != null) {
      widget.onSaveProgress!(answers);
    }
  }

  // TODO: Build summary card - should come from summary card configuration
  // TODO: Replace with SummaryCardFactory.buildCard(currentSectionConfig, answers)
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary: ${sectionTitles[currentSectionIndex]}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text('Section ${currentSectionIndex + 1} complete!'),
          const SizedBox(height: 16),
          Text('Answers so far: ${answers.length}'),
          const SizedBox(height: 20),
          Row(
            children: [
              TextButton(
                onPressed: _goBackToSection,
                child: const Text('Edit Answers'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _proceedToNextSection,
                child: const Text('Continue'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _goNext() {
    if (showingSummaryCard) {
      _proceedToNextSection();
    } else {
      // Check if this is the last question in the section
      bool isLastQuestionInSection = _isLastQuestionInSection();
      
      if (isLastQuestionInSection) {
        setState(() {
          showingSummaryCard = true;
        });
      } else {
        setState(() {
          currentQuestionIndex++;
        });
      }
    }
  }

  void _goPrevious() {
    if (showingSummaryCard) {
      setState(() {
        showingSummaryCard = false;
      });
    } else if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    } else if (currentSectionIndex > 0) {
      // Go to previous section's summary
      setState(() {
        currentSectionIndex--;
        showingSummaryCard = true;
        currentQuestionIndex = _getLastQuestionInSection(currentSectionIndex);
      });
    }
  }

  void _proceedToNextSection() {
    if (currentSectionIndex < sectionTitles.length - 1) {
      setState(() {
        currentSectionIndex++;
        currentQuestionIndex = _getFirstQuestionInSection(currentSectionIndex);
        showingSummaryCard = false;
      });
    } else {
      // Survey complete
      if (widget.onComplete != null) {
        widget.onComplete!(answers);
      }
    }
  }

  void _goBackToSection() {
    setState(() {
      showingSummaryCard = false;
    });
  }

  // TODO: Helper methods - these should use actual configuration logic
  // TODO: Replace with sectionConfig.getQuestionCount() and questionConfig.isRequired
  bool _isLastQuestionInSection() {
    // TODO: Get from section configuration instead of hardcoded 4
    return (currentQuestionIndex + 1) % 4 == 0;
  }

  int _getFirstQuestionInSection(int sectionIndex) {
    // TODO: Calculate from actual section configuration
    return sectionIndex * 4;
  }

  int _getLastQuestionInSection(int sectionIndex) {
    // TODO: Calculate from actual section configuration  
    return (sectionIndex * 4) + 3;
  }

  bool _canGoNext() {
    // TODO: Check if current question is answered (if required)
    // TODO: Use questionConfig.isRequired and answers[currentQuestionId]
    return true;
  }

  bool _canGoPrevious() {
    return currentQuestionIndex > 0 || currentSectionIndex > 0 || showingSummaryCard;
  }

  double _getProgress() {
    // Calculate progress based on sections completed
    double sectionProgress = currentSectionIndex / sectionTitles.length;
    return sectionProgress.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getCurrentSectionTitle(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _getProgress(),
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Section ${currentSectionIndex + 1} of ${sectionTitles.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _getCurrentContent(),
              ),
            ),

            // Navigation Buttons
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  if (_canGoPrevious())
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _goPrevious,
                        child: const Text('Previous'),
                      ),
                    )
                  else
                    const Expanded(child: SizedBox()),

                  const SizedBox(width: 16),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canGoNext() ? _goNext : null,
                      child: Text(
                        showingSummaryCard 
                            ? 'Continue'
                            : _isLastQuestionInSection()
                                ? 'Review Section'
                                : 'Next',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}