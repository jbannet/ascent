# View Files Refactoring Design

## Agreements & Decisions

- Focus on production view/widget files only (no test files, temporary files)
- Break down large view files (500+ lines) into smaller, focused components
- Extract reusable widgets and data models
- Maintain existing functionality while improving maintainability
- Follow existing code conventions and patterns

## Plan

### Priority Files for Refactoring:

#### 1. completion_stats_header.dart (697 lines) - DETAILED BREAKDOWN

**Current Structure Analysis:**
- `AllocationBarConstants` class (4 lines)
- `CompletionStatsHeader` StatefulWidget (25 lines)
- `_CompletionStatsHeaderState` class (431 lines) with 9 widget methods
- `MomentumWavesPainter` CustomPainter class (238 lines)

**New Directory Structure:**
```
plan_header/
├── completion_stats_header.dart (main widget - ~80 lines) - Main composition widget
├── models/
│   └── allocation_bar_constants.dart (~15 lines) - UI constants for bar styling
├── widgets/
│   ├── stats_main_content.dart (~120 lines) - Main content container with metrics layout
│   ├── top_metrics_row.dart (~60 lines) - 4-week, streak, this week metrics row
│   ├── center_metrics_row.dart (~80 lines) - Central number with nutrition/sleep circles
│   ├── streak_counter_widget.dart (~50 lines) - Fire icon streak counter with styling
│   ├── circular_progress_metric.dart (~40 lines) - Reusable circular progress with icon
│   ├── category_allocation_section.dart (~90 lines) - Category allocation title and charts
│   └── allocation_bar_chart.dart (~70 lines) - Horizontal segmented progress bar
├── painters/
│   └── momentum_waves_painter.dart (~250 lines) - Custom painter for animated background waves
└── controllers/
    └── stats_animation_manager.dart (~80 lines) - Manages all animation controllers and timing
```

**Refactoring Tasks:**
- [x] Create `plan_header/` directory structure
- [x] Extract `AllocationBarConstants` to `models/allocation_bar_constants.dart`
- [x] Extract `MomentumWavesPainter` to `painters/momentum_waves_painter.dart`
- [x] Create `StatsAnimationManager` to handle all animation controllers
- [x] Extract `_buildMainContent` to `StatsMainContent` widget
- [x] Extract `_buildTopMetric` to `TopMetricsRow` widget
- [x] Extract center metrics section to `CenterMetricsRow` widget
- [x] Extract `_buildStreakCounter` to `StreakCounterWidget`
- [x] Extract `_buildBottomCircularMetric` to `CircularProgressMetric` widget
- [x] Extract `_buildStyleAllocation` to `CategoryAllocationSection` widget
- [x] Extract allocation chart logic to `AllocationBarChart` widget
- [x] Refactor main widget to compose smaller components
- [x] Fix import issues in other files using AllocationBarConstants

**COMPLETED - Results:**
- Original file: 697 lines → Refactored main file: 93 lines (86% reduction!)
- Created 11 focused, reusable components
- All components follow single responsibility principle
- Animation management centralized in dedicated manager
- No compilation errors or warnings
- Import paths properly maintained

**File Size Estimates:**
- Main widget: 80 lines (composition + state management)
- Animation manager: 80 lines (all animation controllers)
- Wave painter: 250 lines (exact extraction)
- Individual widgets: 40-120 lines each (focused components)
- Constants: 15 lines (extracted constants)

**Implementation Considerations:**

1. **Directory Placement:**
   - New directory: `workflow_views/fitness_plan/widgets/plan_header/`
   - Maintains consistent import paths and relative imports
   - Follows existing project structure

2. **Animation Controller Dependencies:**
   - Main `CompletionStatsHeader` retains `TickerProviderStateMixin`
   - Pass `this` as TickerProvider to `StatsAnimationManager` constructor
   - Main widget disposes animation manager in `dispose()`
   - Animation manager exposes animations via getters for widgets to consume

3. **State Sharing Patterns:**
   - Pass required data as constructor parameters to child widgets
   - Use `AnimatedBuilder` widgets to rebuild on animation changes
   - Consider `InheritedWidget` if many components need same animations
   - Wave painter receives animation values through constructor

4. **Import Strategy:**
   - Use standard imports (not `part`/`part of`) for better testability
   - Each widget file imports only what it needs
   - Maintain lowercase_with_underscores naming convention

5. **Testing Updates:**
   - Update existing tests that import `completion_stats_header.dart`
   - Add widget tests for each new component
   - Mock animation controllers in tests for deterministic behavior

6. **State Management Flow:**
   ```
   CompletionStatsHeader (StatefulWidget)
   ├── StatsAnimationManager (manages all controllers)
   ├── MomentumWavesPainter (receives animation values)
   └── Child widgets (receive animations via AnimatedBuilder)
   ```

#### 2. onboarding_summary_view.dart (517 lines)
- [ ] Extract `FitnessProfileHeader` widget
- [ ] Create individual metric card widgets:
  - [ ] `CardioMetricCard`
  - [ ] `StrengthMetricCard`
  - [ ] `HeartRateZonesCard`
  - [ ] `SessionCommitmentCard`
- [ ] Extract `CategoryAllocationSection` widget
- [ ] Create `RiskFactorsPrioritiesSection` widget
- [ ] Move calculation logic to helper classes

#### 3. persistent_bucket_widget.dart (559 lines)
- [ ] Extract `BucketItem` model to models/nutrition/
- [ ] Extract `NutritionTypeConfig` model to models/nutrition/
- [ ] Create `FallingItemWidget` for animation
- [ ] Create `BucketItemWidget` for individual items
- [ ] Extract `NutritionWheelPicker` widget
- [ ] Separate animation logic from UI

### Additional Large Files (300+ lines):
- ranking_widget.dart (505 lines)
- nutrition_table_bars.dart (391 lines)
- diet_quality_summary.dart (386 lines)
- date_picker_widget.dart (383 lines)

## Common Refactoring Patterns:

1. **Extract Data Models**
   - Move classes to appropriate `/models` subdirectories
   - Keep UI logic separate from data structures

2. **Widget Composition**
   - Break complex build methods into smaller widgets
   - Use composition over large monolithic widgets

3. **Extract Animation Logic**
   - Create dedicated animation controller classes
   - Separate animation configuration from UI

4. **Constants Extraction**
   - Move UI constants to theme/constants files
   - Centralize styling configurations

5. **Business Logic Separation**
   - Move calculations to service/helper classes
   - Keep widgets focused on presentation

## Benefits Expected:
- Better testability (can test components individually)
- Improved reusability across the app
- Easier maintenance and debugging
- Better code organization
- Reduced cognitive load when working on features
- Cleaner git diffs for changes

## Notes:
- Each refactoring should maintain existing functionality
- Test the refactored components to ensure no regressions
- Consider adding unit tests for extracted widgets
- Follow existing import patterns and file organization