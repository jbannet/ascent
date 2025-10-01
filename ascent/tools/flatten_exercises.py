#!/usr/bin/env python3
"""
Flatten the nested exercise directory structure into flat directories for Flutter asset loading.

This script:
1. Copies exercise.json files from exercises/{name}/exercise.json to exercises_flat/{name}.json
2. Copies image files from exercises/{name}/images/*.jpg to exercises_images/{name}_{num}.jpg

The original nested structure in exercises/ is preserved as the source of truth.

Usage:
    python tools/flatten_exercises.py
"""

import json
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EXERCISE_ROOT = ROOT / "assets" / "exercises"
FLAT_ROOT = ROOT / "assets" / "exercises_flat"
IMAGES_ROOT = ROOT / "assets" / "exercises_images"


def flatten_exercises():
    """Flatten the exercise directory structure."""

    # Create output directories
    FLAT_ROOT.mkdir(parents=True, exist_ok=True)
    IMAGES_ROOT.mkdir(parents=True, exist_ok=True)

    exercise_dirs = [d for d in EXERCISE_ROOT.iterdir() if d.is_dir()]

    processed = 0
    errors = []
    total_images = 0

    for exercise_dir in sorted(exercise_dirs):
        dir_name = exercise_dir.name

        # Copy exercise.json
        source_json = exercise_dir / "exercise.json"
        if source_json.exists():
            dest_json = FLAT_ROOT / f"{dir_name}.json"
            shutil.copy2(source_json, dest_json)
            processed += 1
        else:
            errors.append(f"Missing exercise.json in {dir_name}")
            continue

        # Copy images if they exist
        images_dir = exercise_dir / "images"
        if images_dir.exists() and images_dir.is_dir():
            for img_file in sorted(images_dir.iterdir()):
                if img_file.is_file() and img_file.suffix.lower() in ['.jpg', '.jpeg', '.png', '.gif']:
                    # Remove extension, get base name (usually just a number like "0", "1")
                    img_base = img_file.stem
                    dest_img = IMAGES_ROOT / f"{dir_name}_{img_base}{img_file.suffix}"
                    shutil.copy2(img_file, dest_img)
                    total_images += 1

    print(f"✓ Processed {processed} exercises")
    print(f"✓ Copied {total_images} images")
    print(f"✓ Created {FLAT_ROOT}")
    print(f"✓ Created {IMAGES_ROOT}")

    if errors:
        print(f"\n⚠ {len(errors)} errors:")
        for err in errors:
            print(f"  - {err}")

    print("\nNext steps:")
    print("1. Update pubspec.yaml to use:")
    print("     - assets/exercises_flat/")
    print("     - assets/exercises_images/")
    print("2. Update LoadExercisesService to load from exercises_flat/")
    print("3. Test thoroughly")
    print("\nNote: Original assets/exercises/ directory is preserved for maintenance")


if __name__ == "__main__":
    flatten_exercises()