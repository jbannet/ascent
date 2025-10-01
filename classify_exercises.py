#!/usr/bin/env python3
import json
import os
from pathlib import Path
from collections import defaultdict

def classify_movement_patterns(exercise):
    """Determine movement patterns based on exercise characteristics."""
    patterns = []

    name = exercise.get('name', '').lower()
    force = exercise.get('force', '').lower() if exercise.get('force') else ''
    mechanic = exercise.get('mechanic', '').lower() if exercise.get('mechanic') else ''
    equipment = exercise.get('equipment', '').lower() if exercise.get('equipment') else ''
    primary = [m.lower() for m in exercise.get('primaryMuscles', [])]
    secondary = [m.lower() for m in exercise.get('secondaryMuscles', [])]
    instructions = ' '.join(exercise.get('instructions', [])).lower()
    category = exercise.get('category', '').lower()

    all_muscles = primary + secondary

    # Stretching exercises
    if category == 'stretching' or 'stretch' in name:
        if 'dynamic' in name or 'dynamic' in instructions:
            patterns.append('dynamicStretch')
        elif 'mobility' in name or 'mobility' in instructions:
            patterns.append('mobilityDrill')
        else:
            patterns.append('staticStretch')
        return patterns

    # Cardio exercises
    if category == 'cardio' or any(x in name for x in ['run', 'jog', 'bike', 'cycling', 'row', 'elliptical', 'treadmill', 'cardio', 'aerobic']):
        patterns.append('steadyStateCardio')
        return patterns

    # Plyometric exercises
    if category == 'plyometrics' or any(x in name for x in ['jump', 'hop', 'leap', 'bound', 'box jump', 'broad jump']):
        patterns.append('jump')

    # Throw exercises
    if any(x in name for x in ['throw', 'toss', 'medicine ball throw', 'slam']):
        patterns.append('throw')

    # Carry exercises
    if any(x in name for x in ['carry', 'farmer', 'suitcase', 'waiter walk']):
        patterns.append('carry')

    # Crawl exercises
    if 'crawl' in name or 'bear crawl' in name or 'crab walk' in name:
        patterns.append('crawl')

    # Squat patterns
    squat_keywords = ['squat', 'goblet', 'front squat', 'back squat', 'overhead squat', 'pistol']
    if any(x in name for x in squat_keywords):
        patterns.append('squat')

    # Hinge patterns
    hinge_keywords = ['deadlift', 'rdl', 'romanian', 'good morning', 'hip hinge', 'swing', 'clean', 'snatch']
    if any(x in name for x in hinge_keywords):
        patterns.append('hinge')

    # Lunge patterns
    lunge_keywords = ['lunge', 'step up', 'step-up', 'split squat', 'bulgarian']
    if any(x in name for x in lunge_keywords):
        patterns.append('lunge')

    # Horizontal Push
    horizontal_push = ['bench press', 'push-up', 'pushup', 'push up', 'floor press', 'chest press', 'chest fly', 'pec']
    if force == 'push' and any(x in name for x in horizontal_push):
        patterns.append('horizontalPush')
    elif any(x in name for x in ['push-up', 'pushup', 'push up', 'bench', 'chest press', 'floor press']) and 'chest' in all_muscles:
        patterns.append('horizontalPush')

    # Vertical Push
    vertical_push = ['overhead press', 'military press', 'shoulder press', 'arnold press', 'push press', 'jerk', 'handstand']
    if force == 'push' and any(x in name for x in vertical_push):
        patterns.append('verticalPush')
    elif any(x in name for x in vertical_push):
        patterns.append('verticalPush')
    elif 'press' in name and 'shoulders' in all_muscles and 'chest' not in all_muscles:
        patterns.append('verticalPush')

    # Horizontal Pull
    horizontal_pull = ['row', 'inverted row', 'bent over', 'bent-over', 'cable row', 'machine row', 'face pull']
    if force == 'pull' and any(x in name for x in horizontal_pull):
        patterns.append('horizontalPull')
    elif any(x in name for x in horizontal_pull):
        patterns.append('horizontalPull')

    # Vertical Pull
    vertical_pull = ['pull-up', 'pullup', 'pull up', 'chin-up', 'chinup', 'chin up', 'lat pulldown', 'pull down']
    if force == 'pull' and any(x in name for x in vertical_pull):
        patterns.append('verticalPull')
    elif any(x in name for x in vertical_pull):
        patterns.append('verticalPull')

    # Core patterns
    if 'plank' in name or 'hollow' in name or ('ab' in name and 'static' in name):
        patterns.append('antiExtension')

    if any(x in name for x in ['pallof', 'anti-rotation', 'anti rotation', 'bird dog', 'dead bug']):
        patterns.append('antiRotation')

    if any(x in name for x in ['side plank', 'suitcase', 'side bend']):
        patterns.append('antiLateralFlexion')

    if any(x in name for x in ['russian twist', 'wood chop', 'woodchop', 'rotation', 'twist']):
        patterns.append('rotation')

    # If no patterns assigned and it's strength category, try to infer from muscles
    if not patterns and category == 'strength':
        if 'quadriceps' in all_muscles or 'glutes' in all_muscles:
            if 'hamstrings' in all_muscles:
                patterns.append('hinge')
            else:
                patterns.append('squat')

        if 'chest' in all_muscles and force == 'push':
            patterns.append('horizontalPush')

        if 'lats' in all_muscles or 'middle back' in all_muscles:
            if force == 'pull':
                if any(x in name for x in ['down', 'up']):
                    patterns.append('verticalPull')
                else:
                    patterns.append('horizontalPull')

    return patterns if patterns else ['functional_movement']

