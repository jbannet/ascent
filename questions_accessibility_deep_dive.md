# Questions Workflow Accessibility Deep Dive

## Agreements & Decisions

- **Scope**: Complete accessibility overhaul of the entire onboarding questions workflow
- **Approach**: Question-by-question and widget-by-widget detailed accessibility plan
- **Priority**: Start with question view types (the widgets), then apply to individual questions
- **Standard**: Every question must be fully accessible with keyboard navigation and screen reader support
- **Testing**: Each question type gets individual accessibility testing

## Question View Types Analysis & Plan

### 🔴 CRITICAL: Base Question Infrastructure

#### 1. `/question_views/base_question_view.dart` - Foundation for all questions
- **Current Issues**:
  - No accessibility framework at the base level
  - Missing semantic structure for questions
  - No keyboard navigation foundation
- **Accessibility Requirements**:
  - Add base accessibility mixin
  - Implement question progress announcements
  - Add skip/back button semantics
  - Provide question context to screen readers
- **Implementation**:
  ```dart
  abstract class BaseQuestionView extends StatefulWidget {
    // Add accessibility properties
    String get accessibilityLabel;
    String get accessibilityHint;
    String? get progressAnnouncement;
  }
  ```

#### 2. `/question_views/question_input_view.dart` - Input wrapper
- **Current Issues**:
  - No question metadata announced to screen readers
  - Missing validation feedback accessibility
  - No progress context
- **Accessibility Requirements**:
  - Announce question number and total
  - Provide question context semantics
  - Add validation announcements
  - Implement answer state changes
- **Implementation**:
  ```dart
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Question $currentIndex of $totalQuestions',
      hint: questionText,
      child: // existing widget
    );
  }
  ```

### 🟡 INPUT WIDGETS: Question Types Deep Dive

#### 3. `/question_types/single_choice_view.dart` - Radio Button Groups
**Used by**: Gender, Training Location, Equipment, High Impact, Injuries, GLP1 Medications, Primary Motivation, Progress Tracking

- **Current Issues**:
  - `InkWell` wrapper has no semantic labels
  - `Radio` buttons not properly grouped for screen readers
  - No selection feedback beyond visual
  - No keyboard navigation between options
- **Accessibility Requirements**:
  - Add `radioGroup` semantics
  - Label each option clearly
  - Announce selection changes
  - Enable keyboard navigation (arrow keys)
  - Provide option descriptions for screen readers
- **Detailed Implementation**:
  ```dart
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Select one option',
      child: FocusableActionDetector(
        actions: {
          // Arrow key navigation
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (intent) => _selectOption(),
          ),
        },
        child: Column(
          children: options.map((option) =>
            Semantics(
              inMutuallyExclusiveGroup: true,
              checked: isSelected,
              label: '${option.label}. ${option.description ?? ""}',
              hint: isSelected ? 'Selected' : 'Tap to select',
              child: // existing radio option
            ),
          ).toList(),
        ),
      ),
    );
  }
  ```

#### 4. `/question_types/multiple_choice_view.dart` - Checkbox Groups
**Used by**: Fitness Goals, Fall Risk Factors

- **Current Issues**:
  - Similar to single choice but with checkbox semantics
  - No selection count announcements
  - Missing maximum selection limits announcement
- **Accessibility Requirements**:
  - Add `checkboxGroup` semantics
  - Announce current selection count
  - Provide maximum selection guidance
  - Enable keyboard navigation
  - Announce when selection limit reached
- **Detailed Implementation**:
  ```dart
  Widget build(BuildContext context) {
    final selectedCount = selectedOptions.length;
    final maxSelections = widget.maxSelections ?? options.length;

    return Semantics(
      label: 'Select up to $maxSelections options. $selectedCount selected.',
      child: Column(
        children: options.map((option) =>
          Semantics(
            checked: isSelected(option),
            label: '${option.label}. ${option.description ?? ""}',
            hint: isSelected(option) ? 'Selected. Tap to deselect' : 'Tap to select',
            onTap: () => _toggleOption(option),
            child: // existing checkbox option
          ),
        ).toList(),
      ),
    );
  }
  ```

#### 5. `/question_types/slider_view.dart` - Value Sliders
**Used by**: Pushups, Bodyweight Squats, Chair Stand, Run VO2, Sleep Hours, Session Commitment

- **Current Issues**:
  - Custom slider likely missing semantic actions
  - No value announcements during dragging
  - Missing increase/decrease keyboard controls
  - No range information for screen readers
- **Accessibility Requirements**:
  - Add proper slider semantics
  - Implement increase/decrease actions
  - Announce current value and range
  - Enable keyboard controls (arrow keys)
  - Provide value context (e.g., "pushups", "hours")
