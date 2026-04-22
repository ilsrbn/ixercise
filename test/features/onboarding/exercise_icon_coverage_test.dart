import 'package:flutter_test/flutter_test.dart';
import 'package:ixercise/features/onboarding/exercise_catalog.dart';
import 'package:ixercise/features/onboarding/exercise_group_icon.dart';

void main() {
  const Set<String> supportedGroups = <String>{
    'Chest',
    'Back',
    'Legs',
    'Core',
    'Arms',
    'Cardio',
    'Shoulders',
    'Other',
  };

  test('every catalog exercise maps to a supported readable icon group', () {
    final exercises = buildExerciseCatalog();

    expect(exercises, isNotEmpty);
    for (final ExerciseSeed exercise in exercises) {
      expect(
        supportedGroups,
        contains(exercise.group),
        reason: '${exercise.name} has unsupported group ${exercise.group}',
      );
      expect(
        hasExerciseGroupIcon(exercise.group),
        isTrue,
        reason: '${exercise.name} has no icon for ${exercise.group}',
      );
    }
  });

  test('representative exercise names map to useful category icons', () {
    expect(groupForExerciseName('Push-ups'), 'Chest');
    expect(groupForExerciseName('Dumbbell rows'), 'Back');
    expect(groupForExerciseName('Bodyweight squats'), 'Legs');
    expect(groupForExerciseName('Plank shoulder taps'), 'Core');
    expect(groupForExerciseName('Biceps curls'), 'Arms');
    expect(groupForExerciseName('High knees'), 'Cardio');
    expect(groupForExerciseName('Dumbbell shoulder press'), 'Shoulders');
    expect(groupForExerciseName('Bent-over lateral raises'), 'Back');
    expect(groupForExerciseName('Reverse dumbbell flyes'), 'Back');
    expect(groupForExerciseName('Mountain climbers (fast)'), 'Cardio');
    expect(groupForExerciseName('Plank jacks'), 'Cardio');
  });
}