def classify_workout_styles(exercise, patterns):
    """Determine workout styles based on exercise characteristics and patterns."""
    styles = []

    name = exercise.get('name', '').lower()
    category = exercise.get('category', '').lower()
    equipment = exercise.get('equipment', '').lower() if exercise.get('equipment') else ''
    primary = [m.lower() for m in exercise.get('primaryMuscles', [])]

    # Yoga focused
    if 'yoga' in name or any(x in name for x in ['downward dog', 'warrior', 'cobra', 'pigeon']):
        styles.append('yoga_focused')
        return styles

    # Pilates style
    if 'pilates' in name or any(x in name for x in ['reformer', 'hundred']):
        styles.append('pilates_style')
        return styles

    # Senior specific - low impact, seated, gentle
    if any(x in name for x in ['seated', 'chair', 'gentle', 'senior']):
        styles.append('senior_specific')

    # Stretching/mobility - multiple styles (but NOT yoga)
    if category == 'stretching':
        styles.extend(['senior_specific', 'athletic_conditioning'])
        return styles

    # Strongman/Functional
    strongman_keywords = ['farmer', 'carry', 'yoke', 'stone', 'tire', 'sled', 'prowler', 'atlas']
    if any(x in name for x in strongman_keywords):
        styles.append('strongman_functional')

    if any(x in patterns for x in ['carry', 'throw', 'crawl']):
        styles.append('strongman_functional')
        styles.append('functional_movement')

    # CrossFit mixed
    crossfit_keywords = ['thruster', 'wall ball', 'box jump', 'burpee', 'kipping', 'muscle-up', 'toes to bar']
    if any(x in name for x in crossfit_keywords):
        styles.append('crossfit_mixed')
        styles.append('concurrent_hybrid')

    if 'jump' in patterns or 'throw' in patterns:
        styles.append('crossfit_mixed')
        styles.append('athletic_conditioning')

    # Circuit/Metabolic
    if category == 'cardio' or 'steadyStateCardio' in patterns:
        styles.append('circuit_metabolic')
        styles.append('endurance_dominant')
        styles.append('concurrent_hybrid')

    # Endurance dominant
    if 'steadyStateCardio' in patterns:
        if 'endurance_dominant' not in styles:
            styles.append('endurance_dominant')

    # Athletic conditioning
    if any(x in patterns for x in ['jump', 'throw', 'crawl', 'dynamicStretch', 'mobilityDrill']):
        if 'athletic_conditioning' not in styles:
            styles.append('athletic_conditioning')

    # Functional movement
    if equipment in ['', 'body only', 'none'] or any(x in patterns for x in ['crawl', 'carry', 'jump']):
        if 'functional_movement' not in styles:
            styles.append('functional_movement')

    # Now assign based on muscle groups for compound strength exercises
    if category == 'strength':
        # Full body indicators
        if len(primary) >= 2 or any(x in patterns for x in ['hinge', 'squat', 'lunge']):
            styles.append('full_body')
            styles.append('functional_movement')
            styles.append('concurrent_hybrid')

        # Upper/Lower split
        upper_muscles = ['chest', 'lats', 'middle back', 'shoulders', 'triceps', 'biceps', 'forearms', 'traps']
        lower_muscles = ['quadriceps', 'hamstrings', 'glutes', 'calves', 'abductors', 'adductors']

        has_upper = any(m in upper_muscles for m in primary)
        has_lower = any(m in lower_muscles for m in primary)

        if has_upper or has_lower:
            styles.append('upper_lower_split')

        # Push/Pull/Legs
        if any(x in patterns for x in ['horizontalPush', 'verticalPush']):
            styles.append('push_pull_legs')

        if any(x in patterns for x in ['horizontalPull', 'verticalPull']):
            styles.append('push_pull_legs')

        if has_lower:
            styles.append('push_pull_legs')

    return list(set(styles)) if styles else ['full_body', 'functional_movement']