- **Detailed Implementation**:
  ```dart
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
              event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _incrementValue();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
                     event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _decrementValue();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Semantics(
        slider: true,
        value: '$currentValue',
        increasedValue: '${currentValue + 1}',
        decreasedValue: '${currentValue - 1}',
        label: '${widget.label}. Range: ${widget.min} to ${widget.max}',
        hint: 'Use arrow keys or drag to adjust value',
        onIncrease: currentValue < widget.max ? _incrementValue : null,
        onDecrease: currentValue > widget.min ? _decrementValue : null,
        child: // existing slider widget
      ),
    );
  }
  ```

#### 6. `/question_types/text_input_view.dart` - Text Inputs
**Used by**: Open-ended responses, text feedback

- **Current Issues**:
  - Need proper labels and hints
  - Missing validation announcements
  - No character count feedback
- **Accessibility Requirements**:
  - Use proper `TextFormField` semantics
  - Add validation feedback
  - Provide character limits
  - Enable voice input
- **Detailed Implementation**:
  ```dart
  TextFormField(
    decoration: InputDecoration(
      labelText: widget.questionText,
      hintText: widget.placeholder ?? 'Enter your response',
      helperText: widget.maxLength != null
        ? 'Maximum ${widget.maxLength} characters'
        : null,
      errorText: validationError,
    ),
    maxLength: widget.maxLength,
    validator: (value) => _validateInput(value),
    onChanged: (value) {
      // Announce validation changes to screen readers
      if (validationError != null) {
        _announceValidation();
      }
    },
    // Built-in accessibility support
  )
  ```

#### 7. `/question_types/number_input_view.dart` - Numeric Inputs
**Used by**: Age, Weight, Height, numeric assessments

- **Current Issues**:
  - Need numeric keyboard hints
  - Missing range validation announcements
  - No unit announcements (pounds, inches, etc.)
- **Accessibility Requirements**:
  - Add numeric keyboard type
  - Announce value ranges and units
  - Provide increment/decrement buttons
  - Add validation feedback
- **Detailed Implementation**:
  ```dart
  Column(
    children: [
      Semantics(
        label: '${widget.questionText}. Enter value between ${widget.min} and ${widget.max} ${widget.unit}',
        child: TextFormField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: widget.questionText,
            suffixText: widget.unit,
            helperText: 'Range: ${widget.min} - ${widget.max} ${widget.unit}',
          ),
          // Numeric input validation
        ),
      ),
      // Optional increment/decrement buttons for accessibility
      Row(
        children: [
          Semantics(
            button: true,
            label: 'Decrease value',
            onTap: _decrementValue,
            child: IconButton(
              onPressed: _decrementValue,
              icon: Icon(Icons.remove),
            ),
          ),
          Semantics(
            button: true,
            label: 'Increase value',
            onTap: _incrementValue,
            child: IconButton(
              onPressed: _incrementValue,
              icon: Icon(Icons.add),
            ),
          ),
        ],
      ),
    ],
  )
  ```

#### 8. `/question_types/date_picker_view.dart` - Date Selection
**Used by**: Age (Date of Birth)

- **Current Issues**:
  - Custom date picker needs accessibility
  - Date format not announced clearly
  - Missing keyboard navigation
- **Accessibility Requirements**:
  - Use platform date picker when possible
  - Announce date format clearly
  - Provide keyboard input alternative
  - Add date validation feedback
- **Detailed Implementation**:
  ```dart
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          button: true,
          label: selectedDate != null
            ? 'Date of birth: ${DateFormat.yMMMMd().format(selectedDate!)}'
            : 'Select date of birth',
          hint: 'Tap to open date picker',
          child: InkWell(
            onTap: _showDatePicker,
            child: // date display widget
          ),
        ),
        // Alternative text input for accessibility
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Or enter date (MM/DD/YYYY)',
            hintText: '01/15/1990',
          ),
          keyboardType: TextInputType.datetime,
          onChanged: _parseTextDate,
        ),
      ],
    );
  }
  ```

#### 9. `/question_types/dual_picker_view.dart` - Two-Value Picker
**Used by**: Height (feet & inches), Weight with units

- **Current Issues**:
  - Complex interaction needs clear semantics
  - Relationship between values not clear
  - Missing combined value announcements
- **Accessibility Requirements**:
  - Add picker semantics for each component
  - Announce value relationships
  - Provide combined value summary
  - Enable independent navigation
- **Detailed Implementation**:
  ```dart
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Enter ${widget.title}. Two part input.',
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              label: '${widget.firstLabel}. Currently ${firstValue}',
              slider: true,
              value: firstValue.toString(),
              onIncrease: _incrementFirst,
              onDecrease: _decrementFirst,
              child: // first picker
            ),
          ),
          Expanded(
            child: Semantics(
              label: '${widget.secondLabel}. Currently ${secondValue}',
              slider: true,
              value: secondValue.toString(),
              onIncrease: _incrementSecond,
              onDecrease: _decrementSecond,
              child: // second picker
            ),
          ),
        ],
      ),
    );
  }

  // Announce combined value
  void _announceCombinedValue() {
    final combinedValue = '$firstValue ${widget.firstUnit} $secondValue ${widget.secondUnit}';
    // Use semantic announcements for combined value
  }
  ```

