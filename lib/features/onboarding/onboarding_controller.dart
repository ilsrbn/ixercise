import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ixercise/features/onboarding/exercise_catalog.dart';

class OnboardingState {
  const OnboardingState({
    required this.exercises,
    required this.selectedExerciseIds,
    this.query = '',
    this.group = 'All',
  });

  final List<ExerciseOption> exercises;
  final Set<String> selectedExerciseIds;
  final String query;
  final String group;

  List<ExerciseOption> get filteredExercises {
    final String q = query.trim().toLowerCase();
    return exercises
        .where((ExerciseOption e) => group == 'All' || e.group == group)
        .where((ExerciseOption e) => q.isEmpty || e.name.toLowerCase().contains(q))
        .toList(growable: false);
  }

  bool get canContinue => selectedExerciseIds.isNotEmpty;
  List<String> get groups => <String>{
        'All',
        ...exercises.map((ExerciseOption e) => e.group),
      }.toList(growable: false);

  OnboardingState copyWith({
    List<ExerciseOption>? exercises,
    Set<String>? selectedExerciseIds,
    String? query,
    String? group,
  }) {
    return OnboardingState(
      exercises: exercises ?? this.exercises,
      selectedExerciseIds: selectedExerciseIds ?? this.selectedExerciseIds,
      query: query ?? this.query,
      group: group ?? this.group,
    );
  }
}

class ExerciseOption {
  const ExerciseOption({
    required this.id,
    required this.name,
    required this.group,
  });

  final String id;
  final String name;
  final String group;
}

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController()
      : super(
          OnboardingState(
            exercises: buildExerciseCatalog()
                .map(
                  (ExerciseSeed seed) =>
                      ExerciseOption(id: seed.id, name: seed.name, group: seed.group),
                )
                .toList(growable: false),
            selectedExerciseIds: <String>{},
          ),
        );

  void setQuery(String value) {
    state = state.copyWith(query: value);
  }

  void setGroup(String value) {
    state = state.copyWith(group: value);
  }

  void toggleExercise(String exerciseId) {
    final Set<String> next = <String>{...state.selectedExerciseIds};
    if (next.contains(exerciseId)) {
      next.remove(exerciseId);
    } else {
      next.add(exerciseId);
    }
    state = state.copyWith(selectedExerciseIds: next);
  }
}

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>(
  (ref) => OnboardingController(),
);
