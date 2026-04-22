import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ixercise/design_system/ix_button.dart';
import 'package:ixercise/design_system/theme.dart';
import 'package:ixercise/features/onboarding/exercise_group_icon.dart';
import 'package:ixercise/features/onboarding/onboarding_controller.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key, this.onContinue});

  final Future<void> Function(Set<String>)? onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OnboardingState state = ref.watch(onboardingControllerProvider);
    final OnboardingController controller = ref.read(
      onboardingControllerProvider.notifier,
    );
    final IxThemeColors colors = context.ixColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
              children: <Widget>[
                const Offstage(
                  offstage: true,
                  child: Text('Pick Your Exercises'),
                ),
                Row(
                  children: List<Widget>.generate(2, (int i) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i == 1 ? 0 : 6),
                        height: 3,
                        decoration: BoxDecoration(
                          color: i == 0 ? colors.ink : colors.line,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                Text(
                  'STEP 1 OF 2',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    color: colors.softMute,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pick exercises\nyou actually do.',
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
                  'Build your personal library. You can always add more later.',
                  style: TextStyle(
                    fontSize: 15,
                    color: colors.mute,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  key: const Key('onboarding_search'),
                  onChanged: controller.setQuery,
                  decoration: InputDecoration(
                    hintText: 'Search exercises',
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.groups.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (BuildContext context, int index) {
                      final String group = state.groups[index];
                      final bool active = group == state.group;
                      return OutlinedButton(
                        onPressed: () => controller.setGroup(group),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: active
                              ? colors.ink
                              : Colors.transparent,
                          foregroundColor: active ? colors.inverse : colors.ink,
                          side: BorderSide(
                            color: active ? colors.ink : colors.line,
                          ),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(group),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: state.filteredExercises.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final exercise = state.filteredExercises[index];
                    final bool selected = state.selectedExerciseIds.contains(
                      exercise.id,
                    );
                    return InkWell(
                      key: Key('exercise_card_${exercise.id}'),
                      onTap: () => controller.toggleExercise(exercise.id),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: selected ? colors.ink : colors.surface,
                          border: Border.all(
                            color: selected ? colors.ink : colors.line,
                          ),
                        ),
                        child: Stack(
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                ExerciseGroupIcon(
                                  group: exercise.group,
                                  size: 38,
                                  color: selected ? colors.inverse : colors.ink,
                                ),
                                const Spacer(),
                                Text(
                                  exercise.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? colors.inverse
                                        : colors.ink,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  exercise.group.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: selected
                                        ? colors.inverse.withValues(alpha: 0.55)
                                        : colors.softMute,
                                  ),
                                ),
                              ],
                            ),
                            if (selected)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE11D2E),
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
                      child: Text.rich(
                        TextSpan(
                          text: '${state.selectedExerciseIds.length}',
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.ink,
                            fontWeight: FontWeight.w700,
                          ),
                          children: <InlineSpan>[
                            TextSpan(
                              text: ' selected',
                              style: TextStyle(
                                color: colors.mute,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: IxButton.primary(
                        key: const Key('onboarding_continue'),
                        label: 'Continue',
                        onPressed: state.canContinue
                            ? () async =>
                                  onContinue?.call(state.selectedExerciseIds)
                            : null,
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
}