#### 10. `/question_types/wheel_picker_view.dart` - Wheel/Drum Picker
**Used by**: Time selection, list selection

- **Current Issues**:
  - Custom wheel picker needs scroll semantics
  - Current value not clearly announced
  - Missing keyboard navigation
- **Accessibility Requirements**:
  - Add scrollable semantics
  - Announce current value changes
  - Enable keyboard navigation
  - Provide alternative list selection
- **Detailed Implementation**:
  ```dart
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          label: 'Select ${widget.title}',
          value: 'Currently selected: ${currentValue}',
          hint: 'Scroll to change selection',
          child: Focus(
            onKeyEvent: _handleKeyNavigation,
            child: // wheel picker widget
          ),
        ),
        // Alternative dropdown for accessibility
        DropdownButton<String>(
          value: currentValue,
          hint: Text('Select ${widget.title}'),
          items: widget.options.map((option) =>
            DropdownMenuItem(
              value: option,
              child: Text(option),
            ),
          ).toList(),
          onChanged: _onValueChanged,
        ),
      ],
    );
  }
  ```

## Individual Questions Accessibility Plan

### 🔵 DEMOGRAPHICS SECTION

#### Age Question (`age_question.dart`)
- **Widget Type**: DatePickerView
- **Accessibility Issues**: Date picker accessibility
- **Specific Fixes**:
  - Add age calculation announcements
  - Provide text input alternative
  - Announce date format requirements

#### Gender Question (`gender_question.dart`)
- **Widget Type**: SingleChoiceView
- **Accessibility Issues**: Gender options semantics
- **Specific Fixes**:
  - Add inclusive language support
  - Ensure all options are clearly labeled
  - Provide custom option input if available

#### Height Question (`height_question.dart`)
- **Widget Type**: DualPickerView (feet & inches)
- **Accessibility Issues**: Two-part measurement
- **Specific Fixes**:
  - Announce combined height value
  - Add metric/imperial unit announcements
  - Provide direct numeric input alternative

#### Weight Question (`weight_question.dart`)
- **Widget Type**: NumberInputView
- **Accessibility Issues**: Units not clear
- **Specific Fixes**:
  - Announce current unit system
  - Add unit conversion feedback
  - Provide increment/decrement buttons

### 🟢 FITNESS ASSESSMENT SECTION

#### Q4 Run VO2 Question (`q4_run_vo2_question.dart`)
- **Widget Type**: SliderView
- **Accessibility Issues**: Time/distance not clear
- **Specific Fixes**:
  - Add time format announcements
  - Provide fitness level context
  - Add "skip if unable" option

#### Q5 Pushups Question (`q5_pushups_question.dart`)
- **Widget Type**: SliderView
- **Accessibility Issues**: Form quality not addressed
- **Specific Fixes**:
  - Add form instruction semantics
  - Provide modification options
  - Add "skip if unable" option

#### Q6 Bodyweight Squats Question (`q6_bodyweight_squats_question.dart`)
- **Widget Type**: SliderView
- **Accessibility Issues**: Similar to pushups
- **Specific Fixes**:
  - Add form instruction semantics
  - Provide modification guidance
  - Add "skip if unable" option

#### Q6A Chair Stand Question (`q6a_chair_stand_question.dart`)
- **Widget Type**: SliderView
- **Accessibility Issues**: Chair requirement not clear
- **Specific Fixes**:
  - Add equipment requirement announcement
  - Provide setup instructions
  - Add safety guidance

### 🟡 LIFESTYLE SECTION

#### Sleep Hours Question (`sleep_hours_question.dart`)
- **Widget Type**: SliderView
- **Accessibility Issues**: Time format
- **Specific Fixes**:
  - Add hour format announcements
  - Provide healthy range context
  - Add decimal hour input option

#### Current Exercise Days Question (`current_exercise_days_question.dart`)
- **Widget Type**: SliderView
- **Accessibility Issues**: Exercise definition
- **Specific Fixes**:
  - Add exercise definition context
  - Provide examples of counting criteria
  - Add frequency guidance

#### Sedentary Job Question (`sedentary_job_question.dart`)
- **Widget Type**: SingleChoiceView
- **Accessibility Issues**: Job type definitions
- **Specific Fixes**:
  - Add job type explanations
  - Provide examples for each option
  - Add context for mixed jobs

### 🟣 NUTRITION SECTION (CURRENT FOCUS)

