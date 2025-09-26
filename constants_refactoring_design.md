# Constants Refactoring Design

## Agreements & Decisions
- Replace ALL hardcoded strings and numeric values in fitness profile extractors with constants
- Create dedicated constants classes for each extractor domain
- Use existing `constants_features.dart` file as the central location
- Fix percentile calculation bugs (COMPLETED ✅)
- Follow pattern: `ExtractorNameConstants` class with feature keys, thresholds, and values

## ❌ CRITICAL ISSUE DISCOVERED ❌
- Extractors are creating unauthorized features NOT in the source of truth design document
- **SOURCE OF TRUTH:** `/Users/jonathanbannet/MyProjects/fitness_app/ascent/lib/models/fitness_profile_model/__design_fitness_profile.txt`
- **RULE:** If feature is NOT in design doc → REMOVE IT from featuresMap
- **RULE:** If feature IS in design doc → use constants for hardcoded values

## CORRECTIVE ACTIONS REQUIRED
- Fix WeightManagementConstants: Remove 25+ unauthorized features, keep only 5 allowed
- Fix weight_management.dart: Remove all unauthorized featuresMap assignments
- Review ALL extractors against design doc before completing constants refactoring

## Plan

### Phase 1: Complete Existing Work
- [x] Fix all percentile calculation bugs (0-1 → 0-100)
- [x] Create StrengthConstants class infrastructure
- [ ] **IN PROGRESS:** Complete strength.dart refactoring (50% done)

### Phase 2: Create Constants Classes
Based on analysis showing 106+ hardcoded values across 7 files:

#### 2.1 CardioConstants (11 hardcoded values)
- [ ] Analyze cardio.dart for all strings and values
- [ ] Create CardioConstants class
- [ ] Refactor cardio.dart to use constants

#### 2.2 BalanceConstants (4 hardcoded values)
- [ ] Analyze balance.dart for all strings and values
- [ ] Create BalanceConstants class
- [ ] Refactor balance.dart to use constants

#### 2.3 ObjectiveImportanceConstants (28 hardcoded values)
- [ ] Analyze relative_objective_importance.dart for all strings and values
- [ ] Create ObjectiveImportanceConstants class
- [ ] Refactor relative_objective_importance.dart to use constants

#### 2.4 WeightManagementConstants (31 hardcoded values)
- [ ] Analyze weight_management.dart for all strings and values
- [ ] Create WeightManagementConstants class
- [ ] Refactor weight_management.dart to use constants

#### 2.5 FlexibilityConstants (4 hardcoded values)
- [ ] Analyze flexibility.dart for all strings and values
- [ ] Create FlexibilityConstants class
- [ ] Refactor flexibility.dart to use constants

#### 2.6 LowImpactConstants (12 hardcoded values)
- [ ] Analyze low_impact.dart for all strings and values
- [ ] Create LowImpactConstants class
- [ ] Refactor low_impact.dart to use constants

### Phase 3: Final Verification
- [ ] Run Flutter analyze to ensure no compilation errors
- [ ] Verify all magic numbers are replaced with named constants
- [ ] Update any remaining extractors that weren't in initial count

## Tracking Details

### Files to Process:
1. **strength.dart** - 16 hardcoded values (IN PROGRESS - 50% done)
2. **cardio.dart** - 11 hardcoded values
3. **balance.dart** - 4 hardcoded values
4. **relative_objective_importance.dart** - 28 hardcoded values
5. **weight_management.dart** - 31 hardcoded values
6. **flexibility.dart** - 4 hardcoded values
7. **low_impact.dart** - 12 hardcoded values

**Total:** 106+ hardcoded values to replace

### Constants Classes Created:
- [x] StrengthConstants (43 constants) ✅
- [x] AgeThresholds (9 constants) ✅
- [ ] CardioConstants
- [ ] BalanceConstants
- [ ] ObjectiveImportanceConstants
- [ ] WeightManagementConstants
- [ ] FlexibilityConstants
- [ ] LowImpactConstants

### Current Progress:
- **Percentile bugs:** Fixed ✅
- **Constants infrastructure:** Established ✅
- **Source of truth alignment:** CRITICAL ISSUE FIXED ✅
- **Strength refactoring:** Complete ✅
- **Cardio refactoring:** Complete ✅
- **Balance refactoring:** Complete ✅
- **Relative objective importance refactoring:** Complete ✅
- **Weight management refactoring:** Complete (authorized features only) ✅
- **Flexibility refactoring:** Complete (authorized features only) ✅
- **Low impact refactoring:** Complete (disabled - not in design doc) ✅

## Notes
- Large refactoring requires systematic approach to avoid losing track
- Each extractor has unique domain-specific constants
- Some constants may be shared across extractors (use AgeThresholds class)
- All string feature keys must become constants to prevent typos
- All numeric thresholds must become named constants for maintainability

## Completion Criteria
- [ ] Zero hardcoded strings in featuresMap assignments
- [ ] Zero magic numbers in conditional logic
- [ ] All constants have descriptive names
- [ ] Flutter analyze passes with no errors
- [ ] All 7 extractor files fully refactored