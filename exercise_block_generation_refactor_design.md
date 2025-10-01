# Exercise Block Generation Refactor

## Problem
Current code decides upfront how many movement patterns to use based on duration, then creates blocks. This leads to complex duration adjustment logic and doesn't guarantee we use available time efficiently.

## Solution
Fill available time with exercise blocks until time runs out:

1. Calculate total time available for main work (73% of workout)
2. Loop through movement patterns, creating exercise blocks
3. After each block, check remaining time
4. If not enough time for another full block, stop
5. If last block pushed us significantly over, pop it off

## Current Flow (Bad)
```dart
patterns → selectPatternsForDuration() → create blocks → check total → adjust sets/rest
```

## New Flow (Good)
```dart
available time → loop: create block → add to stack → check time → stop when full
```

## Plan
- [x] Calculate main work duration from total duration
- [x] Remove `_selectPatternsForDuration` method
- [x] Remove `_adjustBlocksForDuration` method
- [x] Rewrite `_generateMainWorkBlocks` with time-filling loop
- [x] Add time checks after each block creation
- [x] Check if block pushes total too far over (>10%) before adding

## Notes
- Main work = 73% of total workout duration
- Loop through style.mainWorkPatterns repeatedly if needed
- Each block duration = sets × reps × repDuration + rest
- "Too far over" = more than 10% over target

## Results
- Removed 67 lines of complex duration adjustment logic
- Simplified `generateBlocks()` - no more validation/adjustment
- New `_generateMainWorkBlocks()` fills available time directly
- Cycles through movement patterns until time runs out
- Stops before adding a block if it would push total >10% over
- Much simpler, more predictable behavior
