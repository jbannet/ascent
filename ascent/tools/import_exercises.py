#!/usr/bin/env python3
"""
Validate incoming exercises and write each valid entry to
/ascent/assets/exercises/<sanitized-name>/exercise.json.

Usage:
    python scripts/import_exercises.py path/to/exercises.json
"""

from __future__ import annotations

import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable, List, Mapping, Sequence

ALLOWED_DIR_CHARS = set(
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_'(),-"
)

ROOT = Path(__file__).resolve().parents[1]
EXERCISE_ROOT = ROOT / "ascent" / "assets" / "exercises"

FORCE_VALUES = {"pull", "push", "static", None}
LEVEL_VALUES = {"beginner", "intermediate", "expert"}
MECHANIC_VALUES = {"compound", "isolation", None}
EQUIPMENT_VALUES = {
    "body only",
    "machine",
    "kettlebells",
    "dumbbell",
    "cable",
    "barbell",
    "bands",
    "medicine ball",
    "exercise ball",
    "e-z curl bar",
    "foam roll",
    None,
}
MUSCLE_VALUES = {
    "abdominals",
    "hamstrings",
    "calves",
    "shoulders",
    "adductors",
    "glutes",
    "quadriceps",
    "biceps",
    "forearms",
    "abductors",
    "triceps",
    "chest",
    "lower back",
    "traps",
    "middle back",
    "lats",
    "neck",
}
CATEGORY_VALUES = {
    "strength",
    "cardio",
    "stretching",
    "plyometrics",
    "strongman",
    "powerlifting",
    "olympic weightlifting",
}
PATTERN_VALUES = {
    "squat",
    "hinge",
    "lunge",
    "horizontalPush",
    "verticalPush",
    "horizontalPull",
    "verticalPull",
    "antiExtension",
    "antiRotation",
    "antiLateralFlexion",
    "rotation",
    "carry",
    "throw",
    "jump",
    "crawl",
    "steadyStateCardio",
    "staticStretch",
    "dynamicStretch",
    "mobilityDrill",
    "functional_movement",
}
STYLE_VALUES = {
    "full_body",
    "upper_lower_split",
    "push_pull_legs",
    "concurrent_hybrid",
    "circuit_metabolic",
    "endurance_dominant",
    "strongman_functional",
    "crossfit_mixed",
    "functional_movement",
    "yoga_focused",
    "senior_specific",
    "pilates_style",
    "athletic_conditioning",
}


@dataclass
class ValidationError:
    index: int
    name: str | None
    messages: List[str]

    def to_dict(self) -> Mapping[str, Any]:
        return {
            "index": self.index,
            "name": self.name,
            "errors": self.messages,
        }


def slugify(value: str) -> str:
    """Return a filesystem-safe directory name."""
    value = value.strip()
    value = re.sub(r"\s+", "_", value)
    sanitized = "".join(ch for ch in value if ch in ALLOWED_DIR_CHARS)
    sanitized = sanitized.strip("_")
    return sanitized or "exercise"


def expect_string(value: Any, field: str, messages: List[str]) -> str | None:
    if not isinstance(value, str):
        messages.append(f"{field}: expected string, got {type(value).__name__}")
        return None
    if not value.strip():
        messages.append(f"{field}: must not be empty")
    return value


def expect_string_list(values: Any, field: str, messages: List[str]) -> List[str]:
    if not isinstance(values, Sequence) or isinstance(values, (str, bytes)):
        messages.append(f"{field}: expected list of strings")
        return []
    bad_types = [v for v in values if not isinstance(v, str)]
    if bad_types:
        messages.append(f"{field}: all items must be strings")
    return [v for v in values if isinstance(v, str)]


def expect_enum(value: Any, field: str, allowed: Iterable[str | None], messages: List[str]) -> None:
    if value not in allowed:
        allowed_list = ", ".join(repr(v) for v in allowed)
        messages.append(f"{field}: invalid value {value!r}; allowed: {allowed_list}")


