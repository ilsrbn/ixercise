import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ixercise/design_system/ix_button.dart';
import 'package:ixercise/design_system/tokens.dart';
import 'package:ixercise/domain/models.dart';
import 'package:ixercise/domain/training_set_expander.dart';
import 'package:ixercise/features/home/home_controller.dart';
import 'package:ixercise/features/onboarding/exercise_catalog.dart';
import 'package:ixercise/features/onboarding/onboarding_controller.dart';
import 'package:ixercise/features/onboarding/exercise_group_icon.dart';

class OnboardingTrainingSetupScreen extends ConsumerStatefulWidget {
  const OnboardingTrainingSetupScreen({
    super.key,
    this.initialPlan,
    this.initialSchedule,
    this.onBack,
    this.onSaved,
  });

  final TrainingPlan? initialPlan;
  final Map<String, dynamic>? initialSchedule;
  final VoidCallback? onBack;
  final VoidCallback? onSaved;

  @override
  ConsumerState<OnboardingTrainingSetupScreen> createState() =>
      _OnboardingTrainingSetupScreenState();
}

class _OnboardingTrainingSetupScreenState
    extends ConsumerState<OnboardingTrainingSetupScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'My First Training',
  );
  final List<_SetupItem> _items = <_SetupItem>[];
  _ScheduleType _scheduleType = _ScheduleType.none;
  Set<int> _weekdays = <int>{1, 3, 5};
  String _scheduleTime = '07:30';
  bool _seededFromSelection = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPlan != null) {
      _nameController.text = widget.initialPlan!.name;
      _items
        ..clear()
        ..addAll(_compressPlan(widget.initialPlan!));
    }
    if (widget.initialSchedule != null) {
      final String type = widget.initialSchedule!['type'] as String? ?? 'none';
      if (type == 'weekdays') {
        _scheduleType = _ScheduleType.weekdays;
        _weekdays =
            (widget.initialSchedule!['weekdays'] as List<dynamic>? ??
                    <dynamic>[])
                .whereType<int>()
                .toSet();
      } else if (type == 'alternating') {
        _scheduleType = _ScheduleType.alternating;
      }
      _scheduleTime =
          widget.initialSchedule!['time'] as String? ?? _scheduleTime;
    }
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canSave {
    final bool scheduleValid =
        _scheduleType != _ScheduleType.weekdays || _weekdays.isNotEmpty;
    return _nameController.text.trim().isNotEmpty &&
        _items.isNotEmpty &&
        _items.every(
          (item) => item.exerciseId.trim().isNotEmpty && item.value > 0,
        ) &&
        scheduleValid;
  }

  @override
  Widget build(BuildContext context) {
    final OnboardingState onboarding = ref.watch(onboardingControllerProvider);
    final List<_ExerciseOpt> allExercises = onboarding.exercises
        .map((_e) => _ExerciseOpt(_e.id, _e.name))
        .toList(growable: false);
    if (!_seededFromSelection && _items.isEmpty && allExercises.isNotEmpty) {
      _seededFromSelection = true;
      _items
        ..clear()
        ..addAll(<_SetupItem>[
          _SetupItem(
            exerciseId: allExercises.first.id,
            mode: ExerciseMode.reps,
            value: 10,
            sets: 3,
            restSeconds: 20,
          ),
        ]);
    }

    return Scaffold(
      backgroundColor: IxColors.bg,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
              children: <Widget>[
                const Text(
                  'STEP 2 OF 2',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    color: Color(0xFF9A9A9A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Set up your\ntraining flow.',
                  style: TextStyle(
                    fontSize: 42,
                    letterSpacing: -1.2,
                    height: 1.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0A0A0A),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Order exercises, choose reps or timer, and set rest between items.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6B6B6B),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  key: const Key('training_name_input'),
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Training name',
                    hintStyle: const TextStyle(color: Color(0xFF9A9A9A)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: IxColors.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: IxColors.line),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _ScheduleCard(
                  scheduleType: _scheduleType,
                  weekdays: _weekdays,
                  time: _scheduleTime,
                  onTypeChanged: (_ScheduleType type) =>
                      setState(() => _scheduleType = type),
                  onToggleWeekday: (int day) {
                    setState(() {
                      if (_weekdays.contains(day)) {
                        _weekdays.remove(day);
                      } else {
                        _weekdays.add(day);
                      }
                    });
                  },
                  onPickTime: () async {
                    final String? picked = await _pickClock(
                      context,
                      _scheduleTime,
                      'Schedule time',
                    );
                    if (picked != null) {
                      setState(() => _scheduleTime = picked);
                    }
                  },
                ),
                const SizedBox(height: 14),
                ...List<Widget>.generate(_items.length, (int index) {
                  final List<_ExerciseOpt> available = allExercises;
                  return _ExerciseCard(
                    title: _nameForId(onboarding, _items[index].exerciseId),
                    item: _items[index],
                    onChanged: (_SetupItem next) =>
                        setState(() => _items[index] = next),
                    onPickExercise: () async {
                      final String? picked = await _pickExercise(
                        context,
                        available,
                        _items[index].exerciseId,
                      );
                      if (picked != null) {
                        setState(
                          () => _items[index] = _items[index].copyWith(
                            exerciseId: picked,
                          ),
                        );
                      }
                    },
                    onPickWorkDuration: _items[index].mode == ExerciseMode.time
                        ? () async {
                            final int? picked = await _pickDuration(
                              context,
                              _items[index].value,
                              'Work duration',
                            );
                            if (picked != null && picked > 0) {
                              setState(
                                () => _items[index] = _items[index].copyWith(
                                  value: picked,
                                ),
                              );
                            }
                          }
                        : null,
                    onPickRestDuration: () async {
                      final int? picked = await _pickDuration(
                        context,
                        _items[index].restSeconds,
                        'Rest duration',
                      );
                      if (picked != null && picked >= 0) {
                        setState(
                          () => _items[index] = _items[index].copyWith(
                            restSeconds: picked,
                          ),
                        );
                      }
                    },
                    onSetCountChanged: (int sets) {
                      setState(
                        () =>
                            _items[index] = _items[index].copyWith(sets: sets),
                      );
                    },
                    onRemove: _items.length > 1
                        ? () => setState(() => _items.removeAt(index))
                        : null,
                  );
                }),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  key: const Key('training_add_exercise'),
                  onPressed: allExercises.isEmpty
                      ? null
                      : () {
                          setState(
                            () => _items.add(
                              _SetupItem(
                                exerciseId: allExercises.first.id,
                                mode: ExerciseMode.reps,
                                value: 10,
                                sets: 3,
                                restSeconds: 20,
                              ),
                            ),
                          );
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: IxColors.ink,
                    side: const BorderSide(color: IxColors.line),
                    shape: const StadiumBorder(),
                    minimumSize: const Size.fromHeight(52),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add exercise'),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Color(0x00FAFAFA), Color(0xFFFAFAFA)],
                    stops: <double>[0, 0.35],
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: IxButton.ghost(
                        label: 'Back',
                        onPressed: widget.onBack,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: IxButton.primary(
                        key: const Key('training_save_button'),
                        label: 'Save',
                        onPressed: _canSave ? _save : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _pickExercise(
    BuildContext context,
    List<_ExerciseOpt> available,
    String selectedId,
  ) {
    String query = '';
    String group = 'All';
    String groupFor(_ExerciseOpt e) => groupForExerciseName(e.name);
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final List<_ExerciseOpt> filtered = available
                .where((e) => group == 'All' || groupFor(e) == group)
                .where(
                  (e) => query.isEmpty || e.name.toLowerCase().contains(query),
                )
                .toList(growable: false);
            final List<String> groups = <String>{
              'All',
              ...available.map(groupFor),
            }.toList(growable: false);
            return Container(
              height: MediaQuery.of(context).size.height * 0.86,
              decoration: const BoxDecoration(
                color: IxColors.bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 10),
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCDCDCD),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Pick exercise',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TextField(
                      onChanged: (v) =>
                          setModalState(() => query = v.trim().toLowerCase()),
                      decoration: InputDecoration(
                        hintText: 'Search exercises',
                        hintStyle: const TextStyle(color: Color(0xFF9A9A9A)),
                        prefixIcon: const Icon(Icons.search, size: 18),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: IxColors.line),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: IxColors.line),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      scrollDirection: Axis.horizontal,
                      itemCount: groups.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (BuildContext context, int index) {
                        final String g = groups[index];
                        final bool active = g == group;
                        return OutlinedButton(
                          onPressed: () => setModalState(() => group = g),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: active
                                ? IxColors.ink
                                : Colors.transparent,
                            foregroundColor: active
                                ? Colors.white
                                : IxColors.ink,
                            side: BorderSide(
                              color: active ? IxColors.ink : IxColors.line,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          child: Text(g),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
                      itemCount: filtered.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.05,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemBuilder: (BuildContext context, int index) {
                        final _ExerciseOpt e = filtered[index];
                        final bool active = e.id == selectedId;
                        final String exerciseGroup = groupFor(e);
                        return InkWell(
                          onTap: () => Navigator.of(context).pop(e.id),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: active
                                  ? const Color(0xFF0A0A0A)
                                  : Colors.white,
                              border: Border.all(
                                color: active
                                    ? const Color(0xFF0A0A0A)
                                    : const Color(0xFFE8E8E8),
                              ),
                            ),
                            child: Stack(
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    ExerciseGroupIcon(
                                      group: exerciseGroup,
                                      size: 36,
                                      color: active
                                          ? Colors.white
                                          : const Color(0xFF0A0A0A),
                                    ),
                                    const Spacer(),
                                    Text(
                                      e.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: active
                                            ? Colors.white
                                            : const Color(0xFF0A0A0A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      exerciseGroup.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: active
                                            ? Colors.white.withOpacity(0.55)
                                            : const Color(0xFF9A9A9A),
                                      ),
                                    ),
                                  ],
                                ),
                                if (active)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: const BoxDecoration(
                                        color: IxColors.accent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<int?> _pickDuration(
    BuildContext context,
    int initialSeconds,
    String title,
  ) {
    int minutes = initialSeconds ~/ 60;
    int seconds = initialSeconds % 60;
    final FixedExtentScrollController minuteController =
        FixedExtentScrollController(initialItem: minutes.clamp(0, 59).toInt());
    final FixedExtentScrollController secondController =
        FixedExtentScrollController(initialItem: seconds.clamp(0, 59).toInt());

    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: 320,
              decoration: const BoxDecoration(
                color: IxColors.bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 10),
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCDCDCD),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 36,
                            scrollController: minuteController,
                            onSelectedItemChanged: (int value) {
                              setModalState(() => minutes = value);
                            },
                            children: List<Widget>.generate(
                              60,
                              (int i) => Center(
                                child: Text(
                                  '${i.toString().padLeft(2, '0')} m',
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 36,
                            scrollController: secondController,
                            onSelectedItemChanged: (int value) {
                              setModalState(() => seconds = value);
                            },
                            children: List<Widget>.generate(
                              60,
                              (int i) => Center(
                                child: Text(
                                  '${i.toString().padLeft(2, '0')} s',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                    child: SizedBox(
                      width: double.infinity,
                      child: IxButton.primary(
                        label: 'Apply',
                        onPressed: () =>
                            Navigator.of(context).pop((minutes * 60) + seconds),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<String?> _pickClock(
    BuildContext context,
    String initial,
    String title,
  ) {
    final List<String> parts = initial.split(':');
    int hour = int.tryParse(parts.first) ?? 7;
    int minute = int.tryParse(parts.length > 1 ? parts[1] : '30') ?? 30;
    final FixedExtentScrollController hourController =
        FixedExtentScrollController(initialItem: hour.clamp(0, 23).toInt());
    final FixedExtentScrollController minuteController =
        FixedExtentScrollController(initialItem: minute.clamp(0, 59).toInt());

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: 320,
              decoration: const BoxDecoration(
                color: IxColors.bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 10),
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCDCDCD),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 36,
                            scrollController: hourController,
                            onSelectedItemChanged: (int value) =>
                                setModalState(() => hour = value),
                            children: List<Widget>.generate(
                              24,
                              (int i) => Center(
                                child: Text(
                                  '${i.toString().padLeft(2, '0')} h',
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 36,
                            scrollController: minuteController,
                            onSelectedItemChanged: (int value) =>
                                setModalState(() => minute = value),
                            children: List<Widget>.generate(
                              60,
                              (int i) => Center(
                                child: Text(
                                  '${i.toString().padLeft(2, '0')} m',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                    child: SizedBox(
                      width: double.infinity,
                      child: IxButton.primary(
                        label: 'Apply',
                        onPressed: () => Navigator.of(context).pop(
                          '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _nameForId(OnboardingState onboarding, String id) {
    for (final ExerciseOption item in onboarding.exercises) {
      if (item.id == id) {
        return item.name;
      }
    }
    return id;
  }

  String _findIdByName(OnboardingState onboarding, String name) {
    for (final ExerciseOption item in onboarding.exercises) {
      if (item.name == name) {
        return item.id;
      }
    }
    return name;
  }

  List<_SetupItem> _compressPlan(TrainingPlan plan) {
    final OnboardingState onboarding = ref.read(onboardingControllerProvider);
    final List<_SetupItem> out = <_SetupItem>[];
    for (final TrainingExercise item in plan.items) {
      final int existingIndex = out.indexWhere((_SetupItem setup) {
        final String setupName = _nameForId(onboarding, setup.exerciseId);
        return setupName == item.exerciseId &&
            setup.mode == item.mode &&
            setup.value == item.value &&
            setup.restSeconds == item.restSeconds;
      });
      if (existingIndex >= 0) {
        final _SetupItem existing = out[existingIndex];
        out[existingIndex] = existing.copyWith(sets: existing.sets + 1);
        continue;
      }
      out.add(
        _SetupItem(
          exerciseId: _findIdByName(onboarding, item.exerciseId),
          mode: item.mode,
          value: item.value,
          sets: 1,
          restSeconds: item.restSeconds,
        ),
      );
    }
    return out;
  }

  Future<void> _save() async {
    final List<TrainingExercise> sequence = _items
        .map(
          (_SetupItem item) => TrainingExercise(
            exerciseId: _nameForId(
              ref.read(onboardingControllerProvider),
              item.exerciseId,
            ),
            mode: item.mode,
            value: item.value,
            restSeconds: item.restSeconds,
          ),
        )
        .toList(growable: false);
    final List<TrainingExercise> expandedBySets = interleaveTrainingSets(
      sequence: sequence,
      setCounts: _items
          .map((_SetupItem item) => item.sets)
          .toList(growable: false),
    );
    Map<String, dynamic>? schedule;
    if (_scheduleType == _ScheduleType.weekdays) {
      schedule = <String, dynamic>{
        'type': 'weekdays',
        'weekdays': _weekdays.toList()..sort(),
        'time': _scheduleTime,
      };
    } else if (_scheduleType == _ScheduleType.alternating) {
      schedule = <String, dynamic>{
        'type': 'alternating',
        'time': _scheduleTime,
      };
    }
    if (widget.initialPlan == null) {
      await ref
          .read(homeControllerProvider.notifier)
          .createTrainingFromSequence(
            name: _nameController.text.trim(),
            sequence: expandedBySets,
            schedule: schedule,
          );
    } else {
      await ref
          .read(homeControllerProvider.notifier)
          .updateTrainingFromSequence(
            planId: widget.initialPlan!.id,
            name: _nameController.text.trim(),
            sequence: expandedBySets,
            schedule: schedule,
          );
    }
    widget.onSaved?.call();
  }
}

enum _ScheduleType { none, weekdays, alternating }

class _ExerciseOpt {
  const _ExerciseOpt(this.id, this.name);
  final String id;
  final String name;
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.scheduleType,
    required this.weekdays,
    required this.time,
    required this.onTypeChanged,
    required this.onToggleWeekday,
    required this.onPickTime,
  });

  final _ScheduleType scheduleType;
  final Set<int> weekdays;
  final String time;
  final ValueChanged<_ScheduleType> onTypeChanged;
  final ValueChanged<int> onToggleWeekday;
  final VoidCallback onPickTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Schedule', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _SchedulePill(
                label: 'None',
                active: scheduleType == _ScheduleType.none,
                onTap: () => onTypeChanged(_ScheduleType.none),
              ),
              _SchedulePill(
                label: 'Weekdays',
                active: scheduleType == _ScheduleType.weekdays,
                onTap: () => onTypeChanged(_ScheduleType.weekdays),
              ),
              _SchedulePill(
                label: 'Alternating',
                active: scheduleType == _ScheduleType.alternating,
                onTap: () => onTypeChanged(_ScheduleType.alternating),
              ),
            ],
          ),
          if (scheduleType == _ScheduleType.weekdays) ...<Widget>[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: <Widget>[
                _WeekdayChip(
                  day: 1,
                  label: 'Mon',
                  active: weekdays.contains(1),
                  onTap: onToggleWeekday,
                ),
                _WeekdayChip(
                  day: 2,
                  label: 'Tue',
                  active: weekdays.contains(2),
                  onTap: onToggleWeekday,
                ),
                _WeekdayChip(
                  day: 3,
                  label: 'Wed',
                  active: weekdays.contains(3),
                  onTap: onToggleWeekday,
                ),
                _WeekdayChip(
                  day: 4,
                  label: 'Thu',
                  active: weekdays.contains(4),
                  onTap: onToggleWeekday,
                ),
                _WeekdayChip(
                  day: 5,
                  label: 'Fri',
                  active: weekdays.contains(5),
                  onTap: onToggleWeekday,
                ),
                _WeekdayChip(
                  day: 6,
                  label: 'Sat',
                  active: weekdays.contains(6),
                  onTap: onToggleWeekday,
                ),
                _WeekdayChip(
                  day: 7,
                  label: 'Sun',
                  active: weekdays.contains(7),
                  onTap: onToggleWeekday,
                ),
              ],
            ),
          ],
          if (scheduleType != _ScheduleType.none) ...<Widget>[
            const SizedBox(height: 10),
            InkWell(
              onTap: onPickTime,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                ),
                child: Row(
                  children: <Widget>[
                    const Text('Time', style: TextStyle(color: IxColors.mute)),
                    const Spacer(),
                    Text(
                      time,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.unfold_more, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SchedulePill extends StatelessWidget {
  const _SchedulePill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: active ? IxColors.ink : Colors.white,
          border: Border.all(color: active ? IxColors.ink : IxColors.line),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : IxColors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _WeekdayChip extends StatelessWidget {
  const _WeekdayChip({
    required this.day,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final int day;
  final String label;
  final bool active;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(day),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: active ? const Color(0xFFE11D2E) : Colors.white,
          border: Border.all(
            color: active ? const Color(0xFFE11D2E) : const Color(0xFFE8E8E8),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : IxColors.ink,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.title,
    required this.item,
    required this.onChanged,
    required this.onPickExercise,
    required this.onPickRestDuration,
    required this.onSetCountChanged,
    this.onPickWorkDuration,
    this.onRemove,
  });

  final String title;
  final _SetupItem item;
  final ValueChanged<_SetupItem> onChanged;
  final VoidCallback onPickExercise;
  final VoidCallback onPickRestDuration;
  final ValueChanged<int> onSetCountChanged;
  final VoidCallback? onPickWorkDuration;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: 'Change exercise',
                onPressed: onPickExercise,
                icon: const Icon(Icons.swap_horiz_rounded, size: 20),
              ),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close, size: 18),
                ),
            ],
          ),
          const SizedBox(height: 4),
          _StepperPill(
            label: 'Sets',
            value: item.sets,
            min: 1,
            onChanged: onSetCountChanged,
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _ModePill(
                  label: 'Reps',
                  active: item.mode == ExerciseMode.reps,
                  onTap: () =>
                      onChanged(item.copyWith(mode: ExerciseMode.reps)),
                ),
                _ModePill(
                  label: 'Timer',
                  active: item.mode == ExerciseMode.time,
                  onTap: () =>
                      onChanged(item.copyWith(mode: ExerciseMode.time)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: item.mode == ExerciseMode.time
                    ? _DurationChip(
                        label: 'Work',
                        seconds: item.value,
                        onTap: onPickWorkDuration!,
                      )
                    : _StepperPill(
                        label: 'Reps',
                        value: item.value,
                        min: 1,
                        onChanged: (int value) =>
                            onChanged(item.copyWith(value: value)),
                      ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DurationChip(
                  label: 'Rest',
                  seconds: item.restSeconds,
                  onTap: onPickRestDuration,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: active ? IxColors.ink : Colors.white,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : IxColors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.label,
    required this.seconds,
    required this.onTap,
  });

  final String label;
  final int seconds;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final int m = seconds ~/ 60;
    final int s = seconds % 60;
    final String text =
        '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: IxColors.mute),
                  ),
                ],
              ),
            ),
            const Icon(Icons.unfold_more, size: 16),
          ],
        ),
      ),
    );
  }
}

class _StepperPill extends StatelessWidget {
  const _StepperPill({
    required this.label,
    required this.value,
    required this.min,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Row(
        children: <Widget>[
          _MiniAdjust(
            label: '−',
            onTap: value > min ? () => onChanged(value - 1) : null,
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Text(
                  '$value',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B6B6B),
                  ),
                ),
              ],
            ),
          ),
          _MiniAdjust(label: '+', onTap: () => onChanged(value + 1)),
        ],
      ),
    );
  }
}

class _MiniAdjust extends StatelessWidget {
  const _MiniAdjust({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: onTap == null
              ? const Color(0xFFF0F0F0)
              : const Color(0xFFF7F7F7),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: onTap == null
                ? const Color(0xFFB0B0B0)
                : const Color(0xFF0A0A0A),
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _SetupItem {
  const _SetupItem({
    required this.exerciseId,
    required this.mode,
    required this.value,
    required this.sets,
    required this.restSeconds,
  });

  final String exerciseId;
  final ExerciseMode mode;
  final int value;
  final int sets;
  final int restSeconds;

  _SetupItem copyWith({
    String? exerciseId,
    ExerciseMode? mode,
    int? value,
    int? sets,
    int? restSeconds,
  }) {
    return _SetupItem(
      exerciseId: exerciseId ?? this.exerciseId,
      mode: mode ?? this.mode,
      value: value ?? this.value,
      sets: sets ?? this.sets,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }
}
