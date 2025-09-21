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

### 6. Complete Development Navigator Integration

**Three Entry Points for Testing:**

1. **"Test Full Onboarding Flow" Button (New)**
   - Starts fresh onboarding workflow
   - Goes through all questions
   - On completion: Generates FitnessProfile from answers
   - Navigates: Onboarding → Summary → Plan View
   - Complete end-to-end experience

2. **"Onboarding Summary" Button (Update Existing)**
   - Shows summary with REAL data from saved profile
   - Loads FitnessProfile from LocalStorage (if exists)
   - Falls back to mock data if no saved profile
   - Can navigate to Plan View with "Generate my plan"

3. **"Plan View" Button (Update Existing)**
   - Shows plan generated from REAL saved profile
   - Loads FitnessProfile from LocalStorage (if exists)
   - Generates Plan using Plan.generateFromFitnessProfile()
   - Falls back to mock plan if no saved profile

**Implementation Requirements:**
- Create profile loading utility for saved FitnessProfile
- Update all TemporaryNavigatorView tiles to use real data when available
- Ensure seamless fallback to mock data for testing

## Task Checklist
- [x] Research existing onboarding flow and plan generation capabilities
- [x] Expand OnboardingSummaryView design with detailed specifications
- [x] Create basic OnboardingSummaryView component structure
- [x] Add to TemporaryNavigatorView with mock FitnessProfile data
- [x] Implement metrics cards and visualizations
- [x] Test view with mock data and fix initial overflow issues
- [x] Implement staggered grid layout for responsive cards with variable heights
- [x] Design app state management strategy (Model Self-Persistence + GetIt)
- [x] Add GetIt dependency to pubspec.yaml
- [ ] Add JSON serialization to FitnessProfile (fromJson/toJson)
- [ ] Add persistence methods to FitnessProfile (loadFromStorage/saveToStorage)
- [ ] Add persistence methods to Plan (loadFromStorage/saveToStorage)
- [ ] Create simplified AppDataService (orchestrator only)
- [ ] Create AppStateProvider wrapper for UI reactivity
- [ ] Update main.dart with GetIt setup and initial loading
- [ ] Update TemporaryNavigatorView to use AppStateProvider
- [ ] Update routing to load from AppDataService
- [ ] Connect onboarding completion to AppDataService
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
- Implementation: StaggeredGrid.extent with 220px maxCrossAxisExtent for automatic responsive layout
- Result: 1-6 columns automatically based on screen width (iPhone SE to desktop)

## State Management Strategy
### Problem Statement
- Need global access to FitnessProfile and Plan from both widgets AND models
- Widget prop drilling for passing Profile/Plan through navigation
- Model prop drilling when generating Plan → FourWeeks → WeekOfWorkouts
- Need reactive UI updates when profile/plan changes
- Need to know app state at startup (where user is in the flow)

### Solution: Model Self-Persistence + GetIt Coordination
- **Each model handles its own persistence** (FitnessProfile, Plan)
- **GetIt** provides global service locator for context-free access
- **AppDataService** (thin orchestrator) loads all models at startup
- **AppStateProvider** (ChangeNotifier) wraps service for UI reactivity

### Architecture Benefits
- Clean separation: models manage their own storage
- AppDataService knows app state at startup (profile exists? plan exists?)
- Models can access each other via `AppDataService.instance` without parameters
- Widgets receive data through constructors (remain pure and testable)
- Navigation simplified (no need to pass extras)
- Single source of truth for app state

## Revised Implementation Steps
### Phase 1: Model Persistence
1. Add `get_it: ^7.6.0` to pubspec.yaml ✅
2. Add JSON methods to FitnessProfile (`fromJson`, `toJson`)
3. Add persistence methods to FitnessProfile (`loadFromStorage`, `saveToStorage`)
4. Add persistence methods to Plan (`loadFromStorage`, `saveToStorage`)

### Phase 2: AppDataService (Orchestrator)
5. Create simplified `/lib/services_and_utilities/app_state/app_data_service.dart`
   - Loads all models at startup
   - Simple setters that persist
   - Provides app state (hasProfile, hasPlan)

### Phase 3: Provider Integration
6. Create `/lib/providers/app_state_provider.dart` (wrapper for UI reactivity)
7. Update main.dart with GetIt setup and initial loading
8. Wrap MyApp with MultiProvider

### Phase 4: UI Updates
9. Update TemporaryNavigatorView with Consumer<AppStateProvider>
10. Update route builders to check AppDataService first

### Phase 5: Connect Flow
11. Update onboarding completion to save via AppDataService
12. Update OnboardingSummaryView "Generate" button to use AppDataService
13. Test full flow from onboarding → summary → plan

### Key Architecture Points
- **FitnessProfile** manages its own Hive storage using existing LocalStorageService
- **Plan** gets its own storage mechanism (new Hive box)
- **AppDataService** just coordinates and caches in memory
- **OnboardingProvider** continues to work as-is (no changes needed)
- App startup: `loadFromStorage()` tells us where user is in the flow