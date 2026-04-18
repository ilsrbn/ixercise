import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ixercise/domain/models.dart';

class HomeState {
  const HomeState({
    required this.plans,
  });

  final List<TrainingPlan> plans;
}

class HomeController extends StateNotifier<HomeState> {
  HomeController()
      : super(
          HomeState(
            plans: const <TrainingPlan>[
              TrainingPlan(
                id: 'morning-full-body',
                name: 'Morning Full Body',
                items: <TrainingExercise>[
                  TrainingExercise(
                    exerciseId: 'Jumping jacks',
                    mode: ExerciseMode.time,
                    value: 45,
                    restSeconds: 15,
                  ),
                  TrainingExercise(
                    exerciseId: 'Push-ups',
                    mode: ExerciseMode.reps,
                    value: 12,
                    restSeconds: 30,
                  ),
                  TrainingExercise(
                    exerciseId: 'Bodyweight squats',
                    mode: ExerciseMode.reps,
                    value: 20,
                    restSeconds: 30,
                  ),
                  TrainingExercise(
                    exerciseId: 'Plank',
                    mode: ExerciseMode.time,
                    value: 60,
                    restSeconds: 30,
                  ),
                  TrainingExercise(
                    exerciseId: 'Lunges',
                    mode: ExerciseMode.reps,
                    value: 16,
                    restSeconds: 30,
                  ),
                  TrainingExercise(
                    exerciseId: 'Mountain climbers',
                    mode: ExerciseMode.time,
                    value: 40,
                    restSeconds: 30,
                  ),
                  TrainingExercise(
                    exerciseId: 'Biceps curls',
                    mode: ExerciseMode.reps,
                    value: 15,
                    restSeconds: 30,
                  ),
                  TrainingExercise(
                    exerciseId: 'Crunches',
                    mode: ExerciseMode.reps,
                    value: 20,
                    restSeconds: 0,
                  ),
                ],
              ),
              TrainingPlan(
                id: 'core-express',
                name: 'Core Express',
                items: <TrainingExercise>[
                  TrainingExercise(
                    exerciseId: 'Plank',
                    mode: ExerciseMode.time,
                    value: 45,
                    restSeconds: 15,
                  ),
                  TrainingExercise(
                    exerciseId: 'Bicycle crunches',
                    mode: ExerciseMode.reps,
                    value: 20,
                    restSeconds: 15,
                  ),
                  TrainingExercise(
                    exerciseId: 'Leg raises',
                    mode: ExerciseMode.reps,
                    value: 12,
                    restSeconds: 15,
                  ),
                  TrainingExercise(
                    exerciseId: 'Russian twists',
                    mode: ExerciseMode.reps,
                    value: 20,
                    restSeconds: 15,
                  ),
                  TrainingExercise(
                    exerciseId: 'Hollow body hold',
                    mode: ExerciseMode.time,
                    value: 30,
                    restSeconds: 0,
                  ),
                ],
              ),
            ],
          ),
        );
}

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>(
  (ref) => HomeController(),
);
