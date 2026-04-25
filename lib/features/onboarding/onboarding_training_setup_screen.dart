import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ixercise/design_system/ix_button.dart';
import 'package:ixercise/design_system/theme.dart';
import 'package:ixercise/domain/models.dart';
import 'package:ixercise/domain/training_set_expander.dart';
import 'package:ixercise/features/home/home_controller.dart';
import 'package:ixercise/features/onboarding/exercise_catalog.dart';
import 'package:ixercise/features/onboarding/onboarding_controller.dart';
import 'package:ixercise/features/onboarding/exercise_group_icon.dart';
import 'package:ixercise/features/settings/locale_controller.dart';
import 'package:ixercise/l10n/app_localizations.dart';

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
  _ScheduleType _scheduleType = _ScheduleType.off;
  Set<int> _weekdays = <int>{1, 3, 5};
  String _scheduleTime = '07:30';
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
        _scheduleType = _ScheduleType.custom;
        _weekdays =
            (widget.initialSchedule!['weekdays'] as List<dynamic>? ??
                    <dynamic>[])
                .whereType<int>()
                .toSet();
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
        _scheduleType != _ScheduleType.custom || _weekdays.isNotEmpty;
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
        .map((exercise) => _ExerciseOpt(exercise.id, exercise.name))
        .toList(growable: false);
    final AppLocalizations l10n = ref.watch(appStringsProvider);
    final IxThemeColors colors = context.ixColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
              children: <Widget>[
                Text(
                  l10n.setupTitle,
                  style: TextStyle(
                    fontSize: 42,
                    letterSpacing: -1.2,
                    height: 1.0,
                    fontWeight: FontWeight.w700,
                    color: colors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.setupSubtitle,
                  style: TextStyle(
                    fontSize: 15,
                    color: colors.mute,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  key: const Key('training_name_input'),
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: l10n.trainingName,
                    hintStyle: TextStyle(color: colors.softMute),
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: colors.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: colors.line),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _ScheduleSummaryRow(
                  key: const Key('setup_schedule_row'),
                  scheduleType: _scheduleType,
                  weekdays: _weekdays,
                  time: _scheduleTime,
                  onTap: _openScheduleEditor,
                  l10n: l10n,
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    Text(
                      l10n.exercisesHeader,
                      style: TextStyle(
                        color: colors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_items.length}',
                      style: TextStyle(
                        color: colors.mute,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  proxyDecorator:
                      (Widget child, int index, Animation<double> animation) {
                        return Material(
                          color: Colors.transparent,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 1, end: 1.02).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                            child: child,
                          ),
                        );
                      },
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final _SetupItem moved = _items.removeAt(oldIndex);
                      _items.insert(newIndex, moved);
                    });
                  },
                  itemCount: _items.length,
                  itemBuilder: (BuildContext context, int index) {
                    final _SetupItem item = _items[index];
                    final String title = _nameForId(
                      onboarding,
                      item.exerciseId,
                    );
                    final String group = groupForExerciseName(title);
                    return _SetupSwipeActionRow(
                      key: ObjectKey(item),
                      onDelete: () => setState(() => _items.remove(item)),
                      child: _ExerciseSummaryCard(
                        index: index,
                        title: title,
                        group: group,
                        item: item,
                        onTap: () async {
                          final _SetupItem? edited = await _editExercise(
                            context,
                            allExercises,
                            item,
                          );
                          if (edited != null) {
                            final int currentIndex = _items.indexOf(item);
                            if (currentIndex >= 0) {
                              setState(() => _items[currentIndex] = edited);
                            }
                          }
                        },
                        dragHandle: ReorderableDragStartListener(
                          index: index,
                          child: SizedBox(
                            key: Key('setup_exercise_drag_$index'),
                            width: 44,
                            height: 52,
                            child: Icon(
                              Icons.drag_indicator_rounded,
                              size: 22,
                              color: colors.mute,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  key: const Key('training_add_exercise'),
                  onPressed: allExercises.isEmpty
                      ? null
                      : () async {
                          final _SetupItem? item = await _editExercise(
                            context,
                            allExercises,
                            _SetupItem(
                              exerciseId: allExercises.first.id,
                              mode: ExerciseMode.reps,
                              value: 10,
                              sets: 3,
                              restSeconds: 20,
                            ),
                          );
                          if (item != null) {
                            setState(() => _items.add(item));
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.ink,
                    side: BorderSide(color: colors.line),
                    shape: const StadiumBorder(),
                    minimumSize: const Size.fromHeight(52),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.addExercise),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      colors.background.withValues(alpha: 0),
                      colors.background,
                    ],
                    stops: const <double>[0, 0.35],
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: IxButton.ghost(
                        label: l10n.back,
                        onPressed: widget.onBack,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: IxButton.primary(
                        key: const Key('training_save_button'),
                        label: l10n.save,
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

  Future<_SetupItem?> _editExercise(
    BuildContext context,
    List<_ExerciseOpt> available,
    _SetupItem initial,
  ) {
    final AppLocalizations l10n = ref.read(appStringsProvider);
    String query = '';
    String group = l10n.all;
    _SetupItem draft = initial;
    String groupFor(_ExerciseOpt e) => groupForExerciseName(e.name);
    return showModalBottomSheet<_SetupItem>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final IxThemeColors colors = context.ixColors;
            final List<_ExerciseOpt> filtered = available
                .where((e) => group == l10n.all || groupFor(e) == group)
                .where(
                  (e) => query.isEmpty || e.name.toLowerCase().contains(query),
                )
                .toList(growable: false);
            final List<String> groups = <String>{
              l10n.all,
              ...available.map(groupFor),
            }.toList(growable: false);
            final String selectedName = _nameForId(
              ref.read(onboardingControllerProvider),
              draft.exerciseId,
            );
            final String selectedGroup = groupForExerciseName(selectedName);
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
              ),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 10),
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.line,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.editExercise,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TextField(
                      key: const Key('exercise_search_input'),
                      onChanged: (v) =>
                          setModalState(() => query = v.trim().toLowerCase()),
                      decoration: InputDecoration(
                        hintText: l10n.searchExercises,
                        hintStyle: TextStyle(color: colors.softMute),
                        prefixIcon: Icon(
                          Icons.search,
                          size: 18,
                          color: colors.mute,
                        ),
                        filled: true,
                        fillColor: colors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.line),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.line),
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
                                ? colors.ink
                                : Colors.transparent,
                            foregroundColor: active
                                ? colors.inverse
                                : colors.ink,
                            side: BorderSide(
                              color: active ? colors.ink : colors.line,
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
                        final bool active = e.id == draft.exerciseId;
                        final String exerciseGroup = groupFor(e);
                        return InkWell(
                          key: Key('exercise_option_${e.id}'),
                          onTap: () => setModalState(
                            () => draft = draft.copyWith(exerciseId: e.id),
                          ),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: active ? colors.ink : colors.surface,
                              border: Border.all(
                                color: active ? colors.ink : colors.line,
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
                                          ? colors.inverse
                                          : colors.ink,
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
                                            ? colors.inverse
                                            : colors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      exerciseGroup.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: active
                                            ? colors.inverse.withValues(
                                                alpha: 0.55,
                                              )
                                            : colors.softMute,
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
                                      decoration: BoxDecoration(
                                        color: colors.accent,
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
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
                    decoration: BoxDecoration(
                      color: colors.background,
                      border: Border(top: BorderSide(color: colors.line)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            ExerciseGroupIcon(
                              group: selectedGroup,
                              size: 38,
                              color: colors.ink,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    selectedName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: colors.ink,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    selectedGroup.toUpperCase(),
                                    style: TextStyle(
                                      color: colors.softMute,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _exerciseSummary(draft),
                              style: TextStyle(
                                color: colors.mute,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _StepperPill(
                          keyPrefix: 'exercise_sets',
                          label: l10n.sets,
                          value: draft.sets,
                          min: 1,
                          onChanged: (int value) => setModalState(
                            () => draft = draft.copyWith(sets: value),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: colors.line),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                _ModePill(
                                  key: const Key('exercise_mode_reps'),
                                  label: l10n.reps,
                                  active: draft.mode == ExerciseMode.reps,
                                  onTap: () => setModalState(
                                    () => draft = draft.copyWith(
                                      mode: ExerciseMode.reps,
                                    ),
                                  ),
                                ),
                                _ModePill(
                                  key: const Key('exercise_mode_timer'),
                                  label: l10n.timer,
                                  active: draft.mode == ExerciseMode.time,
                                  onTap: () => setModalState(
                                    () => draft = draft.copyWith(
                                      mode: ExerciseMode.time,
                                      value: draft.value < 5 ? 20 : draft.value,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: draft.mode == ExerciseMode.time
                                  ? _DurationStepperPill(
                                      keyPrefix: 'exercise_work',
                                      label: l10n.work,
                                      seconds: draft.value,
                                      min: 5,
                                      step: 5,
                                      onPick: () async {
                                        final int? picked = await _pickDuration(
                                          context,
                                          draft.value,
                                          l10n.workDuration,
                                        );
                                        if (picked != null && picked > 0) {
                                          setModalState(
                                            () => draft = draft.copyWith(
                                              value: picked,
                                            ),
                                          );
                                        }
                                      },
                                      onChanged: (int value) => setModalState(
                                        () => draft = draft.copyWith(
                                          value: value,
                                        ),
                                      ),
                                    )
                                  : _StepperPill(
                                      keyPrefix: 'exercise_reps',
                                      label: l10n.reps,
                                      value: draft.value,
                                      min: 1,
                                      onChanged: (int value) => setModalState(
                                        () => draft = draft.copyWith(
                                          value: value,
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _DurationStepperPill(
                                keyPrefix: 'exercise_rest',
                                label: l10n.restLabel,
                                seconds: draft.restSeconds,
                                min: 0,
                                step: 5,
                                onPick: () async {
                                  final int? picked = await _pickDuration(
                                    context,
                                    draft.restSeconds,
                                    l10n.restDuration,
                                  );
                                  if (picked != null && picked >= 0) {
                                    setModalState(
                                      () => draft = draft.copyWith(
                                        restSeconds: picked,
                                      ),
                                    );
                                  }
                                },
                                onChanged: (int value) => setModalState(
                                  () => draft = draft.copyWith(
                                    restSeconds: value,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: IxButton.primary(
                            key: const Key('exercise_editor_apply'),
                            label: l10n.apply,
                            onPressed: () => Navigator.of(context).pop(draft),
                          ),
                        ),
                      ],
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
    final AppLocalizations l10n = ref.read(appStringsProvider);
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
            final IxThemeColors colors = context.ixColors;
            return Container(
              height: 320,
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
              ),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 10),
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.line,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.ink,
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
                        label: l10n.apply,
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

  Future<void> _openScheduleEditor() async {
    final AppLocalizations l10n = ref.read(appStringsProvider);
    final _ScheduleDraft? draft = await showModalBottomSheet<_ScheduleDraft>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        _ScheduleType type = _scheduleType;
        Set<int> weekdays = <int>{..._weekdays};
        String time = _scheduleTime;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final IxThemeColors colors = context.ixColors;
            return Container(
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colors.line,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: Text(
                          l10n.scheduleLabel,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colors.ink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ScheduleEditorContent(
                        scheduleType: type,
                        weekdays: weekdays,
                        time: time,
                        l10n: l10n,
                        onTypeChanged: (_ScheduleType next) =>
                            setModalState(() => type = next),
                        onToggleWeekday: (int day) {
                          setModalState(() {
                            if (weekdays.contains(day)) {
                              weekdays = <int>{...weekdays}..remove(day);
                            } else {
                              weekdays = <int>{...weekdays, day};
                            }
                          });
                        },
                        onPickTime: () async {
                          final String? picked = await _pickClock(
                            context,
                            time,
                            l10n.reminderTime,
                          );
                          if (picked != null) {
                            setModalState(() => time = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: IxButton.primary(
                          key: const Key('schedule_editor_apply'),
                          label: l10n.apply,
                          onPressed:
                              type == _ScheduleType.custom && weekdays.isEmpty
                              ? null
                              : () => Navigator.of(context).pop(
                                  _ScheduleDraft(
                                    type: type,
                                    weekdays: weekdays,
                                    time: time,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    if (draft != null) {
      setState(() {
        _scheduleType = draft.type;
        _weekdays = draft.weekdays;
        _scheduleTime = draft.time;
      });
    }
  }

  Future<String?> _pickClock(
    BuildContext context,
    String initial,
    String title,
  ) {
    final AppLocalizations l10n = ref.read(appStringsProvider);
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
            final IxThemeColors colors = context.ixColors;
            return Container(
              height: 320,
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
              ),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 10),
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.line,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.ink,
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
                        label: l10n.apply,
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
    if (_scheduleType == _ScheduleType.custom) {
      schedule = <String, dynamic>{
        'type': 'weekdays',
        'weekdays': _weekdays.toList()..sort(),
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

enum _ScheduleType { off, custom }

class _ScheduleDraft {
  const _ScheduleDraft({
    required this.type,
    required this.weekdays,
    required this.time,
  });

  final _ScheduleType type;
  final Set<int> weekdays;
  final String time;
}

String _scheduleSummary(_ScheduleType type, Set<int> weekdays, String time, AppLocalizations l10n) {
  if (type == _ScheduleType.off) {
    return l10n.scheduleOff;
  }
  return '${l10n.scheduleCustom} · ${_weekdaySummary(weekdays, l10n)} · $time';
}

String _weekdaySummary(Set<int> weekdays, AppLocalizations l10n) {
  final Map<int, String> dayNames = l10n.dayNames;
  final List<int> sorted = weekdays.toList()..sort();
  if (sorted.isEmpty) {
    return l10n.schedulePickDays;
  }
  return sorted.map((int day) {
    final String name = dayNames[day] ?? '';
    return name.isNotEmpty ? name.substring(0, 1) : '';
  }).join(' ');
}

String _exerciseSummary(_SetupItem item) {
  final String work = item.mode == ExerciseMode.reps
      ? '${item.value} reps'
      : '${_secondsShort(item.value)} work';
  return '${item.sets} sets · $work · ${_secondsShort(item.restSeconds)} rest';
}

String _secondsShort(int seconds) {
  if (seconds <= 0) {
    return '0s';
  }
  final int minutes = seconds ~/ 60;
  final int remainder = seconds % 60;
  if (minutes == 0) {
    return '${remainder}s';
  }
  if (remainder == 0) {
    return '${minutes}m';
  }
  return '${minutes}m ${remainder}s';
}

class _ExerciseOpt {
  const _ExerciseOpt(this.id, this.name);
  final String id;
  final String name;
}

class _ScheduleSummaryRow extends StatelessWidget {
  const _ScheduleSummaryRow({
    super.key,
    required this.scheduleType,
    required this.weekdays,
    required this.time,
    required this.onTap,
    required this.l10n,
  });

  final _ScheduleType scheduleType;
  final Set<int> weekdays;
  final String time;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final IxThemeColors colors = context.ixColors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: <Widget>[
              Text(
                l10n.scheduleLabel,
                style: TextStyle(
                  color: colors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Expanded(
                flex: 2,
                child: Text(
                  _scheduleSummary(scheduleType, weekdays, time, l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: colors.mute,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, color: colors.mute),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleEditorContent extends StatelessWidget {
  const _ScheduleEditorContent({
    required this.scheduleType,
    required this.weekdays,
    required this.time,
    required this.onTypeChanged,
    required this.onToggleWeekday,
    required this.onPickTime,
    required this.l10n,
  });

  final _ScheduleType scheduleType;
  final Set<int> weekdays;
  final String time;
  final ValueChanged<_ScheduleType> onTypeChanged;
  final ValueChanged<int> onToggleWeekday;
  final VoidCallback onPickTime;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final IxThemeColors colors = context.ixColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _ScheduleChoiceBox(
                key: const Key('schedule_off_choice'),
                title: l10n.scheduleOff,
                subtitle: l10n.scheduleNoReminders,
                active: scheduleType == _ScheduleType.off,
                onTap: () => onTypeChanged(_ScheduleType.off),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ScheduleChoiceBox(
                key: const Key('schedule_custom_choice'),
                title: l10n.scheduleCustom,
                subtitle: l10n.schedulePickDays,
                active: scheduleType == _ScheduleType.custom,
                onTap: () => onTypeChanged(_ScheduleType.custom),
              ),
            ),
          ],
        ),
        if (scheduleType == _ScheduleType.custom) ...<Widget>[
          const SizedBox(height: 14),
          Text(
            l10n.daysLabel,
            style: TextStyle(
              color: colors.mute,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              for (int day = 1; day <= 7; day++)
                _WeekdayChip(
                  key: Key('schedule_day_$day'),
                  day: day,
                  label: (l10n.dayNames[day] ?? '').substring(0, 1),
                  active: weekdays.contains(day),
                  onTap: onToggleWeekday,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPickTime,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: <Widget>[
                    Text(l10n.reminder, style: TextStyle(color: colors.mute)),
                    const Spacer(),
                    Text(
                      time,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.chevron_right_rounded, color: colors.mute),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ScheduleChoiceBox extends StatelessWidget {
  const _ScheduleChoiceBox({
    super.key,
    required this.title,
    required this.subtitle,
    required this.active,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final IxThemeColors colors = context.ixColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 66),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: active ? colors.ink : colors.surface,
          border: Border.all(color: active ? colors.ink : colors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                color: active ? colors.inverse : colors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                color: active
                    ? colors.inverse.withValues(alpha: 0.7)
                    : colors.mute,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekdayChip extends StatelessWidget {
  const _WeekdayChip({
    super.key,
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
    final IxThemeColors colors = context.ixColors;
    final Color inactiveFill =
        Color.lerp(colors.surface, colors.line, 0.38) ?? colors.surface;
    return InkWell(
      onTap: () => onTap(day),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: active ? colors.accent : inactiveFill,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? colors.inverse : colors.ink,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _SetupSwipeActionRow extends StatefulWidget {
  const _SetupSwipeActionRow({super.key, required this.child, this.onDelete});

  final Widget child;
  final VoidCallback? onDelete;

  @override
  State<_SetupSwipeActionRow> createState() => _SetupSwipeActionRowState();
}

class _SetupSwipeActionRowState extends State<_SetupSwipeActionRow> {
  static const double _maxReveal = 60;
  double _drag = 0;
  bool _isDeleting = false;
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final IxThemeColors colors = context.ixColors;
    final double reveal = (-_drag / _maxReveal).clamp(0.0, 1.0);
    return AnimatedSize(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: ClipRect(
        child: SizedBox(
          height: _isCollapsed ? 0 : 108,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            offset: _isDeleting ? const Offset(-0.16, 0) : Offset.zero,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _isDeleting ? 0 : 1,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 0,
                    right: 0,
                    left: 0,
                    bottom: 0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: _isDeleting
                          ? null
                          : (DragUpdateDetails details) {
                              final double next = (_drag + details.delta.dx)
                                  .clamp(-_maxReveal, 0.0);
                              setState(() => _drag = next);
                            },
                      onHorizontalDragEnd: _isDeleting
                          ? null
                          : (_) {
                              setState(
                                () => _drag = _drag.abs() > _maxReveal * 0.4
                                    ? -_maxReveal
                                    : 0,
                              );
                            },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        transform: Matrix4.translationValues(_drag, 0, 0),
                        color: colors.background,
                        child: widget.child,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 0,
                    bottom: 8,
                    width: _maxReveal,
                    child: IgnorePointer(
                      ignoring:
                          reveal < 0.18 ||
                          widget.onDelete == null ||
                          _isDeleting,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 140),
                        opacity: reveal,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _ActionIcon(
                            key: const Key('setup_exercise_delete_action'),
                            icon: Icons.delete_outline,
                            color: widget.onDelete == null
                                ? colors.softMute
                                : colors.accent,
                            active: _isDeleting,
                            onTap: widget.onDelete == null
                                ? null
                                : _handleDelete,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleDelete() async {
    if (_isDeleting || widget.onDelete == null) {
      return;
    }
    setState(() {
      _isDeleting = true;
      _drag = -_maxReveal;
    });
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) {
      return;
    }
    setState(() => _isCollapsed = true);
    await Future<void>.delayed(const Duration(milliseconds: 240));
    widget.onDelete?.call();
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final IxThemeColors colors = context.ixColors;
    return AnimatedScale(
      duration: const Duration(milliseconds: 170),
      curve: Curves.easeOutBack,
      scale: active ? 0.88 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          curve: Curves.easeOutCubic,
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: active ? color : colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: active ? color : colors.line),
          ),
          child: Icon(icon, size: 18, color: active ? colors.inverse : color),
        ),
      ),
    );
  }
}

class _ExerciseSummaryCard extends StatelessWidget {
  const _ExerciseSummaryCard({
    required this.index,
    required this.title,
    required this.group,
    required this.item,
    required this.onTap,
    required this.dragHandle,
  });

  final int index;
  final String title;
  final String group;
  final _SetupItem item;
  final VoidCallback onTap;
  final Widget dragHandle;

  @override
  Widget build(BuildContext context) {
    final IxThemeColors colors = context.ixColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.line),
            ),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 28,
                  child: Text(
                    (index + 1).toString().padLeft(2, '0'),
                    style: TextStyle(
                      color: colors.softMute,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ExerciseGroupIcon(group: group, size: 36, color: colors.ink),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        group.toUpperCase(),
                        style: TextStyle(
                          color: colors.softMute,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _exerciseSummary(item),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.mute,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                dragHandle,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final IxThemeColors colors = context.ixColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: active ? colors.ink : colors.surface,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? colors.inverse : colors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DurationStepperPill extends StatelessWidget {
  const _DurationStepperPill({
    this.keyPrefix,
    required this.label,
    required this.seconds,
    required this.min,
    required this.step,
    required this.onPick,
    required this.onChanged,
  });

  final String? keyPrefix;
  final String label;
  final int seconds;
  final int min;
  final int step;
  final VoidCallback onPick;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final IxThemeColors colors = context.ixColors;
    final bool canDecrease = seconds > min;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.line),
      ),
      child: Row(
        children: <Widget>[
          _MiniAdjust(
            key: keyPrefix == null ? null : Key('${keyPrefix}_decrement'),
            label: '−',
            onTap: canDecrease
                ? () => onChanged((seconds - step).clamp(min, 3599).toInt())
                : null,
          ),
          Expanded(
            child: InkWell(
              key: keyPrefix == null ? null : Key('${keyPrefix}_pick'),
              onTap: onPick,
              borderRadius: BorderRadius.circular(10),
              child: Column(
                children: <Widget>[
                  Text(
                    _secondsClock(seconds),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(fontSize: 11, color: colors.mute),
                  ),
                ],
              ),
            ),
          ),
          _MiniAdjust(
            key: keyPrefix == null ? null : Key('${keyPrefix}_increment'),
            label: '+',
            onTap: () => onChanged((seconds + step).clamp(min, 3599).toInt()),
          ),
        ],
      ),
    );
  }
}

String _secondsClock(int seconds) {
  final int m = seconds ~/ 60;
  final int s = seconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

class _StepperPill extends StatelessWidget {
  const _StepperPill({
    this.keyPrefix,
    required this.label,
    required this.value,
    required this.min,
    required this.onChanged,
  });

  final String? keyPrefix;
  final String label;
  final int value;
  final int min;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final IxThemeColors colors = context.ixColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.line),
      ),
      child: Row(
        children: <Widget>[
          _MiniAdjust(
            key: keyPrefix == null ? null : Key('${keyPrefix}_decrement'),
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
                Text(label, style: TextStyle(fontSize: 11, color: colors.mute)),
              ],
            ),
          ),
          _MiniAdjust(
            key: keyPrefix == null ? null : Key('${keyPrefix}_increment'),
            label: '+',
            onTap: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _MiniAdjust extends StatelessWidget {
  const _MiniAdjust({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final IxThemeColors colors = context.ixColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: onTap == null ? colors.line : colors.elevatedSurface,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: onTap == null ? colors.softMute : colors.ink,
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
