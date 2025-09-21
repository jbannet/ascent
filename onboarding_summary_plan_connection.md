# Onboarding to Summary to Plan View Connection

## Agreements & Decisions
- Need to create a summary view that shows what was learned from onboarding
- Summary view should appear after onboarding completes, before plan view
- The flow should be: Onboarding → Summary → Plan View
- Summary should display the fitness profile insights before showing the generated plan
- Summary should have two buttons: "Edit" (go back to onboarding) and "Generate my plan" (proceed to plan view)

## Plan

### 1. Create OnboardingSummaryView - Detailed Specification

#### Page Layout
**Header Section**
- Title: "Your Fitness Profile"
- Subtitle: "Here's what we learned about you"

**Fitness Metrics Cards** (Top Section - 2x2 grid)
1. **Cardio Fitness Card**
   - VO2 Max: {vo2max} ml/kg/min
   - METs Capacity: {mets_capacity}
   - Cardio Percentile: {cardio_fitness_percentile}%
   - Recovery Days: {cardio_recovery_days}

2. **Strength Metrics Card**
   - Upper Body Percentile: {upper_body_strength_percentile}%
   - Lower Body Percentile: {lower_body_strength_percentile}%
   - Optimal Rep Range: {strength_optimal_rep_range_min}-{strength_optimal_rep_range_max}
   - Recovery Hours: {strength_recovery_hours}h

3. **Heart Rate Zones Card** (visual bar chart)
   - Zone 1 (Recovery): {hr_zone1} bpm
   - Zone 2 (Base): {hr_zone2} bpm
   - Zone 3 (Tempo): {hr_zone3} bpm
   - Zone 4 (Threshold): {hr_zone4} bpm
   - Zone 5 (Max): {hr_zone5} bpm

4. **Session Commitment Card**
   - Full Workouts/Week: {full_sessions_per_week} (large number)
   - Micro Sessions/Week: {micro_sessions_per_week} (large number)
   - Weekly Minutes: {weekly_training_minutes} min
   - Training Days: {total_training_days}

**Category Allocation Visual** (Middle Section)
- Horizontal stacked bar chart with percentages
- Categories: Cardio, Strength, Balance, Flexibility, Functional
- Use Category.color for each segment
- Legend below with percentages

**Risk Factors & Priorities** (if applicable)
- Fall Risk Score: {fall_risk_score} (if > 0)
- Joint Health: {joint_health_score}
- Impact Tolerance: {impact_tolerance}
- Special Considerations based on age/health

**Recommendations Section** (Bottom Cards)
- Training priorities based on percentiles
- Equipment preferences from answers
- Location preferences
- Any injury accommodations

**Action Buttons**
- "Edit" (outlined) - Back to /onboarding
- "Generate my plan" (elevated, primary) - Generate Plan → /plan

#### Visual Design
- Use cards with subtle shadows
- Progress indicators for percentiles
- Color-coded heart rate zones
- Animated number counters on load
- Consistent purple/teal theme

### 2. Generate FitnessProfile & Plan
- In onboarding completion:
  - Get answers from QuestionBank
  - Create FitnessProfile with feature order and answers
  - Navigate to summary (plan generation happens when user clicks "Generate my plan")

### 3. Update Routing
- Add /onboarding-summary route
- Pass FitnessProfile as extra
- "Edit" button navigates back to /onboarding
- "Generate my plan" calls Plan.generateFromFitnessProfile() then navigates to /plan

### 4. Modify OnboardingProvider
- Add method to create FitnessProfile from answers
- Save profile to storage
- Navigate to summary with profile

### 5. Connect Flow
- Onboarding completion → Summary View (with Edit option) → Generate Plan → Plan View
- Summary shows what was learned
- User can edit or proceed to plan generation

### 6. Add to Development Navigator
- Add new tile in TemporaryNavigatorView for testing
- Create mock FitnessProfile with sample feature data
- Test view with various profile configurations

## Task Checklist
- [x] Research existing onboarding flow and plan generation capabilities
- [x] Expand OnboardingSummaryView design with detailed specifications
- [x] Create basic OnboardingSummaryView component structure
- [x] Add to TemporaryNavigatorView with mock FitnessProfile data
- [x] Implement metrics cards and visualizations
- [x] Test view with mock data and fix initial overflow issues
- [x] Implement staggered grid layout for responsive cards with variable heights
- [ ] Generate FitnessProfile from onboarding answers
- [ ] Update routing to include summary view
- [ ] Connect summary view to plan view with generated plan
- [ ] Update onboarding completion handler
- [ ] Test complete flow end-to-end

## Technical Notes
- Current onboarding saves answers to LocalStorage via QuestionBank
- FitnessProfile class exists with feature extraction capabilities
- Plan model has Plan.generateFromFitnessProfile() factory method
- FourWeeks and WeekOfWorkouts have generation methods too
- No need for separate service - use existing Plan generation

## Layout Solution: Staggered Grid
- Problem: Fixed aspect ratio causes content overflow in metric cards
- Solution: Use flutter_staggered_grid_view package for variable height cards
- Benefits: Natural content sizing, responsive columns, no overflow
- Implementation: Replace GridView.count with StaggeredGrid, responsive column count