def validate_exercise(exercise: Mapping[str, Any]) -> List[str]:
    messages: List[str] = []

    # Required string
    expect_string(exercise.get("name"), "name", messages)

    # Enumerated strings / nullable fields
    expect_enum(exercise.get("force"), "force", FORCE_VALUES, messages)
    expect_enum(exercise.get("level"), "level", LEVEL_VALUES, messages)
    expect_enum(exercise.get("mechanic"), "mechanic", MECHANIC_VALUES, messages)
    expect_enum(exercise.get("equipment"), "equipment", EQUIPMENT_VALUES, messages)
    expect_enum(exercise.get("category"), "category", CATEGORY_VALUES, messages)

    # Arrays
    primary = expect_string_list(exercise.get("primaryMuscles"), "primaryMuscles", messages)
    secondary = expect_string_list(exercise.get("secondaryMuscles"), "secondaryMuscles", messages)
    instructions = expect_string_list(exercise.get("instructions"), "instructions", messages)
    patterns = expect_string_list(exercise.get("movementPatterns"), "movementPatterns", messages)
    styles = expect_string_list(exercise.get("workoutStyles"), "workoutStyles", messages)

    if not primary:
        messages.append("primaryMuscles: must contain at least one muscle")
    if not instructions:
        messages.append("instructions: must contain at least one step")

    invalid_primary = [m for m in primary if m not in MUSCLE_VALUES]
    if invalid_primary:
        messages.append(f"primaryMuscles: invalid values {invalid_primary}")

    invalid_secondary = [m for m in secondary if m not in MUSCLE_VALUES]
    if invalid_secondary:
        messages.append(f"secondaryMuscles: invalid values {invalid_secondary}")

    invalid_patterns = [p for p in patterns if p not in PATTERN_VALUES]
    if invalid_patterns:
        messages.append(f"movementPatterns: invalid values {invalid_patterns}")

    invalid_styles = [s for s in styles if s not in STYLE_VALUES]
    if invalid_styles:
        messages.append(f"workoutStyles: invalid values {invalid_styles}")

    return messages


def write_exercise(exercise: Mapping[str, Any]) -> Path:
    name = exercise["name"]
    directory_name = slugify(name)
    directory = EXERCISE_ROOT / directory_name
    directory.mkdir(parents=True, exist_ok=True)
    legacy_path = EXERCISE_ROOT / f"{directory_name}.json"
    if legacy_path.exists():
        # Align older exports that wrote files directly in the root directory.
        legacy_path.rename(directory / "exercise.json")

    filepath = directory / "exercise.json"
    with filepath.open("w", encoding="utf-8") as handle:
        json.dump(exercise, handle, indent=2, ensure_ascii=False)
        handle.write("\n")
    return filepath


def main(path: str) -> None:
    source_path = Path(path).resolve()
    if not source_path.is_file():
        raise FileNotFoundError(f"Input file not found: {source_path}")

    with source_path.open("r", encoding="utf-8") as handle:
        payload = json.load(handle)

    if not isinstance(payload, list):
        raise ValueError("Input file must contain a JSON array of exercise objects")

    invalid: List[ValidationError] = []
    created = 0

    for index, raw in enumerate(payload):
        if not isinstance(raw, Mapping):
            invalid.append(
                ValidationError(index=index, name=None, messages=["Entry is not a JSON object"])
            )
            continue

        errors = validate_exercise(raw)
        if errors:
            invalid.append(ValidationError(index=index, name=raw.get("name"), messages=errors))
            continue

        write_exercise(raw)
        created += 1

    print(f"Created {created} exercises in {EXERCISE_ROOT}")

    if invalid:
        invalid_path = ROOT / "invalid_exercises.json"
        with invalid_path.open("w", encoding="utf-8") as handle:
            json.dump([err.to_dict() for err in invalid], handle, indent=2)
            handle.write("\n")
        print(f"{len(invalid)} invalid entries written to {invalid_path}")
    else:
        print("All exercises were valid.")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python scripts/import_exercises.py path/to/exercises.json", file=sys.stderr)
        sys.exit(1)
    main(sys.argv[1])