#### Sugary Treats Question (`sugary_treats_question.dart`)
- **Widget Type**: NutritionTableBars (custom)
- **Status**: ✅ Accessibility implemented (needs refactoring)
- **Next Steps**: Apply cleaner pattern to other nutrition questions

#### Sodas Question (`sodas_question.dart`)
- **Widget Type**: NutritionTableBars (custom)
- **Accessibility Issues**: Same as sugary treats
- **Fixes**: Apply same pattern as sugary treats

#### Grains Question (`grains_question.dart`)
- **Widget Type**: NutritionTableBars (custom)
- **Accessibility Issues**: Same as sugary treats
- **Fixes**: Apply same pattern as sugary treats

#### Alcohol Question (`alcohol_question.dart`)
- **Widget Type**: NutritionTableBars (custom)
- **Accessibility Issues**: Same as sugary treats
- **Fixes**: Apply same pattern as sugary treats

### 🔴 GOALS & MOTIVATION SECTION

#### Fitness Goals Question (`fitness_goals_question.dart`)
- **Widget Type**: MultipleChoiceView
- **Accessibility Issues**: Multiple selection limits
- **Specific Fixes**:
  - Add selection count announcements
  - Provide goal category explanations
  - Add priority ranking option

#### Primary Motivation Question (`primary_motivation_question.dart`)
- **Widget Type**: SingleChoiceView
- **Accessibility Issues**: Motivation context
- **Specific Fixes**:
  - Add motivation explanations
  - Provide personal relevance context
  - Add custom motivation option

#### Progress Tracking Question (`progress_tracking_question.dart`)
- **Widget Type**: SingleChoiceView
- **Accessibility Issues**: Tracking method explanations
- **Specific Fixes**:
  - Add tracking method descriptions
  - Provide technology requirements
  - Add privacy considerations

### 🟠 PRACTICAL CONSTRAINTS SECTION

#### Injuries Question (`q1_injuries_question.dart`)
- **Widget Type**: SingleChoiceView
- **Accessibility Issues**: Medical privacy
- **Specific Fixes**:
  - Add privacy assurance
  - Provide medical disclaimer
  - Add consultation recommendations

#### Equipment Question (`q10_equipment_question.dart`)
- **Widget Type**: MultipleChoiceView
- **Accessibility Issues**: Equipment descriptions
- **Specific Fixes**:
  - Add equipment descriptions
  - Provide alternative options
  - Add budget considerations

#### Training Location Question (`q11_training_location_question.dart`)
- **Widget Type**: SingleChoiceView
- **Accessibility Issues**: Location context
- **Specific Fixes**:
  - Add location requirement explanations
  - Provide setup guidance
  - Add space requirement context

## Implementation Priority Schedule

### Week 1: Foundation & Critical Widgets
- [ ] Fix `base_question_view.dart` accessibility framework
- [ ] Fix `question_input_view.dart` progress announcements
- [ ] Fix `single_choice_view.dart` radio group semantics
- [ ] Fix `multiple_choice_view.dart` checkbox semantics

### Week 2: Complex Input Widgets
- [ ] Fix `slider_view.dart` with keyboard controls
- [ ] Fix `date_picker_view.dart` accessibility
- [ ] Fix `dual_picker_view.dart` complex interactions
- [ ] Fix `number_input_view.dart` with units

### Week 3: Specialized Widgets & Questions
- [ ] Fix `wheel_picker_view.dart` scroll semantics
- [ ] Fix `text_input_view.dart` validation
- [ ] Apply fixes to all Demographics questions
- [ ] Apply fixes to all Lifestyle questions

### Week 4: Assessment & Complex Questions
- [ ] Apply fixes to all Fitness Assessment questions
- [ ] Apply fixes to all Goals & Motivation questions
- [ ] Apply fixes to all Practical Constraints questions
- [ ] Comprehensive testing of entire question flow

## Testing Protocol (Per Question)

### Screen Reader Testing:
- [ ] VoiceOver announces question context
- [ ] TalkBack reads all options clearly
- [ ] Progress is announced on navigation
- [ ] Validation feedback is spoken
- [ ] Selection changes are confirmed

### Keyboard Navigation Testing:
- [ ] Tab navigation works through all elements
- [ ] Arrow keys work for sliders/pickers
- [ ] Enter/Space activates selections
- [ ] Escape cancels selections where appropriate
- [ ] Focus indicators are visible

### Assistive Technology Testing:
- [ ] Switch control works for all interactions
- [ ] Voice control recognizes all elements
- [ ] Large text scaling doesn't break layout
- [ ] High contrast mode remains usable

## Success Metrics

- [ ] Every question widget has proper accessibility
- [ ] Complete onboarding flow works with keyboard only
- [ ] Screen reader users can complete entire assessment
- [ ] All questions pass automated accessibility scanning
- [ ] Manual testing confirms real-world usability
- [ ] Documentation exists for future question development