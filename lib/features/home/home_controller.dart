import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ixercise/data/repositories.dart';
import 'package:ixercise/domain/models.dart';
import 'package:ixercise/domain/training_plan_builder.dart';

class HomeState {
  const HomeState({
    required this.plans,
    required this.availableExerciseIds,
    required this.schedulesByPlanId,
    this.isLoading = true,
  });

  final List<TrainingPlan> plans;
  final List<String> availableExerciseIds;
  final Map<String, Map<String, dynamic>> schedulesByPlanId;
  final bool isLoading;

  HomeState copyWith({
    List<TrainingPlan>? plans,
    List<String>? availableExerciseIds,
    Map<String, Map<String, dynamic>>? schedulesByPlanId,
    bool? isLoading,
  }) {
    return HomeState(
      plans: plans ?? this.plans,
      availableExerciseIds: availableExerciseIds ?? this.availableExerciseIds,
      schedulesByPlanId: schedulesByPlanId ?? this.schedulesByPlanId,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HomeController extends StateNotifier<HomeState> {
  HomeController(
    this._planRepository,
    this._selectionRepository,
    this._scheduleRepository,
  ) : super(
        const HomeState(
          plans: <TrainingPlan>[],
          availableExerciseIds: <String>[],
          schedulesByPlanId: <String, Map<String, dynamic>>{},
        ),
      ) {
    hydrate();
  }

  final TrainingPlanRepository _planRepository;
  final ExerciseSelectionRepository _selectionRepository;
  final ScheduleRepository _scheduleRepository;

  Future<void> hydrate() async {
    final List<TrainingPlan> plans = await _planRepository.load();
    final List<String> selected = (await _selectionRepository.load()).toList(
      growable: false,
    );
    final List<Map<String, dynamic>> scheduleList = await _scheduleRepository
        .load();
    final Map<String, Map<String, dynamic>> schedulesByPlanId =
        <String, Map<String, dynamic>>{};
    for (final Map<String, dynamic> item in scheduleList) {
      final String planId = item['planId'] as String? ?? '';
      if (planId.isNotEmpty) {
        schedulesByPlanId[planId] = item;
      }
    }
    state = state.copyWith(
      plans: plans,
      availableExerciseIds: selected,
      schedulesByPlanId: schedulesByPlanId,
      isLoading: false,
    );
  }

  Future<void> ensureFirstPlanForSelection(Set<String> selectedIds) async {
    if (selectedIds.isEmpty) {
      return;
    }

    await _selectionRepository.save(selectedIds);
    final List<TrainingPlan> existing = await _planRepository.load();
    if (existing.isNotEmpty) {
      state = state.copyWith(
        plans: existing,
        availableExerciseIds: selectedIds.toList(growable: false),
      );
      return;
    }

    final TrainingPlan firstPlan = buildPlanFromExerciseIds(
      id: 'plan-${DateTime.now().millisecondsSinceEpoch}',
      name: 'My First Training',
      exerciseIds: selectedIds.take(6).toList(growable: false),
    );
    final List<TrainingPlan> plans = <TrainingPlan>[firstPlan];
    await _planRepository.save(plans);
    state = state.copyWith(
      plans: plans,
      availableExerciseIds: selectedIds.toList(growable: false),
    );
  }

  Future<void> createTraining({
    required String name,
    List<String>? exerciseIds,
  }) async {
    final List<String> source = (exerciseIds ?? state.availableExerciseIds)
        .where((String item) => item.trim().isNotEmpty)
        .toList(growable: false);
    if (source.isEmpty) {
      return;
    }
    final List<TrainingPlan> next = <TrainingPlan>[
      ...state.plans,
      buildPlanFromExerciseIds(
        id: 'plan-${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim().isEmpty ? 'Custom Training' : name.trim(),
        exerciseIds: source.take(8).toList(growable: false),
      ),
    ];
    await _planRepository.save(next);
    state = state.copyWith(plans: next);
  }

  Future<void> createTrainingFromSequence({
    required String name,
    required List<TrainingExercise> sequence,
    Map<String, dynamic>? schedule,
  }) async {
    if (sequence.isEmpty) {
      return;
    }
    final TrainingPlan plan = TrainingPlan(
      id: 'plan-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Custom Training' : name.trim(),
      items: sequence,
    );
    final List<TrainingPlan> next = <TrainingPlan>[...state.plans, plan];
    await _planRepository.save(next);
    Map<String, Map<String, dynamic>> nextSchedules = state.schedulesByPlanId;
    if (schedule != null) {
      nextSchedules = <String, Map<String, dynamic>>{
        ...state.schedulesByPlanId,
        plan.id: <String, dynamic>{...schedule, 'planId': plan.id},
      };
      await _scheduleRepository.save(
        nextSchedules.values.toList(growable: false),
      );
    }
    state = state.copyWith(plans: next, schedulesByPlanId: nextSchedules);
  }

  Future<void> updateTrainingFromSequence({
    required String planId,
    required String name,
    required List<TrainingExercise> sequence,
    Map<String, dynamic>? schedule,
  }) async {
    if (sequence.isEmpty) {
      return;
    }
    final int index = state.plans.indexWhere(
      (TrainingPlan p) => p.id == planId,
    );
    if (index < 0) {
      return;
    }
    final TrainingPlan updated = TrainingPlan(
      id: planId,
      name: name.trim().isEmpty ? state.plans[index].name : name.trim(),
      items: sequence,
    );
    final List<TrainingPlan> nextPlans = <TrainingPlan>[...state.plans];
    nextPlans[index] = updated;
    await _planRepository.save(nextPlans);

    final Map<String, Map<String, dynamic>> nextSchedules =
        <String, Map<String, dynamic>>{...state.schedulesByPlanId};
    if (schedule == null) {
      nextSchedules.remove(planId);
    } else {
      nextSchedules[planId] = <String, dynamic>{...schedule, 'planId': planId};
    }
    await _scheduleRepository.save(
      nextSchedules.values.toList(growable: false),
    );
    state = state.copyWith(plans: nextPlans, schedulesByPlanId: nextSchedules);
  }

  Future<void> deleteTraining(String planId) async {
    final List<TrainingPlan> nextPlans = state.plans
        .where((TrainingPlan p) => p.id != planId)
        .toList(growable: false);
    await _planRepository.save(nextPlans);
    final Map<String, Map<String, dynamic>> nextSchedules =
        <String, Map<String, dynamic>>{...state.schedulesByPlanId}
          ..remove(planId);
    await _scheduleRepository.save(
      nextSchedules.values.toList(growable: false),
    );
    state = state.copyWith(plans: nextPlans, schedulesByPlanId: nextSchedules);
  }
}

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>(
  (ref) => HomeController(
    ref.watch(trainingPlanRepositoryProvider),
    ref.watch(exerciseSelectionRepositoryProvider),
    ref.watch(scheduleRepositoryProvider),
  ),
);