def process_exercise_file(filepath):
    """Process a single exercise.json file."""
    with open(filepath, 'r') as f:
        exercise = json.load(f)

    # Classify
    movement_patterns = classify_movement_patterns(exercise)
    workout_styles = classify_workout_styles(exercise, movement_patterns)

    # Add new fields
    exercise['movementPatterns'] = movement_patterns
    exercise['workoutStyles'] = workout_styles

    # Write back
    with open(filepath, 'w') as f:
        json.dump(exercise, f, indent=2)

    return exercise

def main():
    base_path = Path('/Users/jonathanbannet/MyProjects/fitness_app/ascent/assets/exercises')
    exercise_files = list(base_path.glob('*/exercise.json'))

    print(f"Found {len(exercise_files)} exercise files")

    # Statistics
    pattern_counts = defaultdict(int)
    style_counts = defaultdict(int)
    pattern_exercises = defaultdict(list)
    style_exercises = defaultdict(list)

    total_processed = 0

    for filepath in exercise_files:
        try:
            exercise = process_exercise_file(filepath)
            total_processed += 1

            # Track statistics
            for pattern in exercise['movementPatterns']:
                pattern_counts[pattern] += 1
                pattern_exercises[pattern].append(exercise['name'])

            for style in exercise['workoutStyles']:
                style_counts[style] += 1
                style_exercises[style].append(exercise['name'])

            if total_processed % 100 == 0:
                print(f"Processed {total_processed} exercises...")

        except Exception as e:
            print(f"Error processing {filepath}: {e}")

    print(f"\nCompleted processing {total_processed} exercises")

    # Generate summary report
    report_lines = []
    report_lines.append("# Exercise Classification Update Summary\n")
    report_lines.append(f"**Total exercises processed:** {total_processed}\n")
    report_lines.append(f"**Date:** 2025-10-01\n\n")

    # Movement patterns summary (sorted by count ascending)
    report_lines.append("## Movement Patterns Distribution\n")
    report_lines.append("Sorted by count (ascending) to highlight underrepresented patterns:\n\n")
    sorted_patterns = sorted(pattern_counts.items(), key=lambda x: x[1])
    for pattern, count in sorted_patterns:
        report_lines.append(f"- **{pattern}**: {count} exercises\n")

    # Workout styles summary (sorted by count ascending)
    report_lines.append("\n## Workout Styles Distribution\n")
    report_lines.append("Sorted by count (ascending) to highlight underrepresented styles:\n\n")
    sorted_styles = sorted(style_counts.items(), key=lambda x: x[1])
    for style, count in sorted_styles:
        report_lines.append(f"- **{style}**: {count} exercises\n")

    # Patterns with <10 exercises
    report_lines.append("\n## Movement Patterns with <10 Exercises\n")
    low_patterns = [(p, c) for p, c in sorted_patterns if c < 10]
    if low_patterns:
        for pattern, count in low_patterns:
            report_lines.append(f"\n### {pattern} ({count} exercises)\n")
            for ex_name in pattern_exercises[pattern]:
                report_lines.append(f"- {ex_name}\n")
    else:
        report_lines.append("None - all patterns have 10+ exercises\n")

    # Styles with <10 exercises
    report_lines.append("\n## Workout Styles with <10 Exercises\n")
    low_styles = [(s, c) for s, c in sorted_styles if c < 10]
    if low_styles:
        for style, count in low_styles:
            report_lines.append(f"\n### {style} ({count} exercises)\n")
            for ex_name in style_exercises[style]:
                report_lines.append(f"- {ex_name}\n")
    else:
        report_lines.append("None - all styles have 10+ exercises\n")

    # Detailed view: exercises by workout style
    report_lines.append("\n## Exercises by Workout Style (Full List)\n")
    for style, count in sorted_styles:
        report_lines.append(f"\n### {style} ({count} exercises)\n")
        for ex_name in sorted(style_exercises[style]):
            report_lines.append(f"- {ex_name}\n")

    # Write report
    report_path = '/Users/jonathanbannet/MyProjects/fitness_app/exercise_update_summary.md'
    with open(report_path, 'w') as f:
        f.writelines(report_lines)

    print(f"\nSummary report written to: {report_path}")

if __name__ == '__main__':
    main()
