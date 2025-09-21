# Claude Code Guidelines for Fitness App

This file contains instructions for Claude Code when working on the fitness app project.

## Large Changes Protocol

**ALWAYS create a dedicated file in the root directory for large changes** such as:
- Feature implementations (e.g., `workout_tracking_feature.md`)
- Major refactoring (e.g., `model_restructure.md`)
- Bug fix sessions (e.g., `performance_issues.md`)
- Architecture changes (e.g., `state_management_migration.md`)

## Tracking Requirements

For each dedicated file, **ALWAYS**:

1. **Track agreements and decisions**
   - Record what was agreed upon with the user
   - Document technical decisions and rationale
   - Note any constraints or requirements

2. **Track the plan and todos**
   - Break down the work into specific tasks
   - Keep todos updated as work progresses
   - Include acceptance criteria where applicable

3. **Mark todos as complete**
   - Update status when tasks are finished
   - Note any blockers or changes to the plan
   - Record outcomes and results

## File Format Template

```markdown
# [Change Name]

## Agreements & Decisions
- [Key decisions made with user]

## Plan
- [ ] Task 1
- [ ] Task 2
- [x] Completed task

## Notes
- [Technical notes, blockers, etc.]
```

## Fitness App Context

This Flutter app focuses on fitness planning and workout tracking. Key areas include:
- Workout models and fitness plans
- Session tracking and metrics
- User fitness profiles
- Progress visualization